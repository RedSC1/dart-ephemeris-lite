// Port of apparent.js. MPL-2.0. No barycentric solar reflex, EOP,
// multi-body deflection or Shapiro delay. TT approximates TDB.
import 'dart:math' as math;
import 'accuracy.dart';
import 'coordinates.dart';
import 'ephemeris.dart';
import 'sky_math.dart';

const lightTimeDaysPerAu = auKm / 299792.458 / 86400;
const _rateStep = 0.0005;

enum SkyBody {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
}

/// j2000 means mean J2000 ecliptic/equinox, not ICRS.
enum SkyFrame { j2000, meanOfDate, trueOfDate }

class ApparentOptions {
  final SkyFrame frame;
  final Accuracy accuracy;
  final bool lightTime, aberration, solarDeflection;
  const ApparentOptions({
    this.frame = SkyFrame.trueOfDate,
    this.accuracy = Accuracy.accurate,
    this.lightTime = true,
    this.aberration = true,
    this.solarDeflection = true,
  });
}

class ApparentPosition {
  final SkyBody body;
  final double jdTT,
      longitudeDeg,
      latitudeDeg,
      distanceAu,
      rightAscensionDeg,
      declinationDeg,
      lightTimeDays;
  final SkyFrame frame;
  final List<double> eclipticPositionAu, equatorialPositionAu;
  ApparentPosition({
    required this.body,
    required this.jdTT,
    required this.frame,
    required this.longitudeDeg,
    required this.latitudeDeg,
    required this.distanceAu,
    required this.rightAscensionDeg,
    required this.declinationDeg,
    required this.lightTimeDays,
    required List<double> eclipticPositionAu,
    required List<double> equatorialPositionAu,
  }) : eclipticPositionAu = List.unmodifiable(eclipticPositionAu),
       equatorialPositionAu = List.unmodifiable(equatorialPositionAu);
}

class ApparentState extends ApparentPosition {
  final double longitudeSpeedDegPerDay,
      latitudeSpeedDegPerDay,
      rightAscensionSpeedDegPerDay,
      declinationSpeedDegPerDay,
      distanceSpeedAuPerDay;
  final List<double> eclipticVelocityAuPerDay, equatorialVelocityAuPerDay;
  ApparentState(
    ApparentPosition p, {
    required this.longitudeSpeedDegPerDay,
    required this.latitudeSpeedDegPerDay,
    required this.rightAscensionSpeedDegPerDay,
    required this.declinationSpeedDegPerDay,
    required this.distanceSpeedAuPerDay,
    required List<double> eclipticVelocityAuPerDay,
    required List<double> equatorialVelocityAuPerDay,
  }) : eclipticVelocityAuPerDay = List.unmodifiable(eclipticVelocityAuPerDay),
       equatorialVelocityAuPerDay = List.unmodifiable(
         equatorialVelocityAuPerDay,
       ),
       super(
         body: p.body,
         jdTT: p.jdTT,
         frame: p.frame,
         longitudeDeg: p.longitudeDeg,
         latitudeDeg: p.latitudeDeg,
         distanceAu: p.distanceAu,
         rightAscensionDeg: p.rightAscensionDeg,
         declinationDeg: p.declinationDeg,
         lightTimeDays: p.lightTimeDays,
         eclipticPositionAu: p.eclipticPositionAu,
         equatorialPositionAu: p.equatorialPositionAu,
       );
}

CartesianState _heliocentric(SkyBody body, double jd, Accuracy accuracy) {
  if (body == SkyBody.sun) return CartesianState([0, 0, 0], [0, 0, 0]);
  if (body == SkyBody.moon) {
    return moonHeliocentricState(jd, accuracy: accuracy);
  }
  return planetHeliocentricState(
    Planet.values.byName(body.name),
    jd,
    accuracy: accuracy,
  );
}

List<double> _aberrate(List<double> position, List<double> velocity) {
  final distance = norm(position),
      p = scale(position, 1 / distance),
      beta = scale(velocity, lightTimeDaysPerAu);
  final inverseGamma = math.sqrt(1 - dot(beta, beta)), product = dot(p, beta);
  final direction = add(
    scale(p, inverseGamma),
    scale(beta, 1 + product / (1 + inverseGamma)),
  );
  return scale(unit(direction), distance);
}

