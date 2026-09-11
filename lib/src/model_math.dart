import 'dart:math' as math;
import 'ephemeris_types.dart';

const theoryToJ2000 = [
  [0.9999999999999803, 1.9786988844634012e-7, 2.0200940272138296e-9],
  [-1.978698884606213e-7, 0.9999999999999803, 7.069560215011705e-9],
  [-2.020092628360702e-9, -7.0695604925674616e-9, 1.0],
];
List<double> applyMatrix(List<List<double>> matrix, List<double> v) =>
    matrix.map((row) => row[0] * v[0] + row[1] * v[1] + row[2] * v[2]).toList();
CartesianState sphericalState(List<double> p, List<double> v) {
  final l = p[0], b = p[1], r = p[2], dl = v[0], db = v[1], dr = v[2];
  final cl = math.cos(l), sl = math.sin(l), cb = math.cos(b), sb = math.sin(b);
  return CartesianState(
    [r * cb * cl, r * cb * sl, r * sb],
    [
      dr * cb * cl - r * sb * db * cl - r * cb * sl * dl,
      dr * cb * sl - r * sb * db * sl + r * cb * cl * dl,
      dr * sb + r * cb * db,
    ],
  );
}

void validateJd(double jd) {
  if (!jd.isFinite) throw ArgumentError.value(jd, 'jdTT');
}

CartesianState combineStates(
  CartesianState a,
  CartesianState b,
  double scale,
) => CartesianState(
  List.generate(3, (i) => a.position[i] + b.position[i] * scale),
  List.generate(3, (i) => a.velocity[i] + b.velocity[i] * scale),
);
({double value, double rate}) polynomialState(
  List<double> coefficients,
  double x,
  double xRate,
) {
  var value = 0.0, rate = 0.0;
  for (var i = coefficients.length - 1; i >= 0; i--) {
    rate = rate * x + value;
    value = value * x + coefficients[i];
  }
  return (value: value, rate: rate * xRate);
}
