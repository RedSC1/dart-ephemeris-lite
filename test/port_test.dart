import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final oracle =
      jsonDecode(File('test/fixtures/js_oracles.json').readAsStringSync())
          as Map<String, dynamic>;
  test('Delta-T agrees with JS across joins and future model', () {
    for (final row in oracle['deltaT'] as List) {
      expect(
        deltaTSeconds((row['year'] as num).toDouble()),
        closeTo(row['value'] as num, 1e-8),
        reason: 'year ${row['year']}',
      );
    }
  });
  test('hybrid calendar, decimal years and TT/UT1 agree with JS', () {
    for (final row in oracle['time'] as List) {
      final c = row['civil'];
      final jd = julianDay(
        year: c['year'],
        month: c['month'],
        day: c['day'],
        hour: c['hour'],
        minute: c['minute'],
        second: c['second'],
      );
      expect(jd, row['jd']);
      final result = calendarDateFromJulianDay(jd).toJson();
      for (final field in ['year', 'month', 'day', 'hour', 'minute']) {
        expect(result[field], row['roundtrip'][field]);
      }
      expect(result['second'], closeTo(row['roundtrip']['second'], 1e-8));
      expect(decimalYearFromJulianDay(jd), closeTo(row['decimalYear'], 1e-10));
      final instant = JulianTime.fromUT1(jd);
      expect(instant.jdTT, closeTo(row['instant']['jdTT'], 1e-9));
      expect(JulianTime.fromTT(instant.jdTT).jdUT1, closeTo(jd, 1e-9));
    }
  });
  test('1107 position/velocity states agree with JS in all three tiers', () {
    for (final row in oracle['states'] as List) {
      final jd = (row['jd'] as num).toDouble(),
          accuracy = Accuracy.values.byName(row['accuracy']);
      final body = row['body'] as String;
      final state = body == 'moon'
          ? moonState(jd, accuracy: accuracy)
          : planetHeliocentricState(
              Planet.values.byName(body),
              jd,
              accuracy: accuracy,
            );
      for (var i = 0; i < 3; i++) {
        expect(
          state.position[i],
          closeTo(row['position'][i], body == 'moon' ? 1e-6 : 1e-11),
          reason: '$body $jd $accuracy position $i',
        );
        expect(
          state.velocity[i],
          closeTo(row['velocity'][i], body == 'moon' ? 1e-6 : 1e-11),
          reason: '$body $jd $accuracy velocity $i',
        );
      }
    }
  });
  test('civil validation and historical calendar gap', () {
    expect(
      () => ZonedTime(year: 1582, month: 10, day: 10, offsetMinutes: 480),
      throwsArgumentError,
    );
    expect(
      () => ZonedTime(year: 1900, month: 2, day: 29, offsetMinutes: 0),
      throwsArgumentError,
    );
    expect(
      () => ZonedTime(year: 2000, month: 1, day: 1, offsetMinutes: 841),
      throwsArgumentError,
    );
    expect(
      () => ZonedTime(
        year: 2000,
        month: 1,
        day: 1,
        second: double.nan,
        offsetMinutes: 0,
      ),
      throwsArgumentError,
    );
    expect(() => earthState(double.nan), throwsArgumentError);
    expect(
      () =>
          JulianTime.fromValues(jdUT1: j2000, jdTT: j2000, deltaTSeconds: 100),
      throwsArgumentError,
    );
    expect(
      julianDay(year: 1582, month: 10, day: 15) -
          julianDay(year: 1582, month: 10, day: 4),
      1,
    );
  });
  test('DateTime is an instant, fixed offset selects wall clock', () {
    final utc = DateTime.utc(2000, 1, 1, 12);
    final t = JulianTime.fromDateTime(utc);
    expect(t.jdUT1, j2000);
    expect(t.toDateTime(), utc);
    expect(t.toZonedTime(480).hour, 20);
    expect(
      ZonedTime.fromDateTime(utc, offsetMinutes: 480).toJulianTime().jdUT1,
      j2000,
    );
  });
  test('state results are immutable; centers and units remain explicit', () {
    final e = earthState(j2000),
        m = moonState(j2000),
        emb = embState(j2000),
        h = moonHeliocentricState(j2000),
        sun = sunGeocentricState(j2000);
    expect(() => e.position[0] = 0, throwsUnsupportedError);
    for (var i = 0; i < 3; i++) {
      expect(
        emb.position[i] - e.position[i],
        closeTo(m.position[i] / ((1 + earthMoonMassRatio) * auKm), 1e-15),
      );
      expect(
        h.position[i] - e.position[i],
        closeTo(m.position[i] / auKm, 1e-15),
      );
      expect(sun.position[i], -e.position[i]);
      expect(planetGeocentricState(Planet.earth, j2000).position[i], 0);
    }
  });
}
