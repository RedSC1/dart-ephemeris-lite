import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final rows =
      jsonDecode(File('test/fixtures/js_fast_events.json').readAsStringSync())
          as List;
  test('392 fast event roots match the original JS fixed-stage path', () {
    for (final row in rows) {
      final angle = (row['angle'] as num).toDouble();
      final jd = row['lunar']
          ? lunarPhaseTimeFast(angle)
          : solarLongitudeTimeFast(angle);
      expect(jd, closeTo(row['jdTT'], 2e-8), reason: '${row['lunar']} $angle');
    }
  });
  test('unwrapped revolutions select distinct events; invalid seeds fail', () {
    final a = lunarPhaseTimeFast(0), b = lunarPhaseTimeFast(2 * math.pi);
    expect(b - a, inInclusiveRange(29, 30));
    final s = solarLongitudeTimeFast(0),
        s2 = solarLongitudeTimeFast(2 * math.pi);
    expect(s2 - s, inInclusiveRange(365, 366));
    expect(() => solarLongitudeTimeFast(double.nan), throwsArgumentError);
    expect(() => lunarPhaseTimeFast(double.infinity), throwsArgumentError);
    expect(() => solarLongitudeTimeFast(1e8), throwsRangeError);
  });
}
