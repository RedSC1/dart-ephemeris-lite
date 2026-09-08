// Ported independent controls from JS apparent/ephemeris/orbital/observation tests.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:ephemeris_lite/src/sky_math.dart' as v;
import 'package:test/test.dart';
import 'orbital_support.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/upstream/$name.json').readAsStringSync())
        as Map<String, dynamic>;
SkyFrame _frame(Object? f) => switch (f) {
  'j2000' => SkyFrame.j2000,
  'mean-of-date' => SkyFrame.meanOfDate,
  _ => SkyFrame.trueOfDate,
};
ApparentOptions _ap(Map? o) => ApparentOptions(
  frame: _frame(o?['frame']),
  lightTime: o?['lightTime'] as bool? ?? true,
  aberration: o?['aberration'] as bool? ?? true,
  solarDeflection: o?['solarDeflection'] as bool? ?? true,
);
double _n(dynamic n) => (n as num).toDouble();
void main() {
  for (final body in [Planet.earth, Planet.mercury]) {
    test('JS direct ${body.name} frame and AU fixture controls', () {
      for (final r in _fixture('${body.name}-model')['samples']) {
        final jd = _n(r['jdTT']),
            span = 1 + ((jd - j2000) / 365250).abs(),
            p = planetHeliocentricState(body, jd),
            x = r['corrected'];
        for (var i = 0; i < 3; i++) {
          expect(
            p.position[i],
            closeTo(
              _n(x['position'][i]),
              body == Planet.earth ? 4e-12 * span : 3e-13,
            ),
          );
          expect(
            p.velocity[i],
            closeTo(
              _n(x['velocity'][i]),
              body == Planet.earth ? 8e-14 * span : 1e-14,
            ),
          );
        }
      }
    });
  }
  test(
    'JS apparent: 81 independent C++/DE441 controls, original envelopes',
    () {
      const bounds = {
        'sun': [.2, 30],
        'moon': [.8, 2],
        'mercury': [.5, 100],
        'venus': [.5, 150],
        'mars': [1.5, 250],
        'jupiter': [1, 1000],
        'saturn': [1, 1500],
        'uranus': [8, 60000],
        'neptune': [4, 30000],
      };
      final rows = _fixture('sky-de441')['samples'] as List;
      expect(rows, hasLength(81));
      for (final r in rows) {
        final p = apparentBodyState(
              SkyBody.values.byName(r['body']),
              _n(r['jdTT']),
              options: ApparentOptions(frame: _frame(r['frame'])),
            ),
            x = r['values'] as List,
            b = bounds[r['body']]!;
        expect(
          v.signedDeg(p.longitudeDeg - _n(x[0])) * 3600,
          closeTo(0, b[0].toDouble()),
        );
        expect((p.latitudeDeg - _n(x[1])) * 3600, closeTo(0, b[0].toDouble()));
        expect((p.distanceAu - _n(x[6])) * auKm, closeTo(0, b[1].toDouble()));
        expect(
          p.longitudeSpeedDegPerDay,
          closeTo(_n(x[3]), r['body'] == 'moon' ? 0.001 : .0001),
        );
      }
    },
  );
  test(
    'JS ephemeris: global Moon Python and DE441 states, analytic velocity',
    () {
      for (final r in _fixture('moon-model')['samples'] as List) {
        final jd = _n(r['jd']),
            s = moonState(jd),
            x = r['expected'] as List,
            reference = r['de441'] as List;
        for (var i = 0; i < 3; i++) {
          expect(s.position[i], closeTo(_n(x[i]), .0002));
          expect(s.velocity[i], closeTo(_n(x[i + 3]), .00005));
          expect(
            s.velocity[i],
            closeTo(
              (moonPosition(jd + .002)[i] - moonPosition(jd - .002)[i]) / .004,
              .05,
            ),
          );
        }
        expect(
          v.norm(List.generate(3, (i) => s.position[i] - _n(reference[i]))),
          lessThan(r['year'] >= 1600 && r['year'] <= 2200 ? 2 : 30),
        );
      }
    },
  );
  test('JS ephemeris: all planet Python/DE441 controls including Pluto', () {
    final bodies = Map<String, dynamic>.from(_fixture('top-model')['bodies']);
    bodies['pluto'] = (_fixture('pluto-model')['samples'] as List)
        .map((r) => {...r, 'corrected': r['expected']})
        .toList();
    const bounds = {
      'mercury': 350,
      'venus': 750,
      'mars': 10000,
      'jupiter': 5000,
      'saturn': 21000,
      'uranus': 90000,
      'neptune': 16000,
      'pluto': 5000000,
    };
    final eps = meanObliquityIau2006(j2000),
        c = math.cos(eps),
        s = math.sin(eps),
        precession = vondrak2011PrecessionMatrix(j2000);
    final matrix =
        [
              [1.0, 0.0, 0.0],
              [0.0, c, s],
              [0.0, -s, c],
            ]
            .map(
              (row) => List.generate(
                3,
                (j) => List.generate(
                  3,
                  (k) => row[k] * precession[k][j],
                ).reduce((a, b) => a + b),
              ),
            )
            .toList();
    List<double> toIcrf(List<double> x) => List.generate(
      3,
      (j) =>
          List.generate(3, (k) => x[k] * matrix[k][j]).reduce((a, b) => a + b),
    );
    for (final entry in bodies.entries) {
      for (final row in entry.value as List) {
        final jd = _n(row['jd']),
            state = planetHeliocentricState(
              Planet.values.byName(entry.key),
              jd,
            ),
            p = toIcrf(state.position),
            speed = toIcrf(state.velocity),
            x = row['corrected'] as List;
        for (var i = 0; i < 3; i++) {
          expect(
            p[i] * auKm,
            closeTo(_n(x[i]), .01),
            reason: '${entry.key} $jd position',
          );
          expect(
            speed[i] * auKm / 86.4,
            closeTo(_n(x[i + 3]), 1e-7),
            reason: '${entry.key} $jd velocity',
          );
        }
        if (row['de441'] != null) {
          final year = 2000 + (jd - j2000) / 365.25,
              bound = entry.key == 'pluto' && year >= 1600 && year <= 2200
                  ? 2000
                  : bounds[entry.key]!;
          expect(
            v.norm(List.generate(3, (i) => p[i] * auKm - _n(row['de441'][i]))),
            lessThan(bound),
          );
        }
      }
    }
  });
  test(
    'JS orbital: 297 C++/DE441 events with original per-model tolerances',
    () {
      const bounds = {
        'searchLunarApsides': 25,
        'searchEarthApsides': 75,
        'searchLunarNodes': 6,
        'searchGreatestElongations': 3,
        'searchRightAscensionStations': 8,
        'searchRelativeRightAscension': 1,
      };
      final rows = _fixture('orbital-de441')['samples'] as List,
          cache = <String, List<OrbitalEvent>>{},
          counts = <String, int>{};
      expect(rows, hasLength(297));
      for (final r in rows) {
        final key = jsonEncode([
          r['fn'],
          r['body'],
          r['start'],
          r['end'],
          r['options'],
        ]);
        counts[key] = (counts[key] ?? 0) + 1;
        final events = cache.putIfAbsent(
          key,
          () => runOrbital({
            'kind': r['fn'],
            'args': [
              if (r['body'] != null) r['body'],
              if (r['fn'] == 'searchRelativeRightAscension') ...['moon', 0],
              r['start'],
              r['end'],
            ],
            'options': r['options'] ?? {},
          }),
        );
        final found = events
            .where((e) => (e.time.jdTT - _n(r['event']['jdTT'])).abs() < .01)
            .toList();
        expect(found, hasLength(1), reason: key);
        final seconds =
            r['body'] == 'venus' &&
                [
                  'searchGreatestElongations',
                  'searchRightAscensionStations',
                ].contains(r['fn'])
            ? 10
            : bounds[r['fn']]!;
        expect(
          (found.single.time.jdTT - _n(r['oracleJdTT'])).abs() * 86400,
          lessThan(seconds),
          reason: key,
        );
      }
      for (final e in cache.entries) {
        expect(e.value.length, counts[e.key]);
      }
    },
  );
  final observation = _fixture('observation-de441')['rows'] as List;
  test('JS physical phenomena: 45 independent DE441 triangles', () {
    final rows = observation.where((r) => r['kind'] == 'phenomena').toList();
    expect(rows, hasLength(45));
    for (final r in rows) {
      final body = SkyBody.values.byName(r['body']),
          p = bodyPhenomena(body, _n(r['jd'])),
          x = r['expected'];
      if (body != SkyBody.sun) {
        expect(p.phaseAngleDeg, closeTo(_n(x[5]), .0002));
        expect(p.illuminatedFraction, closeTo(_n(x[6]), 1e-6));
      }
      expect(p.solarElongationDeg, closeTo(_n(x[2]), .001));
      expect(p.apparentDiameterArcsec, closeTo(_n(x[3]), .003));
      expect(p.horizontalParallaxDeg, closeTo(_n(x[7]), 2e-6));
    }
  });
  test(
    'JS observation: independent native horizontal positions and all rise/set/transit roots',
    () {
      for (final r in observation.where(
        (r) => ['horizontal', 'visibility'].contains(r['kind']),
      )) {
        final raw = r['observer'] as Map,
            o = Observer(
              longitudeDeg: _n(raw['longitudeDeg']),
              latitudeDeg: _n(raw['latitudeDeg']),
              heightMeters: _n(raw['heightMeters'] ?? 0),
              pressureMbar: _n(raw['pressureMbar'] ?? 1013.25),
              temperatureCelsius: _n(raw['temperatureCelsius'] ?? 15),
            ),
            opt = r['options'] as Map? ?? {},
            options = BodyVisibilityOptions(
              apparent: _ap(opt['apparent'] as Map?),
              refraction: opt['refraction'] as bool? ?? true,
              limb: DiscLimb.values.byName(opt['limb'] as String? ?? 'upper'),
              horizonDegrees: _n(opt['horizonDegrees'] ?? 0),
            ),
            body = SkyBody.values.byName(r['body']),
            x = r['expected'] as List;
        if (r['kind'] == 'horizontal') {
          final p = bodyHorizontalPosition(
            body,
            _n(r['jd']),
            o,
            options: options,
          );
          expect(v.signedDeg(p.azimuthDeg - _n(x[0])), closeTo(0, .001));
          expect(p.geometricAltitudeDeg, closeTo(_n(x[1]), .001));
          expect(p.apparentAltitudeDeg, closeTo(_n(x[2]), .001));
          expect(
            p.distanceAu,
            closeTo(
              _n(x[3]),
              ['uranus', 'neptune'].contains(body.name)
                  ? 5e-5
                  : body == SkyBody.moon
                  ? 1e-8
                  : 3e-6,
            ),
          );
        } else {
          final p = bodyRiseSetForDay(body, _n(r['jd']), o, options: options),
              fields = [p.rises, p.sets, p.upperTransits, p.lowerTransits];
          for (var i = 0; i < 4; i++) {
            expect(fields[i].length, (x[i] as List).length);
            for (var j = 0; j < fields[i].length; j++) {
              expect(
                (fields[i][j].jdUT1 - _n(x[i][j])) * 86400,
                closeTo(0, .5),
                reason: '${body.name} ${r['jd']} $i',
              );
            }
          }
        }
      }
    },
  );
  test(
    'JS events: complete independent longitude/relative/station/ingress enumerations',
    () {
      final ingress = <String, Map<String, dynamic>>{};
      void compare(List<SkyEvent> actual, List expected, Map r) {
        expect(
          actual.length,
          expected.length,
          reason: '${r['kind']} ${r['body']}',
        );
        final seconds = r['body'] == 'jupiter' && r['kind'] == 'stations'
            ? 15
            : ['uranus', 'neptune'].contains(r['body'])
            ? 60
            : 10;
        for (var i = 0; i < actual.length; i++) {
          expect(
            (actual[i].time.jdTT - _n(expected[i])).abs() * 86400,
            lessThanOrEqualTo(seconds),
          );
        }
      }

      for (final r in observation) {
        if (![
          'ingress-boundary',
          'stations',
          'longitude',
          'relative',
        ].contains(r['kind'])) {
          continue;
        }
        final o = r['options'] as Map? ?? {},
            ap = _ap(o['apparent'] as Map?),
            body = SkyBody.values.byName(r['body']),
            start = _n(r['start']),
            end = _n(r['end']);
        if (r['kind'] == 'ingress-boundary') {
          final k = jsonEncode([r['body'], o, start, end]);
          final g = ingress.putIfAbsent(
            k,
            () => {'row': r, 'expected': <dynamic>[]},
          );
          (g['expected'] as List).addAll(r['expected']);
          continue;
        }
        final events = switch (r['kind']) {
          'stations' => searchStations(body, start, end, apparent: ap),
          'longitude' => searchLongitudeCrossings(
            body,
            _n(r['angle']),
            start,
            end,
            apparent: ap,
          ),
          _ => searchRelativeLongitude(
            body,
            SkyBody.values.byName(r['other']),
            _n(r['angle']),
            start,
            end,
            apparent: ap,
          ),
        };
        compare(events, r['expected'], r);
      }
      expect(ingress.length, 27);
      for (final g in ingress.values) {
        final r = g['row'],
            o = r['options'] as Map,
            expected = g['expected'] as List
              ..sort((a, b) => _n(a).compareTo(_n(b)));
        compare(
          searchIngresses(
            SkyBody.values.byName(r['body']),
            _n(r['start']),
            _n(r['end']),
            apparent: _ap(o['apparent']),
          ),
          expected,
          r,
        );
      }
    },
  );
}
