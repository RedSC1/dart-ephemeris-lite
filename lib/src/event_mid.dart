// Dedicated calendar-event model. The mid model is not apparentBodyState.
import 'dart:math' as math;
import 'coordinates.dart';
import 'ephemeris.dart';
import 'event_fast.dart';
import 'generated/event_data.dart';
import 'sky_math.dart';
import 'time.dart';

const _aberration = 20.4898 * arcsecToRad;
double _wrap(double a) => math.atan2(math.sin(a), math.cos(a));
CartesianState _earth(double jd, {int? l, int? b, int? r}) =>
    earthStateWithPrefixes(jd, [
      for (final (i, n) in [(0, l), (1, b), (2, r)])
        n == null ? null : earthEventPrefixes[i]['$n']!,
    ]);
CartesianState _sun(CartesianState e) =>
    CartesianState(scale(e.position, -1), scale(e.velocity, -1));
CartesianState _transform(MatrixState f, CartesianState s) => CartesianState(
  transform(f.matrix, s.position),
  add(transform(f.matrix, s.velocity), transform(f.rate, s.position)),
);
ScalarState _longitude(CartesianState s) {
  final p = s.position, v = s.velocity;
  return (
    value: math.atan2(p[1], p[0]),
    rate: (p[0] * v[1] - p[1] * v[0]) / (p[0] * p[0] + p[1] * p[1]),
  );
}

ScalarState _radius(CartesianState s) {
  final r = norm(s.position);
  return (value: r, rate: dot(s.position, s.velocity) / r);
}

ScalarState _drift(List<double> a, double jd) {
  final x = (jd - j2000) / 2922000;
  if (a.isEmpty) return (value: 0, rate: 0);
  if (a.length == 1) return (value: a[0], rate: 0);
  var t0 = 1.0,
      t1 = x,
      d0 = 0.0,
      d1 = 1.0,
      value = a[0] + a[1] * x,
      derivative = a[1];
  for (var n = 2; n < a.length; n++) {
    final t = 2 * x * t1 - t0, d = 2 * t1 + 2 * x * d1 - d0;
    value += a[n] * t;
    derivative += a[n] * d;
    t0 = t1;
    t1 = t;
    d0 = d1;
    d1 = d;
  }
  return (value: value, rate: derivative / 2922000);
}

/// Dedicated mid-model apparent solar longitude (rad) and analytic rad/day.
ScalarState solarLongitudeState(double jdTT) {
  final e = _earth(jdTT, r: 30),
      date = _longitude(
        _transform(meanEclipticOfDateMatrixState(jdTT), _sun(e)),
      );
  final n = iau2000bNutationState(jdTT), r = _radius(e);
  return (
    value: date.value + n.dpsi - _aberration / r.value,
    rate: date.rate + n.dpsiRate + _aberration * r.rate / (r.value * r.value),
  );
}

/// Dedicated calendar lunar longitude, with an optional ranked latitude budget.
/// null means all latitude terms; it does not change the longitude budget.
ScalarState moonLongitudeState(double jdTT, {int? latitudeTerms}) {
  final date = _longitude(
    _transform(
      meanEclipticOfDateMatrixState(jdTT),
      moonDirectionWithTerms(jdTT, latitudeTerms: latitudeTerms),
    ),
  );
  final n = iau2000bNutationState(jdTT);
  return (value: date.value + n.dpsi - 3.4e-6, rate: date.rate + n.dpsiRate);
}

ScalarState _phaseState(
  double jd, {
  int? latitudeTerms,
  int? longitudeTerms,
  int? earthL,
  int? earthB,
  int? earthR,
}) {
  final f = meanEclipticOfDateMatrixState(jd),
      moon = _longitude(
        _transform(
          f,
          moonDirectionWithTerms(
            jd,
            latitudeTerms: latitudeTerms,
            longitudeTerms: longitudeTerms,
          ),
        ),
      );
  final e = _earth(jd, l: earthL, b: earthB, r: earthR),
      sun = _longitude(_transform(f, _sun(e))),
      r = _radius(e);
  return (
    value: _wrap(moon.value - sun.value - 3.4e-6 + _aberration / r.value),
    rate: moon.rate - sun.rate - _aberration * r.rate / (r.value * r.value),
  );
}

