import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'orbital_support.dart';

void main() {
  test('orbital searches match JavaScript across frames, tiers and epochs', () {
    final rows =
        jsonDecode(File('test/fixtures/orbital.json').readAsStringSync())
            as List;
    for (final row in rows) {
      final actual = runOrbital(row as Map<String, dynamic>);
      final expected = row['result'] as List;
      expect(
        actual.length,
        expected.length,
        reason: '${row['kind']} ${row['args']} ${row['options']}',
      );
      for (var i = 0; i < actual.length; i++) {
        compareOrbital(actual[i].toJson(), expected[i], '${row['kind']}[$i]');
      }
    }
  });
  final start = julianDay(year: 2026, month: 1, day: 1);
  test('apsides are distance extrema and results are immutable', () {
    double radius(double t) =>
        math.sqrt(moonState(t).position.fold<double>(0, (s, x) => s + x * x));
    final events = searchLunarApsides(start, start + 65);
    expect(events, isNotEmpty);
    for (final e in events) {
      final t = e.time.jdTT;
      for (final d in [-.05, .05]) {
        expect(
          e.kind == ApsisKind.periapsis
              ? radius(t) < radius(t + d)
              : radius(t) > radius(t + d),
          isTrue,
        );
      }
    }
    expect(() => events.clear(), throwsUnsupportedError);
    expect(searchLunarApsides(start, start), isEmpty);
  });
  test('nutation changes node longitude but not the crossing plane', () {
    final mean = searchLunarNodes(start, start + 65);
    final apparent = searchLunarNodes(
      start,
      start + 65,
      frame: SkyFrame.trueOfDate,
    );
    expect(mean.length, apparent.length);
    for (var i = 0; i < mean.length; i++) {
      expect(mean[i].time.jdTT, closeTo(apparent[i].time.jdTT, 1e-9));
      expect(mean[i].latitudeDeg.abs(), lessThan(1e-6));
      expect(mean[i].kind, apparent[i].kind);
      expect(mean[i].longitudeDeg, isNot(apparent[i].longitudeDeg));
    }
  });
  test('RA stations classify the motion after the turning point', () {
    final events = searchRightAscensionStations(
      SkyBody.mercury,
      start,
      start + 365,
    );
    expect(events, isNotEmpty);
    for (final e in events) {
      final after = apparentBodyState(
        SkyBody.mercury,
        e.time.jdTT + .01,
      ).rightAscensionSpeedDegPerDay;
      expect(
        e.direction,
        after < 0 ? MotionDirection.retrograde : MotionDirection.direct,
      );
      expect(e.time.jdTT, inInclusiveRange(start, start + 365));
    }
  });
  test(
    'greatest elongations are angular maxima with stable direction labels',
    () {
      double separation(double t) {
        final a = apparentBodyPosition(SkyBody.mercury, t).equatorialPositionAu;
        final b = apparentBodyPosition(SkyBody.sun, t).equatorialPositionAu;
        double dot(List<double> x, List<double> y) =>
            x[0] * y[0] + x[1] * y[1] + x[2] * y[2];
        return math.acos(
          (dot(a, b) / math.sqrt(dot(a, a) * dot(b, b))).clamp(-1, 1),
        );
      }

      final events = searchGreatestElongations(
        SkyBody.mercury,
        start,
        start + 365,
      );
      final j2000 = searchGreatestElongations(
        SkyBody.mercury,
        start,
        start + 365,
        apparent: const ApparentOptions(frame: SkyFrame.j2000),
      );
      expect(events, isNotEmpty);
      expect(events.length, j2000.length);
      for (var i = 0; i < events.length; i++) {
        final e = events[i], t = e.time.jdTT;
        expect(separation(t), greaterThan(separation(t - .05)));
        expect(separation(t), greaterThan(separation(t + .05)));
        expect(e.kind, j2000[i].kind);
      }
    },
  );
  test('invalid searches fail explicitly', () {
    expect(
      () => searchGreatestElongations(SkyBody.mars, start, start + 10),
      throwsRangeError,
    );
    expect(
      () => searchRelativeRightAscension(
        SkyBody.sun,
        SkyBody.sun,
        0,
        start,
        start + 1,
      ),
      throwsRangeError,
    );
    expect(
      () => searchRelativeRightAscension(
        SkyBody.moon,
        SkyBody.sun,
        double.nan,
        start,
        start + 1,
      ),
      throwsArgumentError,
    );
    expect(() => searchLunarNodes(start + 1, start), throwsArgumentError);
    expect(
      () => searchEarthApsides(start, start + 10, stepDays: 0),
      throwsArgumentError,
    );
  });
}
