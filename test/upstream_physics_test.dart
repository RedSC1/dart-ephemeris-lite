// Model-independent invariants and frozen C++ controls from upstream JS tests.
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:ephemeris_lite/src/sky_math.dart' as v;
import 'package:test/test.dart';

void main() {
  test('Denver sunrise/set independent C++ controls, all limb options', () {
    final variants = [
      (
        const SolarVisibilityOptions(),
        2460409.022335537709,
        2460409.563677349128,
        8.0,
        10.0,
      ),
      (
        const SolarVisibilityOptions(refraction: false),
        2460409.024388565216,
        2460409.561618985143,
        .25,
        .25,
      ),
      (
        const SolarVisibilityOptions(limb: DiscLimb.center, refraction: false),
        2460409.025327078679,
        2460409.562713850470,
        4.0,
        200.0,
      ),
      (
        const SolarVisibilityOptions(limb: DiscLimb.lower, refraction: false),
        2460409.026337929536,
        2460409.559664948378,
        .25,
        .25,
      ),
      (
        const SolarVisibilityOptions(fixedDiscSize: true, refraction: false),
        2460409.024387161247,
        2460409.561620542314,
        .25,
        .25,
      ),
    ];
    for (final r in variants) {
      final result = solarRiseSetForDate(
        ZonedTime(year: 2024, month: 4, day: 8, offsetMinutes: -360),
        Observer(
          longitudeDeg: -104.9903,
          latitudeDeg: 39.7392,
          heightMeters: 1609,
        ),
        options: r.$1,
      );
      expect(result.altitudeState, AltitudeState.crosses);
      expect((result.rise!.jdUT1 - r.$2) * 86400, closeTo(0, r.$4));
      expect((result.set!.jdUT1 - r.$3) * 86400, closeTo(0, r.$5));
      expect(result.rise!.toZonedTime(-360).day, 8);
      expect(result.set!.toZonedTime(-360).day, 8);
    }
    expect(
      hybridAtmosphericRefraction(
        15 * math.pi / 180,
        pressureMbar: 1010,
        temperatureCelsius: 10,
      ),
      closeTo(1.05132761341894705e-3, 2e-15),
    );
    expect(hybridAtmosphericRefraction(-1.01 * math.pi / 180), 0);
  });
  test('apparent frames follow precession/nutation and preserve distances', () {
    for (final body in SkyBody.values) {
      const t = 2469807.5;
      final fixed = apparentBodyPosition(
        body,
        t,
        options: const ApparentOptions(frame: SkyFrame.j2000),
      );
      final mean = apparentBodyPosition(
        body,
        t,
        options: const ApparentOptions(frame: SkyFrame.meanOfDate),
      );
      final apparent = apparentBodyPosition(body, t);
      final expected = v.transform(
        meanEclipticOfDateMatrixState(t).matrix,
        fixed.eclipticPositionAu,
      );
      for (var i = 0; i < 3; i++) {
        expect(mean.eclipticPositionAu[i], closeTo(expected[i], 1e-13));
      }
      expect(
        v.signedDeg(apparent.longitudeDeg - mean.longitudeDeg),
        closeTo(iau2000bNutation(t).dpsi * 180 / math.pi, 1e-10),
      );
      expect(apparent.latitudeDeg, closeTo(mean.latitudeDeg, 1e-10));
      expect(fixed.distanceAu, closeTo(mean.distanceAu, 1e-12));
      expect(
        v.signedDeg(mean.longitudeDeg - fixed.longitudeDeg).abs(),
        greaterThan(.5),
      );
    }
  });
  test('turning corrections off recovers geometric centers and units', () {
    for (final body in SkyBody.values) {
      final p = apparentBodyPosition(
        body,
        j2000,
        options: const ApparentOptions(
          frame: SkyFrame.j2000,
          lightTime: false,
          aberration: false,
          solarDeflection: false,
        ),
      );
      final raw = body == SkyBody.moon
          ? moonPosition(j2000).map((x) => x / auKm).toList()
          : body == SkyBody.sun
          ? sunGeocentricPosition(j2000)
          : planetGeocentricPosition(Planet.values.byName(body.name), j2000);
      for (var i = 0; i < 3; i++) {
        expect(p.eclipticPositionAu[i], closeTo(raw[i], 2e-14));
      }
      expect(v.norm(p.equatorialPositionAu), closeTo(v.norm(raw), 2e-13));
      expect(p.lightTimeDays, 0);
      final a = apparentBodyPosition(body, 2460409.25);
      expect(
        a.lightTimeDays,
        closeTo(a.distanceAu * lightTimeDaysPerAu, 1e-11),
      );
    }
  });
  test(
    'all apparent rates differentiate changing frames through longitude wrap',
    () {
      const t = 2460390.629, h = .002;
      for (final frame in SkyFrame.values) {
        for (final body in [
          SkyBody.sun,
          SkyBody.moon,
          SkyBody.mercury,
          SkyBody.neptune,
        ]) {
          final options = ApparentOptions(frame: frame),
              p = apparentBodyState(body, t, options: options),
              before = apparentBodyPosition(body, t - h, options: options),
              after = apparentBodyPosition(body, t + h, options: options),
              dt = (t + h) - (t - h);
          expect(
            p.longitudeSpeedDegPerDay,
            closeTo(
              v.signedDeg(after.longitudeDeg - before.longitudeDeg) / dt,
              2e-5,
            ),
          );
          expect(
            p.rightAscensionSpeedDegPerDay,
            closeTo(
              v.signedDeg(after.rightAscensionDeg - before.rightAscensionDeg) /
                  dt,
              2e-5,
            ),
          );
          for (var i = 0; i < 3; i++) {
            expect(
              p.eclipticVelocityAuPerDay[i],
              closeTo(
                (after.eclipticPositionAu[i] - before.eclipticPositionAu[i]) /
                    dt,
                1e-7,
              ),
            );
          }
        }
      }
    },
  );
  test('C++ Swiss equation-of-time independent controls', () {
    for (final r in [
      [2451545.0, -197.11531440430917],
      [2460311.0, -198.9342282623329],
      [2460409.0, -102.17101941988405],
      [2460676.5, -206.5203796885362],
    ]) {
      final result = equationOfTime(r[0]);
      expect(result.equationSeconds, closeTo(r[1], .02));
      expect(
        result.equationDays * 86400,
        closeTo(result.equationSeconds, 1e-12),
      );
    }
  });
  test(
    'event model angular derivatives independently match numerical slopes',
    () {
      double wrap(double x) => (x + math.pi) % (2 * math.pi) - math.pi;
      for (final evaluator in [solarLongitudeState, elongationState]) {
        for (final jd in [2451545.0, 2415020.5, 3182029.5]) {
          const h = .001;
          expect(
            evaluator(jd).rate,
            closeTo(
              wrap(evaluator(jd + h).value - evaluator(jd - h).value) / (2 * h),
              1e-6,
            ),
          );
        }
      }
      for (final year in [
        -6000,
        -2000,
        1000,
        1100,
        1200,
        1499,
        1500,
        1550,
        1600,
        1601,
        2000,
        2199,
        2200,
        2250,
        2300,
        2301,
        2800,
        2900,
        3000,
        6000,
        10000,
      ]) {
        final jd = j2000 + (year - 2000) * 365.25;
        const h = .002;
        for (final drift in [false, true]) {
          final before = lowSolarLongitudeState(jd - h, withDrift: drift),
              after = lowSolarLongitudeState(jd + h, withDrift: drift);
          expect(
            lowSolarLongitudeState(jd, withDrift: drift).rate,
            closeTo(wrap(after.value - before.value) / (2 * h), 2e-6),
          );
          final b = lowElongationState(jd - h, withDrift: drift),
              a = lowElongationState(jd + h, withDrift: drift);
          expect(
            lowElongationState(jd, withDrift: drift).rate,
            closeTo(wrap(a.value - b.value) / (2 * h), 2e-6),
          );
        }
      }
    },
  );
}
