import 'dart:math' as math;
import 'accuracy.dart';
import 'ephemeris_types.dart';
import 'model_math.dart';
export 'ephemeris_types.dart';
import 'planet_evaluator.dart';
import 'generated/earth_series.dart';
import 'generated/moon_series.dart';

CartesianState earthState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => evaluatePlanetSeries(earthSeries, earthPrefixes, jdTT, accuracy);
List<double> earthPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => earthState(jdTT, accuracy: accuracy).position;
CartesianState earthDirectionState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => evaluatePlanetSeries(
  earthSeries,
  earthPrefixes,
  jdTT,
  accuracy,
  direction: true,
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

  ({double value, double rate}) coordinate(
    int c,
    Accuracy accuracy, {
    int? terms,
  }) {
    final groups = [moonL, moonB, moonR][c];
    final counts = accuracy == Accuracy.accurate
        ? null
        : moonPrefixes[c][accuracy.name]!;
    var value = 0.0, rate = 0.0;
    if (terms != null) {
      final ranked = moonRankedIndices[c];
      if (terms < 0 || terms > ranked.length) {
        throw RangeError('Invalid lunar term limit');
      }
      for (var i = 0; i < terms; i++) {
        final n = ranked[i][0], index = ranked[i][1], rows = groups[n];
        final arg = argument(rows[index + 2].toInt());
        final v = rows[index] * arg.sine + rows[index + 1] * arg.cosine;
        final dv =
            (rows[index] * arg.cosine - rows[index + 1] * arg.sine) * arg.speed;
        final env = math.pow(x, n).toDouble(),
            dr = n == 0 ? 0.0 : n * math.pow(x, n - 1) / moonScaleDays;
        value += v * env;
        rate += dv * env + v * dr;
      }
    } else {
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
    }
    if (c == 0) {
      final m = polynomialState(moonW1, x, 1 / moonScaleDays);
      value += m.value;
      rate += m.rate;
    }
    return (value: value, rate: rate);
  }
}

CartesianState _moon(
  double jd,
  Accuracy accuracy, {
  bool direction = false,
  int? latitudeTerms,
  bool fullLatitude = false,
  int? longitudeTerms,
}) {
  validateJd(jd);
  final evaluation = _MoonEvaluation(jd);
  final l = evaluation.coordinate(0, accuracy, terms: longitudeTerms),
      b = evaluation.coordinate(
        1,
        fullLatitude ? Accuracy.accurate : accuracy,
        terms: latitudeTerms,
      );
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
  final pp = polynomialState(moonPrecessionP, t, tRate),
      qq = polynomialState(moonPrecessionQ, t, tRate);
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
  final sv = applyMatrix(matrix, vel), fv = applyMatrix(rate, pos);
  return CartesianState(
    applyMatrix(matrix, pos),
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
  Object? latitudeTerms,
}) {
  if (latitudeTerms != null &&
      latitudeTerms != 'full' &&
      (latitudeTerms is! int || latitudeTerms < 0 || latitudeTerms > 277)) {
    throw RangeError("latitudeTerms must be 0..277 or 'full'");
  }
  return _moon(
    jdTT,
    accuracy,
    direction: true,
    latitudeTerms: latitudeTerms is int ? latitudeTerms : null,
    fullLatitude: latitudeTerms == 'full',
  );
}

List<double> moonPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => moonState(jdTT, accuracy: accuracy).position;
({double value, double rate}) moonElpLongitudeState(double jdTT) {
  validateJd(jdTT);
  return _MoonEvaluation(jdTT).coordinate(0, Accuracy.accurate);
}

CartesianState moonHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => combineStates(
  earthState(jdTT, accuracy: accuracy),
  moonState(jdTT, accuracy: accuracy),
  1 / auKm,
);
CartesianState embState(double jdTT, {Accuracy accuracy = Accuracy.accurate}) =>
    combineStates(
      earthState(jdTT, accuracy: accuracy),
      moonState(jdTT, accuracy: accuracy),
      1 / ((1 + earthMoonMassRatio) * auKm),
    );

// Internal calendar model entry points, hidden by the package barrel.
CartesianState earthStateWithPrefixes(double jd, List<List<int>?> counts) =>
    evaluatePlanetSeries(
      earthSeries,
      earthPrefixes,
      jd,
      Accuracy.accurate,
      prefixOverride: counts,
    );
CartesianState moonDirectionWithTerms(
  double jd, {
  int? latitudeTerms,
  int? longitudeTerms,
}) => _moon(
  jd,
  Accuracy.accurate,
  direction: true,
  latitudeTerms: latitudeTerms,
  longitudeTerms: longitudeTerms,
);
({double value, double rate}) moonLongitudeWithTerms(double jd, int terms) {
  validateJd(jd);
  return _MoonEvaluation(jd).coordinate(0, Accuracy.accurate, terms: terms);
}

// Explicit geometric aliases preserve the upstream units and accuracy option.
CartesianState earthHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => earthState(jdTT, accuracy: accuracy);
CartesianState moonGeocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => moonState(jdTT, accuracy: accuracy);
CartesianState embHeliocentricState(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => embState(jdTT, accuracy: accuracy);
List<double> embPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => embState(jdTT, accuracy: accuracy).position;
List<double> earthHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => earthState(jdTT, accuracy: accuracy).position;
List<double> moonGeocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => moonState(jdTT, accuracy: accuracy).position;
List<double> moonHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => moonHeliocentricState(jdTT, accuracy: accuracy).position;
List<double> embHeliocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => embState(jdTT, accuracy: accuracy).position;
List<double> sunGeocentricPosition(
  double jdTT, {
  Accuracy accuracy = Accuracy.accurate,
}) => sunGeocentricState(jdTT, accuracy: accuracy).position;
