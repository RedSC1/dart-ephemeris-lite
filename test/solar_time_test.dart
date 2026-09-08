import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final rows =
      jsonDecode(File('test/fixtures/js_solar_time.json').readAsStringSync())
          as List;
  test('120 solar clocks, equation of time and GAST match JS', () {
    for (final r in rows) {
      final c = r['civil'];
      final time = ZonedTime(
        year: c['year'],
        month: c['month'],
        day: c['day'],
        hour: c['hour'],
        minute: c['minute'],
        second: (c['second'] as num).toDouble(),
        offsetMinutes: c['offsetMinutes'],
      );
      final longitude = (r['longitude'] as num).toDouble();
      final eq = equationOfTime(time),
          mean = meanSolarTime(time, longitude),
          apparent = trueSolarTime(time, longitude);
      expect(eq.equationSeconds, closeTo(r['eq']['equationSeconds'], 1e-6));
      expect(
        greenwichSiderealTime(time.toJulianTime().jdUT1),
        closeTo(r['gast'], 1e-9),
      );
      expect(mean.jdSolar, r['mean']['jdSolar']);
      expect(apparent.jdSolar, closeTo(r['apparent']['jdSolar'], 1e-9));
      expect(identical(apparent.sourceClock, time), isTrue);
      expect(
        localMeanToApparentSolarTime(mean.jdSolar, longitude),
        closeTo(apparent.jdSolar, 1e-9),
      );
      expect(
        localApparentToMeanSolarTime(apparent.jdSolar, longitude),
        closeTo(mean.jdSolar, 1e-9),
      );
    }
  });
  test('virtual solar clock is distinct from physical zoned time', () {
    final clock = trueSolarTime(JulianTime.fromUT1(j2000), 120);
    expect(clock, isNot(isA<ZonedTime>()));
    expect(clock.instant.jdUT1, j2000);
    expect(() => trueSolarTime(j2000, 181), throwsArgumentError);
    expect(() => equationOfTime('2000-01-01'), throwsArgumentError);
  });
}
