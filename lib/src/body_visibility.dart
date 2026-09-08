// Port of body-visibility.js. MPL-2.0.
import 'dart:math' as math;
import 'apparent.dart';
import 'ephemeris.dart';
import 'disc_radii.dart';
import 'event_search.dart';
import 'observer.dart';
import 'sky_math.dart';
import 'solar_time.dart';
import 'solar_visibility.dart';
import 'time.dart';

class BodyVisibilityOptions {
  final DiscLimb limb;
  final bool refraction;
  final double horizonDegrees;
  final ApparentOptions apparent;
  const BodyVisibilityOptions({
    this.limb = DiscLimb.upper,
    this.refraction = true,
    this.horizonDegrees = 0,
    this.apparent = const ApparentOptions(),
  });
}

class BodyHorizontalPosition {
  final SkyBody body;
  final double jdUT1,
      jdTT,
      azimuthDeg,
      geometricAltitudeDeg,
      apparentAltitudeDeg,
      rightAscensionDeg,
      declinationDeg,
      distanceAu,
      hourAngleDeg;
  const BodyHorizontalPosition._(
    this.body,
    this.jdUT1,
    this.jdTT,
    this.azimuthDeg,
    this.geometricAltitudeDeg,
    this.apparentAltitudeDeg,
    this.rightAscensionDeg,
    this.declinationDeg,
    this.distanceAu,
    this.hourAngleDeg,
  );
  Map<String, Object> toJson() => {
    'body': body.name,
    'jdUT1': jdUT1,
    'jdTT': jdTT,
    'azimuthDeg': azimuthDeg,
    'geometricAltitudeDeg': geometricAltitudeDeg,
    'apparentAltitudeDeg': apparentAltitudeDeg,
    'rightAscensionDeg': rightAscensionDeg,
    'declinationDeg': declinationDeg,
    'distanceAu': distanceAu,
    'hourAngleDeg': hourAngleDeg,
  };
}

class BodyRiseSetResult {
  final SkyBody body;
  final double dayStartUT1, dayEndUT1;
  final AltitudeState altitudeState;
  final List<JulianTime> rises, sets, upperTransits, lowerTransits;
  final DiscLimb limb;
  final bool refraction;
  BodyRiseSetResult._(
    this.body,
    this.dayStartUT1,
    this.dayEndUT1,
    this.altitudeState,
    List<JulianTime> rises,
    List<JulianTime> sets,
    List<JulianTime> upper,
    List<JulianTime> lower,
    this.limb,
    this.refraction,
  ) : rises = List.unmodifiable(rises),
      sets = List.unmodifiable(sets),
      upperTransits = List.unmodifiable(upper),
      lowerTransits = List.unmodifiable(lower);
}

/// Topocentric true-of-date coordinates; azimuth is north through east.
/// No terrain, horizon dip, polar motion or diurnal aberration is included.
BodyHorizontalPosition bodyHorizontalPosition(
  SkyBody body,
  double jdUT1,
  Observer observer, {
  BodyVisibilityOptions options = const BodyVisibilityOptions(),
}) {
  if (!jdUT1.isFinite) {
    throw ArgumentError('jdUT1 must be finite');
  }
  validateVisibilityObserver(observer);
  if (options.apparent.frame != SkyFrame.trueOfDate) {
    throw RangeError('horizontal coordinates require true-of-date axes');
  }
  final tt = ut1ToTt(jdUT1),
      position = apparentBodyPosition(body, tt, options: options.apparent);
  final sidereal =
          (greenwichSiderealTime(jdUT1, jdTT: tt) + observer.longitudeDeg) /
          rad,
      lat = observer.latitudeDeg / rad;
  final sinLat = math.sin(lat),
      cosLat = math.cos(lat),
      n = 6378137 / math.sqrt(1 - 6.69437999014e-3 * sinLat * sinLat);
  final rho = (n + observer.heightMeters) * cosLat / (auKm * 1000),
      z =
          (n * (1 - 6.69437999014e-3) + observer.heightMeters) *
          sinLat /
          (auKm * 1000);
  final top = spherical(
    sub(position.equatorialPositionAu, [
      rho * math.cos(sidereal),
      rho * math.sin(sidereal),
      z,
    ]),
  );
  final hour = signedDeg(sidereal * rad - top.longitudeDeg),
      h = hour / rad,
      dec = top.latitudeDeg / rad;
  final altitude = math.asin(
    (sinLat * math.sin(dec) + cosLat * math.cos(dec) * math.cos(h)).clamp(
      -1,
      1,
    ),
  );
  final azimuth = math.atan2(
    -math.cos(dec) * math.sin(h),
    math.sin(dec) * cosLat - math.cos(dec) * sinLat * math.cos(h),
  );
  final refraction = options.refraction
      ? hybridAtmosphericRefraction(
          altitude,
          pressureMbar: observer.pressureMbar,
          temperatureCelsius: observer.temperatureCelsius,
        )
      : 0;
  return BodyHorizontalPosition._(
    body,
    jdUT1,
    tt,
    normDeg(azimuth * rad),
    altitude * rad,
    (altitude + refraction) * rad,
    top.longitudeDeg,
    top.latitudeDeg,
    top.distanceAu,
    hour,
  );
}

