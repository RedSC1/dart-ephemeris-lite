// Port of direct-planet-model.js, planet-frame.js and moon-model.js. MPL-2.0.
import 'dart:math' as math;
import 'accuracy.dart';
import 'generated/series.dart';

const j2000 = 2451545.0;
const auKm = 149597870.7;
const earthMoonMassRatio = 81.30056822149722;

/// Pluto's special near/fallback model is not ported yet.
enum Planet { mercury, venus, earth, mars, jupiter, saturn, uranus, neptune }

/// Geometric mean J2000 ecliptic position and analytic velocity.
/// Planet states: AU and AU/day. Geocentric Moon: km and km/day.
class CartesianState {
  final List<double> position, velocity;
  CartesianState(List<double> position, List<double> velocity)
    : position = List.unmodifiable(position),
      velocity = List.unmodifiable(velocity);
}

const _toJ2000 = [
  [0.9999999999999803, 1.9786988844634012e-7, 2.0200940272138296e-9],
  [-1.978698884606213e-7, 0.9999999999999803, 7.069560215011705e-9],
  [-2.020092628360702e-9, -7.0695604925674616e-9, 1.0],
];
List<double> _apply(List<List<double>> matrix, List<double> v) =>
    matrix.map((row) => row[0] * v[0] + row[1] * v[1] + row[2] * v[2]).toList();
