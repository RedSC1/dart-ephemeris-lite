import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final rows =
      jsonDecode(
            File('test/fixtures/js_accurate_events.json').readAsStringSync(),
          )
          as List;
  test(
    'accurate event roots match JS and satisfy apparent-angle residuals',
    () {
      for (final row in rows) {
        final angle = (row['angle'] as num).toDouble();
        final jd = row['lunar']
            ? lunarPhaseTimeAccurate(angle)
            : solarLongitudeTimeAccurate(angle);
        expect(jd, closeTo(row['jdTT'], 1e-8));
        final sun = apparentBodyState(SkyBody.sun, jd),
            moon = row['lunar'] ? apparentBodyState(SkyBody.moon, jd) : null;
        final value = moon == null
            ? sun.longitudeDeg
            : moon.longitudeDeg - sun.longitudeDeg;
        final rate = moon == null
            ? sun.longitudeSpeedDegPerDay
            : moon.longitudeSpeedDegPerDay - sun.longitudeSpeedDegPerDay;
        final error = (value - angle * 180 / math.pi + 180) % 360 - 180;
        expect((error / rate).abs() * 86400, lessThanOrEqualTo(0.011));
      }
    },
  );
  test('accurate tolerances are validated rather than silently ignored', () {
    expect(
      () => solarLongitudeTimeAccurate(0, toleranceSeconds: 0),
      throwsArgumentError,
    );
    expect(
      () => lunarPhaseTimeAccurate(0, toleranceSeconds: double.nan),
      throwsArgumentError,
    );
    expect(
      () => solarLongitudeTimeAccurate(0, toleranceSeconds: 1e-12),
      throwsRangeError,
    );
  });
}
