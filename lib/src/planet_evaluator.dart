import 'dart:math' as math;
import 'accuracy.dart';
import 'ephemeris_types.dart';
import 'model_math.dart';

CartesianState evaluatePlanetSeries(
  List<List<List<double>>> groups,
  Map<String, List<List<int>?>> prefixes,
  double jd,
  Accuracy accuracy, {
  bool direction = false,
  List<List<int>?>? prefixOverride,
}) {
  validateJd(jd);
  final limits =
      prefixOverride ??
      (accuracy == Accuracy.accurate ? null : prefixes[accuracy.name]);
  final t = (jd - j2000) / 365250;
  final degree = groups.map((axis) => axis.length).reduce(math.max) - 1;
  final basis = List<double>.filled(degree + 1, 0),
      derivative = List<double>.filled(degree + 1, 0);
  basis[0] = 1;
  for (var n = 1; n <= degree; n++) {
    basis[n] = basis[n - 1] * t;
    derivative[n] = n * basis[n - 1] / 365250;
  }
  final values = [0.0, 0.0, direction ? 1.0 : 0.0], rates = [0.0, 0.0, 0.0];
  for (var c = 0; c < (direction ? 2 : 3); c++) {
    final counts = limits?[c];
    for (var n = 0; n < groups[c].length; n++) {
      final rows = groups[c][n];
      final end = counts == null
          ? rows.length
          : math.min((n < counts.length ? counts[n] : 0) * 3, rows.length);
      var value = 0.0, rate = 0.0;
      for (var i = 0; i < end; i += 3) {
        final a = rows[i], w = rows[i + 2], arg = rows[i + 1] + w * t;
        final term = a * math.cos(arg);
        if (counts == null) {
          value += term;
          rate -= a * w * math.sin(arg) / 365250;
        } else {
          values[c] += basis[n] * term;
          rates[c] +=
              derivative[n] * term - basis[n] * a * w * math.sin(arg) / 365250;
        }
      }
      if (counts == null) {
        values[c] += basis[n] * value;
        rates[c] += derivative[n] * value + basis[n] * rate;
      }
    }
  }
  values[0] = math.atan2(math.sin(values[0]), math.cos(values[0]));
  final native = sphericalState(values, rates);
  final p = applyMatrix(theoryToJ2000, native.position),
      v = applyMatrix(theoryToJ2000, native.velocity);
  if (!direction) return CartesianState(p, v);
  final radius = math.sqrt(p.fold(0.0, (s, x) => s + x * x));
  var radialRate = 0.0;
  for (var k = 0; k < 3; k++) {
    radialRate += p[k] * v[k];
  }
  radialRate /= radius;
  return CartesianState(
    p.map((x) => x / radius).toList(),
    List.generate(
      3,
      (k) => v[k] / radius - p[k] * radialRate / (radius * radius),
    ),
  );
}
