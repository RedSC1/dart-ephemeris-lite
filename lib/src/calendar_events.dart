import 'dart:math' as math;
import 'accuracy.dart';
import 'ephemeris.dart' show j2000;
import 'event_fast.dart';
import 'event_accurate.dart';
import 'event_mid.dart';
import 'time.dart';

enum EventSolver { auto, safeguarded }

/// Nearest astronomical solar-longitude event, returning one physical instant.
/// Default mid is a dedicated calendar model, not a position truncation tier.
JulianTime solveSolarLongitude(
  double targetLongitude,
  double nearJdTT, {
  Accuracy accuracy = Accuracy.mid,
  EventSolver solver = EventSolver.auto,
  double? toleranceSeconds,
}) => _solve(
  targetLongitude,
  nearJdTT,
  false,
  accuracy,
  solver,
  toleranceSeconds,
);

/// Nearest astronomical elongation event. Mid defaults to ten latitude terms.
/// moonLatitudeTerms accepts an integer (mid only) or 'full'; null uses the
/// tier default. Accurate fixes full and fast fixes ten terms.
JulianTime solveLunarPhase(
  double targetElongation,
  double nearJdTT, {
  Accuracy accuracy = Accuracy.mid,
  EventSolver solver = EventSolver.auto,
  double? toleranceSeconds,
  Object? moonLatitudeTerms,
}) => _solve(
  targetElongation,
  nearJdTT,
  true,
  accuracy,
  solver,
  toleranceSeconds,
  moonLatitudeTerms,
);
JulianTime solveNewMoon(
  double nearJdTT, {
  Accuracy accuracy = Accuracy.mid,
  EventSolver solver = EventSolver.auto,
  double? toleranceSeconds,
  Object? moonLatitudeTerms,
}) => solveLunarPhase(
  0,
  nearJdTT,
  accuracy: accuracy,
  solver: solver,
  toleranceSeconds: toleranceSeconds,
  moonLatitudeTerms: moonLatitudeTerms,
);
JulianTime _solve(
  double targetAngle,
  double near,
  bool lunar,
  Accuracy accuracy,
  EventSolver solver,
  double? tolerance, [
  Object? moonLatitudeTerms,
]) {
  if (!targetAngle.isFinite || !near.isFinite) {
    throw ArgumentError('Event angle and date must be finite');
  }
  final budget = moonLatitudeTerms == null
      ? (accuracy == Accuracy.accurate ? null : 10)
      : moonLatitudeTerms == 'full'
      ? null
      : moonLatitudeTerms is int &&
            moonLatitudeTerms >= 0 &&
            moonLatitudeTerms <= 277
      ? moonLatitudeTerms
      : throw RangeError("moonLatitudeTerms must be 0..277 or 'full'");
  if (lunar &&
      accuracy != Accuracy.mid &&
      moonLatitudeTerms != null &&
      (accuracy == Accuracy.fast ? budget != 10 : budget != null)) {
    throw RangeError('Custom latitude budgets require mid accuracy');
  }
  if (accuracy == Accuracy.mid) {
    return solveMidEvent(
      targetAngle,
      near,
      lunar,
      toleranceSeconds: tolerance ?? 0.01,
      safeguarded: solver == EventSolver.safeguarded,
      moonLatitudeTerms: budget,
    );
  }
  if ((near - j2000).abs() > 2922000) {
    throw RangeError('Event must lie within J2000 ± 2922000 days');
  }
  if (accuracy == Accuracy.fast &&
      (tolerance != null || solver != EventSolver.auto)) {
    throw ArgumentError(
      'Fast events have fixed stages, not a tolerance or safeguarded solver',
    );
  }
  final target = math.atan2(math.sin(targetAngle), math.cos(targetAngle)),
      tau = 2 * math.pi,
      t = (near - j2000) / 36525;
  final mean = lunar
      ? 7771.37714500204 * t - 1.08472
      : 1.75347 + math.pi + 628.3319653318 * t;
  // JS Math.round uses ties toward positive infinity, unlike Dart round.
  final angle = target + tau * ((mean - target) / tau + 0.5).floor();
  double evaluate(double a) => accuracy == Accuracy.accurate
      ? accurateEventRoot(
          a,
          lunar,
          tolerance ?? 0.01,
          safeguarded: solver == EventSolver.safeguarded,
          normalizedTarget: target,
        )
      : lunar
      ? lunarPhaseTimeFast(a)
      : solarLongitudeTimeFast(a);
  var result = evaluate(angle);
  final distance = near - result;
  if (distance.abs() > (lunar ? 12 : 170)) {
    final adjacent = evaluate(angle + distance.sign * tau);
    if ((adjacent - near).abs() < distance.abs()) result = adjacent;
  }
  return JulianTime.fromTT(result);
}
