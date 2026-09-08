// Pure Dart port of coordinates.js. MPL-2.0.
import 'dart:math' as math;
import 'ephemeris.dart' show j2000;
import 'generated/coordinate_data.dart';

const arcsecToRad = math.pi / 648000;
const _century = 36525.0;
const _eps0 = 84381.406 * arcsecToRad;
const _tau = 2 * math.pi;
typedef Matrix3 = List<List<double>>;
typedef ScalarState = ({double value, double rate});

/// Matrix plus analytic derivative per TT day. Both matrices are immutable.
class MatrixState {
  final Matrix3 matrix, rate;
  MatrixState(Matrix3 matrix, Matrix3 rate)
    : matrix = _freeze(matrix),
      rate = _freeze(rate);
}

Matrix3 _freeze(Matrix3 m) =>
    List.unmodifiable(m.map((r) => List<double>.unmodifiable(r)));
void _finite(double jd) {
  if (!jd.isFinite) throw ArgumentError.value(jd, 'jdTT');
}

double _polynomial(List<double> a, double t) {
  var v = 0.0;
  for (var i = a.length - 1; i >= 0; i--) {
    v = v * t + a[i];
  }
  return v;
}

double _derivative(List<double> a, double t) {
  var v = 0.0;
  for (var i = a.length - 1; i >= 1; i--) {
    v = v * t + i * a[i];
  }
  return v;
}

Matrix3 _multiply(Matrix3 a, Matrix3 b) => List.generate(
  3,
  (i) => List.generate(
    3,
    (j) => ((0 + a[i][0] * b[0][j]) + a[i][1] * b[1][j]) + a[i][2] * b[2][j],
  ),
);
Matrix3 _add(Matrix3 a, Matrix3 b) =>
    List.generate(3, (i) => List.generate(3, (j) => a[i][j] + b[i][j]));
Matrix3 _transpose(Matrix3 a) =>
    List.generate(3, (i) => List.generate(3, (j) => a[j][i]));
Matrix3 _rx(double angle) {
  final c = math.cos(angle), s = math.sin(angle);
  return [
    [1, 0, 0],
    [0, c, s],
    [0, -s, c],
  ];
}

Matrix3 _rxRate(double angle, double rate) {
  final c = math.cos(angle), s = math.sin(angle);
  return [
    [0, 0, 0],
    [0, -s * rate, c * rate],
    [0, -c * rate, -s * rate],
  ];
}

Matrix3 _ry(double angle) {
  final c = math.cos(angle), s = math.sin(angle);
  return [
    [c, 0, -s],
    [0, 1, 0],
    [s, 0, c],
  ];
}

Matrix3 _rz(double angle) {
  final c = math.cos(angle), s = math.sin(angle);
  return [
    [c, s, 0],
    [-s, c, 0],
    [0, 0, 1],
  ];
}

