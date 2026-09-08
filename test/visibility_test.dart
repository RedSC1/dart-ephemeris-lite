import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

Observer observer(Map o) => Observer(
  longitudeDeg: (o['longitudeDeg'] as num).toDouble(),
  latitudeDeg: (o['latitudeDeg'] as num).toDouble(),
  heightMeters: (o['heightMeters'] as num?)?.toDouble() ?? 0,
  pressureMbar: (o['pressureMbar'] as num?)?.toDouble() ?? 1013.25,
  temperatureCelsius: (o['temperatureCelsius'] as num?)?.toDouble() ?? 15,
);
DiscLimb limb(Map o) => DiscLimb.values.byName(o['limb'] ?? 'upper');
SolarVisibilityOptions solarOptions(Map o) => SolarVisibilityOptions(
  limb: limb(o),
  refraction: o['refraction'] ?? true,
  fixedDiscSize: o['fixedDiscSize'] ?? false,
  horizonDegrees: (o['horizonDegrees'] as num?)?.toDouble() ?? 0,
);
BodyVisibilityOptions bodyOptions(Map o) => BodyVisibilityOptions(
  limb: limb(o),
  refraction: o['refraction'] ?? true,
  horizonDegrees: (o['horizonDegrees'] as num?)?.toDouble() ?? 0,
  apparent: ApparentOptions(
    accuracy: Accuracy.values.byName(o['apparent']?['accuracy'] ?? 'accurate'),
  ),
);
const states = {
  'not-found': AltitudeState.notFound,
  'crosses': AltitudeState.crosses,
  'always-above': AltitudeState.alwaysAbove,
  'always-below': AltitudeState.alwaysBelow,
  'tangent': AltitudeState.tangent,
};
void instant(JulianTime? a, dynamic e) {
  if (e == null) {
    expect(a, isNull);
    return;
  }
  expect(a, isNotNull);
  expect((a!.jdUT1 - e['jdUT1']).abs() * 86400, lessThan(0.02));
}

