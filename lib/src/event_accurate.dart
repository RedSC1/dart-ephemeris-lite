// Accurate apparent-position event roots, ported from calendar-events.js.
import 'dart:math' as math;
import 'sun_moon_apparent.dart';
import 'coordinates.dart' show ScalarState;
import 'sun_moon_ephemeris.dart' show j2000;
import 'event_fast.dart';

double _wrap(double angle) => math.atan2(math.sin(angle), math.cos(angle));
double _checked(double jd) {
  if (!jd.isFinite || (jd - j2000).abs() > 2922000) {
    throw RangeError('Event must lie within J2000 ± 2922000 days');
  }
  return jd;
}

ScalarState _evaluate(double jd, bool lunar) {
  _checked(jd);
  final sun = apparentBodyState(SkyBody.sun, jd);
  const radians = math.pi / 180;
  if (!lunar) {
    return (
      value: sun.longitudeDeg * radians,
      rate: sun.longitudeSpeedDegPerDay * radians,
    );
  }
  final moon = apparentBodyState(SkyBody.moon, jd);
  return (
    value: _wrap((moon.longitudeDeg - sun.longitudeDeg) * radians),
    rate:
        (moon.longitudeSpeedDegPerDay - sun.longitudeSpeedDegPerDay) * radians,
  );
}

double accurateEventRoot(
  double angle,
  bool lunar,
  double tolerance, {
  bool safeguarded = false,
  double? normalizedTarget,
}) {
  if (!angle.isFinite) throw ArgumentError.value(angle, 'angle');
  final seed = _checked(
    j2000 +
        (lunar
                ? (angle + 1.08472) / 7771.37714500204
                : (angle - 1.75347 - math.pi) / 628.3319653318) *
            36525,
  );
  if (!tolerance.isFinite || tolerance <= 0) {
    throw ArgumentError.value(tolerance, 'toleranceSeconds');
  }
  const epsilon = 2.220446049250313e-16;
  if (tolerance < 2 * epsilon * seed.abs() * 86400) {
    throw RangeError('Tolerance below Julian Day resolution');
  }
  final estimate = lunar
          ? lunarPhaseTimeFast(angle)
          : solarLongitudeTimeFast(angle),
      target = normalizedTarget ?? _wrap(angle);
  final halfWidth = lunar ? 2.0 : 3.0;
  var jd = estimate;
  for (var i = 0; !safeguarded && i < 4; i++) {
    final state = _evaluate(jd, lunar),
        residual = _wrap(state.value - target),
        correction = residual / state.rate;
    if (!correction.isFinite || state.rate <= 0) break;
    if (correction.abs() * 86400 <= tolerance) return _checked(jd);
    final next = jd - correction;
    if (!(next > estimate - halfWidth && next < estimate + halfWidth)) break;
    jd = next;
  }
  var width = halfWidth, left = 0.0, right = 0.0, fl = 0.0, fr = 0.0;
  for (var i = 0; i < 6; i++) {
    left = estimate - width;
    right = estimate + width;
    fl = _wrap(_evaluate(left, lunar).value - target);
    fr = _wrap(_evaluate(right, lunar).value - target);
    if (fl <= 0 && fr >= 0) break;
    width *= 1.8;
  }
  if (!(fl <= 0 && fr >= 0)) {
    throw StateError('Could not bracket requested event');
  }
  jd = estimate.clamp(left, right);
  double verify(double value) {
    final s = _evaluate(value, lunar),
        rounding = 2 * epsilon * value.abs() * 86400;
    if ((_wrap(s.value - target) / s.rate).abs() * 86400 >
        tolerance + rounding) {
      throw StateError('Apparent root did not converge');
    }
    return _checked(value);
  }

  for (var i = 0; i < 40; i++) {
    final state = _evaluate(jd, lunar), residual = _wrap(state.value - target);
    if ((residual / state.rate).abs() * 86400 <= tolerance) return verify(jd);
    if (residual < 0) {
      left = jd;
    } else {
      right = jd;
    }
    final newton = jd - residual / state.rate;
    final next = newton.isFinite && newton > left && newton < right
        ? newton
        : 0.5 * (left + right);
    if ((next - jd).abs() * 86400 <= tolerance) return verify(next);
    jd = next;
  }
  throw StateError('Event root did not converge');
}

/// Unwrapped solar longitude (rad) → JD(TT), through the complete apparent
/// Sun chain. Tolerance is numerical convergence, not astronomical accuracy.
double solarLongitudeTimeAccurate(
  double longitude, {
  double toleranceSeconds = 0.01,
}) => accurateEventRoot(longitude, false, toleranceSeconds);

/// Unwrapped elongation (rad) → JD(TT), with full lunar latitude, distance,
/// iterated light time, aberration and solar deflection.
double lunarPhaseTimeAccurate(
  double elongation, {
  double toleranceSeconds = 0.01,
}) => accurateEventRoot(elongation, true, toleranceSeconds);
