import 'apparent_core.dart';
export 'apparent_core.dart' hide ApparentEvaluator;

final _evaluator = ApparentEvaluator(
  (body, jd, accuracy) =>
      throw ArgumentError.value(body, 'body', 'Expected Sun or Moon'),
);

/// 返回视位置修正链的中间向量，便于检查几何与光行时修正。
///
/// 输入为 TT 儒略日，各位置向量为 AU。
ApparentGeometry apparentGeometry(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) => _evaluator.apparentGeometry(body, jdTT, options: options);

/// 计算 [jdTT]（TT 儒略日）时刻的地心视位置。
///
/// 返回角度为度、距离为 AU；参考系与修正由 ApparentOptions 控制。
ApparentPosition apparentBodyPosition(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) => _evaluator.apparentBodyPosition(body, jdTT, options: options);

/// 计算地心视位置及完整修正链的差分速度。
///
/// 输入为 TT 儒略日，返回角速度为度/日、线速度为 AU/day。
ApparentState apparentBodyState(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) => _evaluator.apparentBodyState(body, jdTT, options: options);