ScalarState elongationState(double jdTT, {int? moonLatitudeTerms}) =>
    _phaseState(jdTT, latitudeTerms: moonLatitudeTerms);
ScalarState lowSolarLongitudeState(
  double jdTT, {
  bool withDrift = true,
  int termCount = 10,
}) {
  final e = _earth(jdTT, l: termCount, b: 0, r: 3),
      date = _longitude(
        _transform(meanEclipticOfDateMatrixState(jdTT), _sun(e)),
      ),
      n = iau2000bNutationState(jdTT, termCount: 10),
      r = _radius(e);
  final drift = withDrift
      ? _drift(lowSolarDrift, jdTT)
      : (value: 0.0, rate: 0.0);
  return (
    value: date.value + n.dpsi - _aberration / r.value + drift.value,
    rate:
        date.rate +
        n.dpsiRate +
        _aberration * r.rate / (r.value * r.value) +
        drift.rate,
  );
}

ScalarState lowElongationState(
  double jdTT, {
  bool withDrift = true,
  int moonTermCount = 10,
  int earthTermCount = 10,
}) {
  final moon = moonLongitudeWithTerms(jdTT, moonTermCount),
      sun = lowSolarLongitudeState(
        jdTT,
        withDrift: false,
        termCount: earthTermCount,
      );
  final drift = withDrift
      ? _drift(lowElongationDrift, jdTT)
      : (value: 0.0, rate: 0.0);
  return (
    value: _wrap(moon.value - sun.value - 3.4e-6 + drift.value),
    rate: moon.rate - sun.rate + drift.rate,
  );
}

double _estimate(
  ScalarState Function(double) evaluate,
  double target,
  double near,
  int count,
) {
  var jd = near;
  for (var i = 0; i < count; i++) {
    final s = evaluate(jd);
    jd -= _wrap(s.value - target) / s.rate;
  }
  return jd;
}

double? _newton(
  ScalarState Function(double) evaluate,
  double target,
  double estimate,
  double width,
  double tolerance,
) {
  var jd = estimate;
  for (var i = 0; i < 4; i++) {
    final s = evaluate(jd), correction = _wrap(s.value - target) / s.rate;
    if (!correction.isFinite || s.rate <= 0) return null;
    if (correction.abs() * 86400 <= tolerance) return jd;
    final next = jd - correction;
    if (!(next > estimate - width && next < estimate + width)) return null;
    jd = next;
  }
  return null;
}

double _safeguarded(
  ScalarState Function(double) evaluate,
  double target,
  double estimate,
  double width,
  double tolerance,
) {
  var left = 0.0, right = 0.0, fl = 0.0, fr = 0.0;
  for (var i = 0; i < 6; i++) {
    left = estimate - width;
    right = estimate + width;
    fl = _wrap(evaluate(left).value - target);
    fr = _wrap(evaluate(right).value - target);
    if (fl <= 0 && fr >= 0) break;
    width *= 1.8;
  }
  if (!(fl <= 0 && fr >= 0)) throw StateError('Could not bracket event');
  var jd = estimate.clamp(left, right);
  for (var i = 0; i < 40; i++) {
    final s = evaluate(jd), residual = _wrap(s.value - target);
    if ((residual / s.rate).abs() * 86400 <= tolerance) return jd;
    if (residual < 0) {
      left = jd;
    } else {
      right = jd;
    }
    final newton = jd - residual / s.rate,
        next = newton.isFinite && newton > left && newton < right
            ? newton
            : 0.5 * (left + right);
    if ((next - jd).abs() * 86400 <= tolerance) return next;
    jd = next;
  }
  throw StateError('Event root did not converge');
}

