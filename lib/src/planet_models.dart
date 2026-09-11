import 'dart:math' as math;
import 'accuracy.dart';
import 'ephemeris_types.dart';
import 'model_math.dart';
import 'sun_moon_ephemeris.dart' show earthState;
import 'planet_evaluator.dart';
import 'generated/planet_series.dart';
import 'generated/pluto_series.dart';

/// 计算行星日心几何位置和解析速度。
///
/// [jdTT] 为 TT 儒略日；输出采用 J2000 平黄道／平春分点，单位为 AU、AU/day。
/// 默认全量。冥王星代表其系统质心，推荐区间为 1600～2200 年；
/// 区间外使用粗略模型，不保证同等精度。
CartesianState planetHeliocentricState(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planet == Planet.pluto
    ? _pluto(jdTT, accuracy)
    : evaluatePlanetSeries(
        planetSeries[planet.name]!,
        planetPrefixes[planet.name]!,
        jdTT,
        accuracy,
      );

/// 返回 [planetHeliocentricState] 的三维位置，单位 AU。
List<double> planetHeliocentricPosition(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(planet, jdTT, accuracy: accuracy).position;

/// 将行星日心状态减去地球日心状态，返回地心几何状态。
///
/// 输入为 TT 儒略日；单位 AU、AU/day。未应用光行时与视位置修正。
CartesianState planetGeocentricState(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => combineStates(
  planetHeliocentricState(planet, jdTT, accuracy: accuracy),
  earthState(jdTT, accuracy: accuracy),
  -1,
);

/// Pluto is recommended only for 1600–2200. Outside this interval a coarse
/// fallback remains computable; this is not a precision wide-epoch ephemeris.
CartesianState _pluto(double jd, Accuracy accuracy) {
  validateJd(jd);
  final year = 2000 + (jd - j2000) / 365.25;
  if (year >= 1600 && year <= 2200) return _plutoNear(jd, accuracy);
  if (year <= 1590 || year >= 2210) return _plutoFar(jd);
  final near = _plutoNear(jd, accuracy), far = _plutoFar(jd);
  final x = year < 1600 ? (year - 1590) / 10 : (2210 - year) / 10;
  final weight = math.pow(x, 3) * (10 - 15 * x + 6 * x * x);
  final rate =
      30 * x * x * math.pow(1 - x, 2) * (year < 1600 ? 1 : -1) / (10 * 365.25);
  return CartesianState(
    List.generate(
      3,
      (k) => far.position[k] + weight * (near.position[k] - far.position[k]),
    ),
    List.generate(
      3,
      (k) =>
          far.velocity[k] +
          weight * (near.velocity[k] - far.velocity[k]) +
          rate * (near.position[k] - far.position[k]),
    ),
  );
}

CartesianState _plutoNear(double jd, Accuracy accuracy) {
  final x = (jd - plutoNearEpoch) / plutoNearScaleDays;
  final limit = switch (accuracy) {
    Accuracy.fast => 336,
    Accuracy.mid => 368,
    Accuracy.accurate => plutoNear[0].length,
  };
  final v = <double>[], rates = <double>[];
  for (final a in plutoNear) {
    var b1 = 0.0, b2 = 0.0, d1 = 0.0, d2 = 0.0;
    for (
      var i =
          (accuracy == Accuracy.accurate
              ? a.length
              : math.min(a.length, limit)) -
          1;
      i > 0;
      i--
    ) {
      final b = 2 * x * b1 - b2 + a[i], d = 2 * b1 + 2 * x * d1 - d2;
      b2 = b1;
      b1 = b;
      d2 = d1;
      d1 = d;
    }
    v.add(x * b1 - b2 + a[0]);
    rates.add((b1 + x * d1 - d2) / plutoNearScaleDays);
  }
  v[0] = v[0] + plutoNearPhase + plutoNearMotion * (jd - j2000) / 365250;
  rates[0] += plutoNearMotion / 365250;
  final s = sphericalState(v, rates);
  return CartesianState(
    applyMatrix(theoryToJ2000, s.position),
    applyMatrix(theoryToJ2000, s.velocity),
  );
}

CartesianState _plutoFar(double jd) {
  const scale = 2922000.0;
  final x = (jd - j2000) / scale, t = (jd - j2000) / 365250;
  final degree = plutoFallback.map((a) => a.length).reduce(math.max) - 1;
  final basis = List<double>.filled(degree + 1, 0),
      derivative = List<double>.filled(degree + 1, 0);
  basis[0] = 1;
  if (degree > 0) {
    basis[1] = x;
    derivative[1] = 1 / scale;
  }
  for (var n = 2; n <= degree; n++) {
    basis[n] = ((2 * n - 1) * x * basis[n - 1] - (n - 1) * basis[n - 2]) / n;
    derivative[n] =
        ((2 * n - 1) * (basis[n - 1] / scale + x * derivative[n - 1]) -
            (n - 1) * derivative[n - 2]) /
        n;
  }
  final v = [0.0, 0.0, 0.0], rates = [0.0, 0.0, 0.0];
  for (var c = 0; c < 3; c++) {
    for (var n = 0; n < plutoFallback[c].length; n++) {
      var value = 0.0, rate = 0.0;
      final a = plutoFallback[c][n];
      for (var i = 0; i < a.length; i += 3) {
        final arg = a[i + 1] + a[i + 2] * t;
        value += a[i] * math.cos(arg);
        rate -= a[i] * a[i + 2] * math.sin(arg) / 365250;
      }
      v[c] += basis[n] * value;
      rates[c] += derivative[n] * value + basis[n] * rate;
    }
  }
  v[0] = math.atan2(math.sin(v[0]), math.cos(v[0]));
  final s = sphericalState(v, rates);
  return CartesianState(
    applyMatrix(theoryToJ2000, s.position),
    applyMatrix(theoryToJ2000, s.velocity),
  );
}

CartesianState mercuryHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.mercury, jdTT, accuracy: accuracy);
List<double> mercuryHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => mercuryHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState venusHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.venus, jdTT, accuracy: accuracy);
List<double> venusHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => venusHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState marsHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.mars, jdTT, accuracy: accuracy);
List<double> marsHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => marsHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState jupiterHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.jupiter, jdTT, accuracy: accuracy);
List<double> jupiterHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => jupiterHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState saturnHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.saturn, jdTT, accuracy: accuracy);
List<double> saturnHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => saturnHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState uranusHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.uranus, jdTT, accuracy: accuracy);
List<double> uranusHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => uranusHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState neptuneHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.neptune, jdTT, accuracy: accuracy);
List<double> neptuneHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => neptuneHeliocentricState(jdTT, accuracy: accuracy).position;
CartesianState plutoHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.pluto, jdTT, accuracy: accuracy);
List<double> plutoHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => plutoHeliocentricState(jdTT, accuracy: accuracy).position;
List<double> planetGeocentricPosition(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetGeocentricState(planet, jdTT, accuracy: accuracy).position;
