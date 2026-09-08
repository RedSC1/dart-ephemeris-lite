// Port of phenomena.js. MPL-2.0.
import 'dart:math' as math;
import 'apparent.dart';
import 'disc_radii.dart';
import 'ephemeris.dart';
import 'sky_math.dart';

class BodyPhenomena {
  final SkyBody body;
  final double jdTT,
      distanceAu,
      solarElongationDeg,
      apparentDiameterArcsec,
      horizontalParallaxDeg;
  final double? phaseAngleDeg, illuminatedFraction;
  const BodyPhenomena({
    required this.body,
    required this.jdTT,
    required this.distanceAu,
    required this.phaseAngleDeg,
    required this.illuminatedFraction,
    required this.solarElongationDeg,
    required this.apparentDiameterArcsec,
    required this.horizontalParallaxDeg,
  });
  Map<String, Object?> toJson() => {
    'body': body.name,
    'jdTT': jdTT,
    'distanceAu': distanceAu,
    'phaseAngleDeg': phaseAngleDeg,
    'illuminatedFraction': illuminatedFraction,
    'solarElongationDeg': solarElongationDeg,
    'apparentDiameterArcsec': apparentDiameterArcsec,
    'horizontalParallaxDeg': horizontalParallaxDeg,
  };
}

class MoonIllumination extends BodyPhenomena {
  final double phaseCycle;
  final bool waxing;
  MoonIllumination._(BodyPhenomena p, this.phaseCycle)
    : waxing = phaseCycle < 0.5,
      super(
        body: p.body,
        jdTT: p.jdTT,
        distanceAu: p.distanceAu,
        phaseAngleDeg: p.phaseAngleDeg,
        illuminatedFraction: p.illuminatedFraction,
        solarElongationDeg: p.solarElongationDeg,
        apparentDiameterArcsec: p.apparentDiameterArcsec,
        horizontalParallaxDeg: p.horizontalParallaxDeg,
      );
  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'phaseCycle': phaseCycle,
    'waxing': waxing,
  };
}

/// Geocentric disc/illumination geometry, without a magnitude or terrain model.
/// The Sun has null phase angle and illuminated fraction.
BodyPhenomena bodyPhenomena(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) {
  final g = apparentGeometry(body, jdTT, options: options),
      p = apparentBodyPosition(body, jdTT, options: options);
  final sun = body == SkyBody.sun
      ? p
      : apparentBodyPosition(SkyBody.sun, jdTT, options: options);
  final elongation = body == SkyBody.sun
      ? 0.0
      : math.acos(
              dot(
                unit(p.equatorialPositionAu),
                unit(sun.equatorialPositionAu),
              ).clamp(-1, 1),
            ) *
            rad;
  final cosine = body == SkyBody.sun
      ? null
      : dot(unit(g.target), unit(g.astrometric)).clamp(-1.0, 1.0);
  return BodyPhenomena(
    body: body,
    jdTT: jdTT,
    distanceAu: p.distanceAu,
    phaseAngleDeg: cosine == null ? null : math.acos(cosine) * rad,
    illuminatedFraction: cosine == null ? null : (1 + cosine) / 2,
    solarElongationDeg: elongation,
    apparentDiameterArcsec:
        2 *
        math.asin(
          (bodyDiscRadiusKm[body]! / auKm / p.distanceAu).clamp(-1, 1),
        ) *
        rad *
        3600,
    horizontalParallaxDeg:
        math.asin((6378.137 / auKm / p.distanceAu).clamp(-1, 1)) * rad,
  );
}

MoonIllumination moonIllumination(
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) {
  final p = bodyPhenomena(SkyBody.moon, jdTT, options: options);
  final date = ApparentOptions(
    frame: SkyFrame.trueOfDate,
    accuracy: options.accuracy,
    lightTime: options.lightTime,
    aberration: options.aberration,
    solarDeflection: options.solarDeflection,
  );
  final moon = apparentBodyPosition(SkyBody.moon, jdTT, options: date),
      sun = apparentBodyPosition(SkyBody.sun, jdTT, options: date);
  return MoonIllumination._(
    p,
    normDeg(moon.longitudeDeg - sun.longitudeDeg) / 360,
  );
}