// Same stages and acceptance conditions as JS. Initially reuse analytic state
// evaluators for values; removing unused derivative work is a later optimization.
double? _simple(
  double target,
  double near,
  double tolerance,
  bool lunar,
  int? latitudeTerms,
) {
  bool inRange(double jd) => jd.isFinite && (jd - j2000).abs() <= 2922000;
  if (!inRange(near) ||
      tolerance < 2 * 2.220446049250313e-16 * near.abs() * 86400) {
    return null;
  }
  final rate = lunar ? elongationApproximateRate : solarApproximateRate;
  double low(double jd) =>
      lunar ? lowElongationState(jd).value : lowSolarLongitudeState(jd).value;
  var jd = near;
  for (var i = 0; i < 2; i++) {
    if (!inRange(jd)) return null;
    final residual = _wrap(low(jd) - target);
    if (i == 0 && residual.abs() > math.pi - 0.1) return null;
    jd -= residual / rate(jd);
  }
  final estimate = jd, width = lunar ? 2 : 3;
  double? phaseVelocity;
  if (lunar) {
    if (!inRange(jd)) return null;
    final middle = _phaseState(
      jd,
      latitudeTerms: latitudeTerms,
      longitudeTerms: 60,
      earthL: 60,
      earthB: 0,
      earthR: 3,
    ).value;
    jd -= _wrap(middle - target) / rate(jd);
    if (!inRange(jd)) return null;
    phaseVelocity = elongationRefineRate(jd);
  }
  for (var i = 0; i < 5; i++) {
    if (!inRange(jd) || (jd - estimate).abs() > width) return null;
    final value = lunar
        ? _phaseState(jd, latitudeTerms: latitudeTerms, earthR: 30).value
        : solarLongitudeState(jd).value;
    final velocity = phaseVelocity ?? rate(jd),
        step = _wrap(value - target) / velocity;
    if (!step.isFinite || velocity <= 0) return null;
    if (step.abs() * 86400 <= tolerance * 0.5) return jd;
    final next = jd - step;
    if (next == jd) return null;
    jd = next;
  }
  return null;
}

JulianTime solveMidEvent(
  double targetAngle,
  double near,
  bool lunar, {
  double toleranceSeconds = 0.01,
  bool safeguarded = false,
  int? moonLatitudeTerms = 10,
}) {
  if (!targetAngle.isFinite || !near.isFinite) {
    throw ArgumentError('Event angle and date must be finite');
  }
  if (!toleranceSeconds.isFinite || toleranceSeconds <= 0) {
    throw ArgumentError.value(toleranceSeconds, 'toleranceSeconds');
  }
  final target = _wrap(targetAngle),
      tolerance = !lunar && !safeguarded
          ? math.min(toleranceSeconds, 0.001)
          : toleranceSeconds;
  final simple = safeguarded
      ? null
      : _simple(target, near, tolerance, lunar, moonLatitudeTerms);
  if (simple != null) return JulianTime.fromTT(simple);
  final estimate = _estimate(
    lunar ? lowElongationState : lowSolarLongitudeState,
    target,
    near,
    lunar ? 3 : 2,
  );
  ScalarState evaluate(double jd) => lunar
      ? elongationState(jd, moonLatitudeTerms: moonLatitudeTerms)
      : solarLongitudeState(jd);
  ScalarState fast(double jd) => lunar
      ? _phaseState(jd, latitudeTerms: moonLatitudeTerms, earthR: 30)
      : solarLongitudeState(jd);
  final root = safeguarded
      ? null
      : _newton(fast, target, estimate, lunar ? 2 : 3, tolerance);
  return JulianTime.fromTT(
    root ?? _safeguarded(evaluate, target, estimate, lunar ? 2 : 3, tolerance),
  );
}
