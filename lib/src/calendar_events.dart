import 'dart:math' as math;
import 'accuracy.dart';
import 'sun_moon_ephemeris.dart' show j2000;
import 'event_fast.dart';
import 'event_accurate.dart';
import 'event_mid.dart';
import 'time.dart';

/// 气朔迭代求解策略；快速档仅支持 auto，其他档可选择带保护的求根。
enum EventSolver { auto, safeguarded }

/// 求 [nearJdTT] 附近最近一次到达目标太阳视黄经的天文时刻。
///
/// [targetLongitude] 使用弧度，nearJdTT 为 TT 儒略日；返回同时包含 TT 与 UT1
/// 的 JulianTime。默认 mid 使用专用事件模型，三档不只是位置级数的截断。
///
/// 历史历法只影响事件归日，不改变本函数的根。toleranceSeconds 是数值
/// 收敛阈值（秒），不是绝对天文误差保证；fast 不接受该参数或 safeguarded。
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

/// 求 [nearJdTT] 附近最近一次到达目标日月视黄经差的天文时刻。
///
/// [targetElongation] 使用弧度：0 为朔，π/2 为上弦，π 为望，3π/2 为下弦。
/// nearJdTT 为 TT 儒略日，默认 mid。moonLatitudeTerms 可在 mid 下设为
/// 0～277 或 'full'；省略为 10 项，fast 固定 10 项，accurate 固定全量。
///
/// 历史归日不改变返回的天文时刻。toleranceSeconds 为数值收敛阈值（秒），
/// 不是绝对天文精度；fast 仅支持默认求解策略和固定阶段。
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

/// 求 [nearJdTT] 附近最近一次朔的天文时刻。
///
/// 等价于目标角为 0 的 [solveLunarPhase]，精度、黄纬预算和求解选项相同。
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
