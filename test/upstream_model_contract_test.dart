// Behavioral/structural regressions from JS ephemeris.test.js and time.test.js.
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:ephemeris_lite/src/generated/series.dart' as data;
import 'package:test/test.dart';

double distance(List<double> a, List<double> b) => math.sqrt(
  List.generate(
    3,
    (i) => (a[i] - b[i]) * (a[i] - b[i]),
  ).reduce((a, b) => a + b),
);
void main() {
  test(
    'classic series uses a single Julian-millennium variable and official native frame',
    () {
      const t = 2.375;
      double evaluate(List<List<double>> groups) {
        var value = 0.0, power = 1.0;
        for (final group in groups) {
          var sum = 0.0;
          for (var j = 0; j < group.length; j += 3) {
            sum += group[j] * math.cos(group[j + 1] + group[j + 2] * t);
          }
          value += power * sum;
          power *= t;
        }
        return value;
      }

      final eps = (23 * 3600 + 26 * 60 + 21.41136) * math.pi / (180 * 3600),
          phi = -.05188 * math.pi / (180 * 3600);
      final ce = math.cos(eps),
          se = math.sin(eps),
          cp = math.cos(phi),
          sp = math.sin(phi);
      for (final e in data.planetSeries.entries) {
        final l = evaluate(e.value[0]),
            b = evaluate(e.value[1]),
            r = evaluate(e.value[2]);
        final x = r * math.cos(b) * math.cos(l),
            y = r * math.cos(b) * math.sin(l),
            z = r * math.sin(b);
        final expected = icrfEquatorialToJ2000Ecliptic([
          cp * x - sp * ce * y + sp * se * z,
          sp * x + cp * ce * y - cp * se * z,
          se * y + ce * z,
        ]);
        final actual = planetHeliocentricPosition(
          Planet.values.byName(e.key),
          j2000 + t * 365250,
        );
        for (var j = 0; j < 3; j++) {
          expect(actual[j], closeTo(expected[j], 2e-14), reason: e.key);
        }
      }
    },
  );
  test('Earth prefixes retain complete cross-power frequency envelopes', () {
    final groups = data.planetSeries['earth']!,
        budgets = data.planetPrefixes['earth']!;
    for (var axis = 0; axis < 3; axis++) {
      final previous = <double>{};
      for (final tier in ['fast', 'mid']) {
        final selected = <double>{};
        for (var power = 0; power < groups[axis].length; power++) {
          final rows = groups[axis][power],
              count = budgets[tier]![axis]?[power] ?? rows.length ~/ 3;
          for (var i = 0; i < count * 3; i += 3) {
            selected.add(rows[i + 2]);
          }
        }
        expect(selected.containsAll(previous), isTrue);
        for (var power = 0; power < groups[axis].length; power++) {
          final rows = groups[axis][power],
              count = budgets[tier]![axis]?[power] ?? rows.length ~/ 3;
          for (var i = 0; i < rows.length; i += 3) {
            expect(i < count * 3, selected.contains(rows[i + 2]));
          }
        }
        previous.addAll(selected);
      }
    }
    for (var axis = 0; axis < 3; axis++) {
      final blocks = [data.moonL, data.moonB, data.moonR][axis],
          budget = data.moonPrefixes[axis];
      for (var power = 0; power < blocks.length; power++) {
        expect(
          budget['fast']![power],
          lessThanOrEqualTo(budget['mid']![power]),
        );
        expect(
          budget['mid']![power],
          lessThanOrEqualTo(blocks[power].length ~/ 3),
        );
      }
    }
  });
  test('published folded term counts are retained exactly', () {
    const expected = {
      'mercury': [299, 160, 242],
      'venus': [156, 82, 153],
      'earth': [386, 50, 475],
      'mars': [489, 101, 528],
      'jupiter': [586, 232, 723],
      'saturn': [849, 320, 1241],
      'uranus': [413, 138, 653],
      'neptune': [153, 101, 167],
    };
    for (final e in expected.entries) {
      final axes = data.planetSeries[e.key]!;
      for (var axis = 0; axis < 3; axis++) {
        var count = 0;
        for (final block in axes[axis]) {
          expect(block.length % 3, 0);
          expect(block.every((x) => x.isFinite), isTrue);
          count += block.length ~/ 3;
        }
        expect(count, e.value[axis], reason: '${e.key} $axis');
      }
    }
  });
  test('Delta T joins retain value and first derivative continuity', () {
    for (final boundary in [-820.0, -720.0, 2027.0, 2028.0]) {
      final h = boundary < 0 ? 1e-4 : 1e-5;
      expect(
        deltaTSeconds(boundary - 1e-9),
        closeTo(deltaTSeconds(boundary + 1e-9), boundary < 0 ? 1e-6 : 1e-7),
      );
      expect(
        (deltaTSeconds(boundary) - deltaTSeconds(boundary - h)) / h,
        closeTo(
          (deltaTSeconds(boundary + h) - deltaTSeconds(boundary)) / h,
          2e-5,
        ),
      );
    }
  });
  test(
    'offline precision prefixes are nested and within complete table bounds',
    () {
      for (final entry in data.planetPrefixes.entries) {
        for (var axis = 0; axis < 3; axis++) {
          final blocks = data.planetSeries[entry.key]![axis];
          for (var n = 0; n < blocks.length; n++) {
            final count = blocks[n].length ~/ 3;
            final fast = entry.value['fast']![axis]?[n] ?? count,
                mid = entry.value['mid']![axis]?[n] ?? count;
            expect(fast, inInclusiveRange(0, mid));
            expect(mid, lessThanOrEqualTo(count));
          }
        }
      }
    },
  );
  test(
    'call-local position tiers preserve default and ordered aggregate errors',
    () {
      for (final body in Planet.values) {
        var fastDelta = 0.0, midDelta = 0.0;
        for (final jd in [j2000 - 123456, j2000, j2000 + 234567]) {
          final full = planetHeliocentricState(
            body,
            jd,
            accuracy: Accuracy.accurate,
          );
          final fast = planetHeliocentricState(
            body,
            jd,
            accuracy: Accuracy.fast,
          );
          final mid = planetHeliocentricState(body, jd, accuracy: Accuracy.mid);
          expect(planetHeliocentricState(body, jd).position, full.position);
          expect(planetHeliocentricState(body, jd).velocity, full.velocity);
          fastDelta += distance(fast.position, full.position);
          midDelta += distance(mid.position, full.position);
          expect(
            [
              ...fast.position,
              ...fast.velocity,
              ...mid.position,
              ...mid.velocity,
            ].every((v) => v.isFinite),
            isTrue,
          );
        }
        expect(fastDelta, greaterThanOrEqualTo(midDelta), reason: body.name);
        expect(fastDelta, greaterThan(0), reason: body.name);
      }
    },
  );
  test('VSOP87B official J2000 position controls', () {
    final fixtures = {
      Planet.mercury: [4.4293481043, -.0527573411, .4664714751, 1e-6],
      Planet.venus: [3.1870221910, .0569782849, .7202129248, 1e-6],
      Planet.earth: [1.7519238637, -.0000039656, .9833276823, 1e-6],
      Planet.mars: [6.2735389872, -.0247779824, 1.3912076937, 2e-6],
    };
    for (final e in fixtures.entries) {
      final l = e.value[0], b = e.value[1], r = e.value[2];
      expect(
        distance(planetHeliocentricPosition(e.key, j2000), [
          r * math.cos(b) * math.cos(l),
          r * math.cos(b) * math.sin(l),
          r * math.sin(b),
        ]),
        lessThanOrEqualTo(e.value[3]),
      );
    }
  });
  test(
    'analytic velocities at all old segment joins and full-range endpoints',
    () {
      const years = [
        -6000,
        -5975.25,
        -5975,
        -5974.75,
        -4000,
        -2040,
        -2020,
        -2000,
        -1980,
        -1960,
        0,
        990,
        1000,
        1200,
        1500,
        1550,
        1589,
        1590,
        1595,
        1600,
        1900,
        2024.75,
        2025,
        2025.25,
        2200,
        2205,
        2210,
        2211,
        2250,
        2300,
        2800,
        3000,
        3010,
        4000,
        5960,
        5980,
        6000,
        6020,
        6040,
        9975,
        10000,
      ];
      for (final body in Planet.values) {
        for (final year in years) {
          final jd = j2000 + (year - 2000) * 365.25,
              h = body == Planet.pluto ? 1 / 32 : .002;
          final state = planetHeliocentricState(body, jd),
              before = planetHeliocentricPosition(body, jd - h),
              after = planetHeliocentricPosition(body, jd + h);
          for (var i = 0; i < 3; i++) {
            expect(
              state.velocity[i],
              closeTo(
                (after[i] - before[i]) / (2 * h),
                body == Planet.pluto ? 2e-9 : 2e-7,
              ),
              reason: '$body $year $i',
            );
          }
        }
        final state = planetHeliocentricState(body, j2000),
            earth = earthState(j2000),
            geo = planetGeocentricState(body, j2000);
        for (var i = 0; i < 3; i++) {
          expect(geo.position[i], state.position[i] - earth.position[i]);
          expect(geo.velocity[i], state.velocity[i] - earth.velocity[i]);
        }
      }
    },
  );
}