void main() {
  final f =
      jsonDecode(File('test/fixtures/visibility.json').readAsStringSync())
          as Map;
  test('atmospheric refraction cutoff and blend match JS', () {
    for (final row in f['refraction']) {
      expect(
        hybridAtmosphericRefraction(
          (row['angle'] as num).toDouble(),
          pressureMbar: (row['options']['pressureMbar'] as num).toDouble(),
          temperatureCelsius: 10,
        ),
        closeTo(row['value'], 2e-15),
      );
    }
  });
  test(
    'topocentric positions across bodies, accuracy tiers and polar sites match JS',
    () {
      for (final row in f['positions']) {
        final a = bodyHorizontalPosition(
          SkyBody.values.byName(row['body']),
          (row['jd'] as num).toDouble(),
          observer(row['observer']),
          options: bodyOptions(row['options']),
        ).toJson();
        final e = row['result'] as Map;
        for (final key in e.keys) {
          if (e[key] is num) {
            expect(
              a[key] as num,
              closeTo(e[key], key == 'distanceAu' ? 1e-11 : 1e-8),
              reason: '${row['body']} $key ${row['observer']}',
            );
          } else {
            expect(a[key], e[key]);
          }
        }
      }
    },
  );
  test('fast solar samples and rise/set windows match JS', () {
    for (final row in f['solar']) {
      final o = observer(row['observer']),
          opts = solarOptions(row['options']),
          jd = (row['jd'] as num).toDouble();
      final a = solarAltitude(jd, o, options: opts), e = row['altitude'];
      expect(a.centerAltitudeRad, closeTo(e['centerAltitudeRad'], 1e-10));
      expect(a.apparentAltitudeRad, closeTo(e['apparentAltitudeRad'], 1e-10));
      expect(a.azimuthRad, closeTo(e['azimuthRad'], 1e-10));
      expect(a.slopeRadPerDay, closeTo(e['slopeRadPerDay'], 1e-8));
      final result = computeSolarRiseSetFast(jd, o, options: opts),
          expected = row['result'];
      expect(result.altitudeState, states[expected['altitudeState']]);
      instant(result.rise, expected['rise']);
      instant(result.set, expected['set']);
    }
  });
  test('all daily crossings and upper/lower transits match JS', () {
    for (final row in f['days']) {
      final start = (row['jd'] as num).toDouble();
      final a = bodyRiseSetForDay(
        SkyBody.values.byName(row['body']),
        start,
        observer(row['observer']),
        options: bodyOptions(row['options']),
      );
      final e = row['result'];
      expect(
        a.altitudeState,
        states[e['altitudeState']],
        reason: '${row['body']} ${row['observer']} ${row['options']}',
      );
      for (final pair in [
        (a.rises, e['rises']),
        (a.sets, e['sets']),
        (a.upperTransits, e['upperTransits']),
        (a.lowerTransits, e['lowerTransits']),
      ]) {
        expect(pair.$1.length, pair.$2.length);
        for (var i = 0; i < pair.$1.length; i++) {
          instant(pair.$1[i], pair.$2[i]);
          expect(pair.$1[i].jdUT1, greaterThanOrEqualTo(start));
          expect(pair.$1[i].jdUT1, lessThan(start + 1));
        }
      }
      expect(() => a.rises.clear(), throwsUnsupportedError);
    }
    final grazing = f['days'].last['result'];
    expect(grazing['rises'].length, 1);
    expect(grazing['sets'].length, 1);
    expect(
      (grazing['sets'][0]['jdUT1'] - grazing['rises'][0]['jdUT1']) * 86400,
      lessThan(600),
    );
  });
  test(
    'typed solar date selects local noon and invalid observers/axes reject',
    () {
      const o = Observer(longitudeDeg: 116.4, latitudeDeg: 39.9);
      final date = ZonedTime(
            year: 2026,
            month: 6,
            day: 21,
            hour: 1,
            offsetMinutes: 480,
          ),
          noon = ZonedTime(
            year: 2026,
            month: 6,
            day: 21,
            hour: 12,
            offsetMinutes: 480,
          );
      final a = solarRiseSetForDate(date, o),
          b = computeSolarRiseSetFast(noon.toJulianTime(), o);
      expect(a.rise!.jdUT1, b.rise!.jdUT1);
      expect(a.set!.jdUT1, b.set!.jdUT1);
      expect(
        () => bodyHorizontalPosition(
          SkyBody.moon,
          2451545,
          o,
          options: const BodyVisibilityOptions(
            apparent: ApparentOptions(frame: SkyFrame.j2000),
          ),
        ),
        throwsRangeError,
      );
      expect(
        () => solarAltitude(
          2451545,
          const Observer(longitudeDeg: 0, latitudeDeg: 91),
        ),
        throwsRangeError,
      );
      expect(
        () => hybridAtmosphericRefraction(double.nan),
        throwsArgumentError,
      );
      expect(
        () => bodyRiseSetForDay(
          SkyBody.sun,
          2451545,
          o,
          options: const BodyVisibilityOptions(horizonDegrees: 91),
        ),
        throwsRangeError,
      );
      expect(
        () => bodyHorizontalPosition(
          SkyBody.sun,
          2451545,
          const Observer(
            longitudeDeg: 0,
            latitudeDeg: 0,
            temperatureCelsius: -273,
          ),
        ),
        throwsRangeError,
      );
    },
  );
  test('refraction cutoff is not reported as a physical crossing', () {
    final result = bodyRiseSetForDay(
      SkyBody.sun,
      2460409.5,
      const Observer(longitudeDeg: 116.4, latitudeDeg: 39.9),
      options: const BodyVisibilityOptions(
        limb: DiscLimb.center,
        horizonDegrees: -0.8,
      ),
    );
    expect(result.rises, isEmpty);
    expect(result.sets, isEmpty);
    expect(result.altitudeState, AltitudeState.notFound);
  });
}