List<double> _deflect(
  List<double> position,
  List<double> earth,
  List<double> target,
) {
  final distance = norm(position),
      em = norm(earth),
      p = unit(position),
      e = unit(earth),
      q = unit(target);
  final limb = 695700 / auKm / em,
      denominator = math.max(1 + dot(q, e), limb * limb / 2),
      weight = 1.97412574336e-8 / em / denominator;
  return scale(unit(add(p, scale(cross(p, cross(e, q)), weight))), distance);
}

/// Geocentric apparent position. Input TT JD, angles degrees, distances AU.
ApparentPosition apparentBodyPosition(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) {
  if (!jdTT.isFinite) throw ArgumentError.value(jdTT, 'jdTT');
  final earth = earthState(jdTT, accuracy: options.accuracy);
  var target = _heliocentric(body, jdTT, options.accuracy),
      position = sub(target.position, earth.position),
      lightTime = 0.0;
  if (options.lightTime) {
    var converged = false;
    for (var i = 0; i < 12; i++) {
      final next = norm(position) * lightTimeDaysPerAu,
          change = (next - lightTime).abs();
      lightTime = next;
      final emission = jdTT - lightTime;
      target = _heliocentric(body, emission, options.accuracy);
      final remainder = (jdTT - emission) - lightTime;
      target = CartesianState(
        add(target.position, scale(target.velocity, remainder)),
        target.velocity,
      );
      position = sub(target.position, earth.position);
      if (change < 1e-11) {
        converged = true;
        break;
      }
    }
    if (!converged) throw StateError('Light-time iteration did not converge');
  }
  if (body != SkyBody.sun && options.solarDeflection) {
    position = _deflect(position, earth.position, target.position);
  }
  if (options.aberration) {
    position = _aberrate(position, earth.velocity);
  }
  final nutation = iau2000bNutation(jdTT);
  var ecliptic = position, obliquity = 84381.406 * arcsecToRad;
  if (options.frame != SkyFrame.j2000) {
    ecliptic = transform(meanEclipticOfDateMatrixState(jdTT).matrix, position);
    obliquity = nutation.meanObliquity;
    if (options.frame == SkyFrame.trueOfDate) {
      ecliptic = rotateZ(ecliptic, nutation.dpsi);
      obliquity = nutation.trueObliquity;
    }
  }
  final eq = rotateX(ecliptic, obliquity),
      es = spherical(ecliptic),
      qs = spherical(eq);
  return ApparentPosition(
    body: body,
    jdTT: jdTT,
    frame: options.frame,
    longitudeDeg: es.longitudeDeg,
    latitudeDeg: es.latitudeDeg,
    distanceAu: es.distanceAu,
    rightAscensionDeg: qs.longitudeDeg,
    declinationDeg: qs.latitudeDeg,
    lightTimeDays: lightTime,
    eclipticPositionAu: ecliptic,
    equatorialPositionAu: eq,
  );
}

/// Central-difference rates of the complete apparent-position chain.
/// Unlike geometric state velocities these are not analytic derivatives.
ApparentState apparentBodyState(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) {
  final current = apparentBodyPosition(body, jdTT, options: options),
      before = apparentBodyPosition(body, jdTT - _rateStep, options: options),
      after = apparentBodyPosition(body, jdTT + _rateStep, options: options);
  final dt = (jdTT + _rateStep) - (jdTT - _rateStep);
  return ApparentState(
    current,
    longitudeSpeedDegPerDay:
        signedDeg(after.longitudeDeg - before.longitudeDeg) / dt,
    latitudeSpeedDegPerDay: (after.latitudeDeg - before.latitudeDeg) / dt,
    rightAscensionSpeedDegPerDay:
        signedDeg(after.rightAscensionDeg - before.rightAscensionDeg) / dt,
    declinationSpeedDegPerDay:
        (after.declinationDeg - before.declinationDeg) / dt,
    distanceSpeedAuPerDay: (after.distanceAu - before.distanceAu) / dt,
    eclipticVelocityAuPerDay: scale(
      sub(after.eclipticPositionAu, before.eclipticPositionAu),
      1 / dt,
    ),
    equatorialVelocityAuPerDay: scale(
      sub(after.equatorialPositionAu, before.equatorialPositionAu),
      1 / dt,
    ),
  );
}