/// All crossings in the exact interval [dayStartUT1,dayStartUT1+1).
/// No implicit timezone or longitude-based day is inferred.
BodyRiseSetResult bodyRiseSetForDay(
  SkyBody body,
  double dayStartUT1,
  Observer observer, {
  BodyVisibilityOptions options = const BodyVisibilityOptions(),
}) {
  if (!dayStartUT1.isFinite) {
    throw ArgumentError('dayStartUT1 must be finite');
  }
  validateVisibilityObserver(observer);
  if (!options.horizonDegrees.isFinite || options.horizonDegrees.abs() > 90) {
    throw RangeError('horizonDegrees must be within ±90');
  }
  final end = dayStartUT1 + 1,
      sign = options.limb == DiscLimb.upper
          ? 1
          : options.limb == DiscLimb.lower
          ? -1
          : 0;
  final cache = <double, BodyHorizontalPosition>{};
  BodyHorizontalPosition at(double t) => cache.putIfAbsent(
    t,
    () => bodyHorizontalPosition(body, t, observer, options: options),
  );
  double altitude(double t) {
    final p = at(t),
        radius =
            math.asin(
              (bodyDiscRadiusKm[body]! / auKm / p.distanceAu).clamp(-1, 1),
            ) *
            rad;
    final geometric = p.geometricAltitudeDeg + sign * radius;
    final refraction = options.refraction
        ? hybridAtmosphericRefraction(
                geometric / rad,
                pressureMbar: observer.pressureMbar,
                temperatureCelsius: observer.temperatureCelsius,
              ) *
              rad
        : 0;
    return geometric + refraction - options.horizonDegrees;
  }

  final samples = List.generate(145, (i) {
    final t = dayStartUT1 + i / 144;
    return (time: t, value: altitude(t));
  });
  final extrema = <({double time, double value})>[];
  for (var i = 1; i < 144; i++) {
    final a = samples[i - 1], b = samples[i], c = samples[i + 1];
    if ((b.value - a.value) * (c.value - b.value) >= 0) {
      continue;
    }
    final sign = b.value > a.value ? 1 : -1;
    var left = a.time, right = c.time;
    for (var j = 0; j < 40 && right - left > 1e-8; j++) {
      final x = left + (right - left) / 3, y = right - (right - left) / 3;
      if (altitude(x) * sign < altitude(y) * sign) {
        left = x;
      } else {
        right = y;
      }
    }
    final t = (left + right) / 2;
    extrema.add((time: t, value: altitude(t)));
  }
  final grid = [...samples, ...extrema]
    ..sort((a, b) => a.time.compareTo(b.time));
  final rises = <double>[], sets = <double>[];
  for (var i = 0; i < grid.length - 1; i++) {
    if (grid[i + 1].time - grid[i].time <= 1e-8) {
      continue;
    }
    final roots = searchCrossings(
      altitude,
      grid[i].time,
      grid[i + 1].time,
      stepDays: 1 / 144,
    );
    for (final root in roots) {
      if (altitude(root.time).abs() > 1e-4) {
        continue;
      }
      final list = altitude(root.time + 1e-5) > altitude(root.time - 1e-5)
          ? rises
          : sets;
      if (list.isEmpty || root.time - list.last > 1e-7) {
        list.add(root.time);
      }
    }
  }
  final transits = searchCrossings(
    (t) => math.sin(at(t).hourAngleDeg / rad),
    dayStartUT1,
    end,
    stepDays: 1 / 24,
  );
  final min = grid.map((p) => p.value).reduce(math.min),
      max = grid.map((p) => p.value).reduce(math.max);
  final state = rises.isNotEmpty || sets.isNotEmpty
      ? AltitudeState.crosses
      : extrema.any((p) => p.value.abs() < 1e-5)
      ? AltitudeState.tangent
      : min > 0
      ? AltitudeState.alwaysAbove
      : max < 0
      ? AltitudeState.alwaysBelow
      : AltitudeState.notFound;
  return BodyRiseSetResult._(
    body,
    dayStartUT1,
    end,
    state,
    rises.map(JulianTime.fromUT1).toList(),
    sets.map(JulianTime.fromUT1).toList(),
    transits
        .where((p) => math.cos(at(p.time).hourAngleDeg / rad) > 0)
        .map((p) => JulianTime.fromUT1(p.time))
        .toList(),
    transits
        .where((p) => math.cos(at(p.time).hourAngleDeg / rad) < 0)
        .map((p) => JulianTime.fromUT1(p.time))
        .toList(),
    options.limb,
    options.refraction,
  );
}
