// Port of phenomena.js. MPL-2.0.
import 'dart:math' as math;
import 'apparent.dart';
import 'disc_radii.dart';
import 'ephemeris.dart';
import 'sky_math.dart';

/// 天体相位角、照明比例与视圆面等观测量。
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

/// 月球照明与盈亏结果；照明比例不是月龄的线性比例。
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

/// 计算天体相位与圆面信息，输入为 TT 儒略日。
///
/// 采用本库视位置和简化圆面模型，不含地形或形状细节。
///
/// 太阳的相位角与照明比例返回 null；不包含星等模型。
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

/// 计算月球照明比例与盈亏，输入为 TT 儒略日。
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
