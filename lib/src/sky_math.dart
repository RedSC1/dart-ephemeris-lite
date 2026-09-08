import 'dart:math' as math;

const rad = 180 / math.pi;
double normDeg(double x) => ((x.remainder(360)) + 360).remainder(360);
double signedDeg(double x) => normDeg(x + 180) - 180;
double dot(List<double> a, List<double> b) {
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

List<double> add(List<double> a, List<double> b) =>
    List.generate(3, (i) => a[i] + b[i]);
List<double> sub(List<double> a, List<double> b) =>
    List.generate(3, (i) => a[i] - b[i]);
List<double> scale(List<double> a, double s) => a.map((v) => v * s).toList();
double norm(List<double> a) => math.sqrt(dot(a, a));
List<double> unit(List<double> a) => scale(a, 1 / norm(a));
List<double> transform(List<List<double>> m, List<double> v) =>
    m.map((r) => dot(r, v)).toList();
List<double> cross(List<double> a, List<double> b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
List<double> rotateX(List<double> v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return [v[0], c * v[1] - s * v[2], s * v[1] + c * v[2]];
}

List<double> rotateZ(List<double> v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return [c * v[0] - s * v[1], s * v[0] + c * v[1], v[2]];
}

({double longitudeDeg, double latitudeDeg, double distanceAu}) spherical(
  List<double> v,
) => (
  longitudeDeg: normDeg(math.atan2(v[1], v[0]) * rad),
  latitudeDeg: math.atan2(v[2], math.sqrt(v[0] * v[0] + v[1] * v[1])) * rad,
  distanceAu: norm(v),
);