List<double> _cross(List<double> a, List<double> b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
typedef _VectorState = ({List<double> value, List<double> rate});
_VectorState _normalize(List<double> v, List<double> rate) {
  final length = math.sqrt(v.fold(0.0, (s, x) => s + x * x));
  final unit = v.map((x) => x / length).toList();
  var projection = 0.0;
  for (var i = 0; i < 3; i++) {
    projection += unit[i] * rate[i];
  }
  return (
    value: unit,
    rate: List.generate(3, (i) => (rate[i] - unit[i] * projection) / length),
  );
}

_VectorState _crossState(
  List<double> a,
  List<double> ad,
  List<double> b,
  List<double> bd,
) {
  final left = _cross(ad, b), right = _cross(a, bd);
  return (
    value: _cross(a, b),
    rate: List.generate(3, (i) => left[i] + right[i]),
  );
}

/// IAU 2006 mean obliquity in radians.
double meanObliquityIau2006(double jdTT) =>
    meanObliquityIau2006State(jdTT).value;
ScalarState meanObliquityIau2006State(double jdTT) {
  _finite(jdTT);
  const a = [
    84381.406,
    -46.836769,
    -0.0001831,
    0.00200340,
    -0.000000576,
    -0.0000000434,
  ];
  final t = (jdTT - j2000) / _century;
  return (
    value: _polynomial(a, t) * arcsecToRad,
    rate: _derivative(a, t) * arcsecToRad / _century,
  );
}

/// Angles in radians and analytic rates per TT day.
class NutationState {
  final double dpsi, deps, dpsiRate, depsRate, meanObliquity, meanObliquityRate;
  const NutationState({
    required this.dpsi,
    required this.deps,
    required this.dpsiRate,
    required this.depsRate,
    required this.meanObliquity,
    required this.meanObliquityRate,
  });
  double get trueObliquity => meanObliquity + deps;
  double get trueObliquityRate => meanObliquityRate + depsRate;
  Map<String, double> toJson() => {
    'dpsi': dpsi,
    'deps': deps,
    'dpsiRate': dpsiRate,
    'depsRate': depsRate,
    'meanObliquity': meanObliquity,
    'meanObliquityRate': meanObliquityRate,
    'trueObliquity': trueObliquity,
    'trueObliquityRate': trueObliquityRate,
  };
}

const _arguments = [
  [485868.249036, 1717915923.2178],
  [1287104.79305, 129596581.0481],
  [335779.526232, 1739527262.8478],
  [1072260.70369, 1602961601.2090],
  [450160.398036, -6962890.5431],
];
NutationState iau2000bNutation(double jdTT) => iau2000bNutationState(jdTT);
NutationState iau2000bNutationState(double jdTT, {int? termCount}) {
  _finite(jdTT);
  final t = (jdTT - j2000) / _century;
  // JS % is signed remainder; Dart % is Euclidean modulo.
  final fa = _arguments
      .map((d) => (d[0] + t * d[1]).remainder(1296000) * arcsecToRad)
      .toList();
  final fr = _arguments.map((d) => d[1] * arcsecToRad / _century).toList();
  var dp = 0.0, de = 0.0, dpRate = 0.0, deRate = 0.0;
  final count = (termCount ?? nutationTerms.length).clamp(
    0,
    nutationTerms.length,
  );
  for (var i = count - 1; i >= 0; i--) {
    final r = nutationTerms[i];
    var a = 0.0, ar = 0.0;
    for (var j = 0; j < 5; j++) {
      a += r[j] * fa[j];
      ar += r[j] * fr[j];
    }
    final s = math.sin(a),
        c = math.cos(a),
        psi = r[5] + r[6] * t,
        eps = r[8] + r[9] * t;
    dp += psi * s + r[7] * c;
    de += eps * c + r[10] * s;
    dpRate += r[6] / _century * s + psi * c * ar - r[7] * s * ar;
    deRate += r[9] / _century * c - eps * s * ar + r[10] * c * ar;
  }
  final ob = meanObliquityIau2006State(jdTT);
  return NutationState(
    dpsi: (-0.000135 + dp * 1e-7) * arcsecToRad,
    deps: (0.000388 + de * 1e-7) * arcsecToRad,
    dpsiRate: dpRate * 1e-7 * arcsecToRad,
    depsRate: deRate * 1e-7 * arcsecToRad,
    meanObliquity: ob.value,
    meanObliquityRate: ob.rate,
  );
}

/// Value-only longitude path, avoiding obliquity and derivative evaluation.
double iau2000bNutationLongitude(double jdTT, {int? termCount}) {
  _finite(jdTT);
  final t = (jdTT - j2000) / _century;
  final fa = _arguments
      .map((d) => (d[0] + t * d[1]).remainder(1296000) * arcsecToRad)
      .toList();
  var dp = 0.0;
  for (
    var i =
        (termCount ?? nutationTerms.length).clamp(0, nutationTerms.length) - 1;
    i >= 0;
    i--
  ) {
    final r = nutationTerms[i];
    var a = 0.0;
    for (var j = 0; j < 5; j++) {
      a += r[j] * fa[j];
    }
    dp += (r[5] + r[6] * t) * math.sin(a) + r[7] * math.cos(a);
  }
  return (-0.000135 + dp * 1e-7) * arcsecToRad;
}

final _bias = _multiply(
  _multiply(_rx(0.0068192 * arcsecToRad), _ry(-0.016617 * arcsecToRad)),
  _rz(-0.0146 * arcsecToRad),
);

({double a, double b, double ad, double bd}) _periodic(
  List<List<double>> terms,
  List<double> p,
  List<double> q,
  double t,
) {
  var a = 0.0, b = 0.0, ad = 0.0, bd = 0.0;
  for (final r in terms) {
    final arg = _tau * t / r[0], rate = _tau / r[0];
    a += math.cos(arg) * r[1] + math.sin(arg) * r[3];
    b += math.cos(arg) * r[2] + math.sin(arg) * r[4];
    ad += rate * (-math.sin(arg) * r[1] + math.cos(arg) * r[3]);
    bd += rate * (-math.sin(arg) * r[2] + math.cos(arg) * r[4]);
  }
  return (
    a: (a + _polynomial(p, t)) * arcsecToRad,
    b: (b + _polynomial(q, t)) * arcsecToRad,
    ad: (ad + _derivative(p, t)) * arcsecToRad / _century,
    bd: (bd + _derivative(q, t)) * arcsecToRad / _century,
  );
}

/// Vondrák 2011 precession including the same frame bias as the JS model.
MatrixState vondrak2011PrecessionMatrixState(double jdTT) {
  _finite(jdTT);
  final t = (jdTT - j2000) / _century;
  final e = _periodic(eclipticPeriodic, pa, qa, t),
      f = _periodic(equatorPeriodic, xa, ya, t);
  final p = e.a, q = e.b, pd = e.ad, qd = e.bd;
  final z = math.sqrt(math.max(1 - p * p - q * q, 0)),
      zd = z == 0 ? 0.0 : -(p * pd + q * qd) / z;
  final ep = [
    p,
    -q * math.cos(_eps0) - z * math.sin(_eps0),
    -q * math.sin(_eps0) + z * math.cos(_eps0),
  ];
  final ed = [
    pd,
    -qd * math.cos(_eps0) - zd * math.sin(_eps0),
    -qd * math.sin(_eps0) + zd * math.cos(_eps0),
  ];
  final x = f.a, y = f.b, xd = f.ad, yd = f.bd;
  final ez = math.sqrt(math.max(1 - x * x - y * y, 0)),
      ezd = ez == 0 ? 0.0 : -(x * xd + y * yd) / ez;
  final pole = [x, y, ez], poleRate = [xd, yd, ezd];
  final cross = _crossState(pole, poleRate, ep, ed),
      xs = _normalize(cross.value, cross.rate);
  final ys = _crossState(pole, poleRate, xs.value, xs.rate);
  return MatrixState(
    _multiply([xs.value, ys.value, pole], _bias),
    _multiply([xs.rate, ys.rate, poleRate], _bias),
  );
}

Matrix3 vondrak2011PrecessionMatrix(double jdTT) =>
    vondrak2011PrecessionMatrixState(jdTT).matrix;
final _fixed = _multiply(
  _rx(meanObliquityIau2006(j2000)),
  vondrak2011PrecessionMatrix(j2000),
);
final _fixedInverse = _transpose(_fixed);

/// ICRF equatorial vector to fixed mean J2000 ecliptic axes.
List<double> icrfEquatorialToJ2000Ecliptic(List<double> v) {
  if (v.length != 3 || !v.every((x) => x.isFinite)) {
    throw ArgumentError('Vector must contain three finite numbers');
  }
  return List.unmodifiable(
    _fixed.map((r) => r[0] * v[0] + r[1] * v[1] + r[2] * v[2]),
  );
}

/// Fixed mean J2000 ecliptic to mean ecliptic/equinox of date, with rate.
MatrixState meanEclipticOfDateMatrixState(double jdTT) {
  final p = vondrak2011PrecessionMatrixState(jdTT),
      ob = meanObliquityIau2006State(jdTT);
  final rx = _rx(ob.value), rd = _rxRate(ob.value, ob.rate);
  return MatrixState(
    _multiply(_multiply(rx, p.matrix), _fixedInverse),
    _multiply(
      _add(_multiply(rd, p.matrix), _multiply(rx, p.rate)),
      _fixedInverse,
    ),
  );
}

/// Value-only date-frame evaluation, matching the JS optimized path.
Matrix3 meanEclipticOfDateMatrix(double jdTT) {
  _finite(jdTT);
  final t = (jdTT - j2000) / _century;
  var p = 0.0, q = 0.0, x = 0.0, y = 0.0;
  for (final r in eclipticPeriodic) {
    final a = _tau * t / r[0];
    p += math.cos(a) * r[1] + math.sin(a) * r[3];
    q += math.cos(a) * r[2] + math.sin(a) * r[4];
  }
  p = (p + _polynomial(pa, t)) * arcsecToRad;
  q = (q + _polynomial(qa, t)) * arcsecToRad;
  final z = math.sqrt(math.max(1 - p * p - q * q, 0));
  final e = [
    p,
    -q * math.cos(_eps0) - z * math.sin(_eps0),
    -q * math.sin(_eps0) + z * math.cos(_eps0),
  ];
  for (final r in equatorPeriodic) {
    final a = _tau * t / r[0];
    x += math.cos(a) * r[1] + math.sin(a) * r[3];
    y += math.cos(a) * r[2] + math.sin(a) * r[4];
  }
  x = (x + _polynomial(xa, t)) * arcsecToRad;
  y = (y + _polynomial(ya, t)) * arcsecToRad;
  final pole = [x, y, math.sqrt(math.max(1 - x * x - y * y, 0))],
      equinox = _cross(pole, e);
  final length = math.sqrt(equinox.fold(0.0, (s, v) => s + v * v));
  final unit = equinox.map((v) => v / length).toList();
  final precession = _multiply([unit, _cross(pole, unit), pole], _bias);
  return _freeze(
    _multiply(
      _multiply(_rx(meanObliquityIau2006(jdTT)), precession),
      _fixedInverse,
    ),
  );
}