CartesianState _spherical(List<double> p, List<double> v) {
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

void _finite(double jd) {
  if (!jd.isFinite) throw ArgumentError.value(jd, 'jdTT');
}

CartesianState _planet(
  Planet planet,
  double jd,
  Accuracy accuracy, {
  bool direction = false,
}) {
  _finite(jd);
  final groups = planetSeries[planet.name]!;
  final limits = accuracy == Accuracy.accurate
      ? null
      : planetPrefixes[planet.name]![accuracy.name];
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
  final native = _spherical(values, rates);
  final p = _apply(_toJ2000, native.position),
      v = _apply(_toJ2000, native.velocity);
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

CartesianState planetHeliocentricState(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => _planet(planet, jdTT, accuracy);
List<double> planetHeliocentricPosition(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(planet, jdTT, accuracy: accuracy).position;
CartesianState earthState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => planetHeliocentricState(Planet.earth, jdTT, accuracy: accuracy);
List<double> earthPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => earthState(jdTT, accuracy: accuracy).position;
CartesianState earthDirectionState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => _planet(Planet.earth, jdTT, accuracy, direction: true);
CartesianState _combine(CartesianState a, CartesianState b, double scale) =>
    CartesianState(
      List.generate(3, (i) => a.position[i] + b.position[i] * scale),
      List.generate(3, (i) => a.velocity[i] + b.velocity[i] * scale),
    );
CartesianState planetGeocentricState(
  Planet planet,
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => _combine(
  planetHeliocentricState(planet, jdTT, accuracy: accuracy),
  earthState(jdTT, accuracy: accuracy),
  -1,
);
CartesianState sunGeocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) {
  final e = earthState(jdTT, accuracy: accuracy);
  return CartesianState(
    e.position.map((x) => -x).toList(),
    e.velocity.map((x) => -x).toList(),
  );
}

({double value, double rate}) _poly(
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

// Per-evaluation scratch data: no global mutable cache or accuracy setting.
class _MoonEvaluation {
  final double x;
  final List<({double sine, double cosine, double speed})?> arguments;
  _MoonEvaluation(double jd)
    : x = (jd - j2000) / moonScaleDays,
      arguments = List.filled(moonArguments.length, null);
  ({double sine, double cosine, double speed}) argument(int k) {
    final cached = arguments[k];
    if (cached != null) return cached;
    final p = moonArguments[k];
    var a = p[7], d = a;
    for (var i = 6; i >= 0; i--) {
      a = a * x + p[i];
      d = d * x + a;
    }
    a *= x;
    return arguments[k] = (
      sine: math.sin(a),
      cosine: math.cos(a),
      speed: d / moonScaleDays,
    );
  }

  ({double value, double rate}) coordinate(int c, Accuracy accuracy) {
    final groups = [moonL, moonB, moonR][c];
    final counts = accuracy == Accuracy.accurate
        ? null
        : moonPrefixes[c][accuracy.name]!;
    var value = 0.0, rate = 0.0;
    for (var n = 0; n < groups.length; n++) {
      final rows = groups[n];
      final end = counts == null
          ? rows.length
          : math.min((n < counts.length ? counts[n] : 0) * 3, rows.length);
      var sum = 0.0, derivative = 0.0;
      for (var i = 0; i < end; i += 3) {
        final arg = argument(rows[i + 2].toInt());
        sum += rows[i] * arg.sine + rows[i + 1] * arg.cosine;
        derivative +=
            (rows[i] * arg.cosine - rows[i + 1] * arg.sine) * arg.speed;
      }
      final env = math.pow(x, n).toDouble(),
          dr = n == 0 ? 0.0 : n * math.pow(x, n - 1) / moonScaleDays;
      value += sum * env;
      rate += derivative * env + sum * dr;
    }
    if (c == 0) {
      final m = _poly(moonW1, x, 1 / moonScaleDays);
      value += m.value;
      rate += m.rate;
    }
    return (value: value, rate: rate);
  }
}

CartesianState _moon(double jd, Accuracy accuracy, {bool direction = false}) {
  _finite(jd);
  final evaluation = _MoonEvaluation(jd);
  final l = evaluation.coordinate(0, accuracy),
      b = evaluation.coordinate(1, accuracy);
  final r = direction
      ? (value: 1.0, rate: 0.0)
      : evaluation.coordinate(2, accuracy);
  final cl = math.cos(l.value),
      sl = math.sin(l.value),
      cb = math.cos(b.value),
      sb = math.sin(b.value),
      rc = r.value * cb;
  final drc = r.rate * cb - r.value * sb * b.rate;
  final pos = [rc * cl, rc * sl, r.value * sb],
      vel = [
        drc * cl - rc * sl * l.rate,
        drc * sl + rc * cl * l.rate,
        r.rate * sb + r.value * cb * b.rate,
      ];
  final t = evaluation.x * 80;
  const tRate = 1 / 36525;
  final pp = _poly(moonPrecessionP, t, tRate),
      qq = _poly(moonPrecessionQ, t, tRate);
  final p = pp.value * t,
      q = qq.value * t,
      dp = pp.rate * t + pp.value * tRate,
      dq = qq.rate * t + qq.value * tRate;
  final s = 1 - p * p - q * q;
  if (s < 0) throw RangeError('ELP P/Q rotation outside real-valued domain');
  final rot = 2 * math.sqrt(s), dr = -2 * (p * dp + q * dq) / math.sqrt(s);
  final matrix = [
    [1 - 2 * p * p, 2 * p * q, p * rot],
    [2 * p * q, 1 - 2 * q * q, -q * rot],
    [-p * rot, q * rot, 1 - 2 * p * p - 2 * q * q],
  ];
  final rate = [
    [-4 * p * dp, 2 * (dp * q + p * dq), dp * rot + p * dr],
    [2 * (dp * q + p * dq), -4 * q * dq, -dq * rot - q * dr],
    [-dp * rot - p * dr, dq * rot + q * dr, -4 * p * dp - 4 * q * dq],
  ];
  final sv = _apply(matrix, vel), fv = _apply(rate, pos);
  return CartesianState(
    _apply(matrix, pos),
    List.generate(3, (i) => sv[i] + fv[i]),
  );
}

CartesianState moonState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => _moon(jdTT, accuracy);
CartesianState moonDirectionState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => _moon(jdTT, accuracy, direction: true);
List<double> moonPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => moonState(jdTT, accuracy: accuracy).position;
({double value, double rate}) moonElpLongitudeState(double jdTT) {
  _finite(jdTT);
  return _MoonEvaluation(jdTT).coordinate(0, Accuracy.accurate);
}

CartesianState moonHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => _combine(
  earthState(jdTT, accuracy: accuracy),
  moonState(jdTT, accuracy: accuracy),
  1 / auKm,
);
CartesianState embState(double jdTT, {Accuracy accuracy = Accuracy.accurate}) =>
    _combine(
      earthState(jdTT, accuracy: accuracy),
      moonState(jdTT, accuracy: accuracy),
      1 / ((1 + earthMoonMassRatio) * auKm),
    );
