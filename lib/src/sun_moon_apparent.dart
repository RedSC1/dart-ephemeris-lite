import 'apparent_core.dart';
export 'apparent_core.dart' hide ApparentEvaluator;

final _evaluator = ApparentEvaluator(
  (body, jd, accuracy) =>
      throw ArgumentError.value(body, 'body', 'Expected Sun or Moon'),
);

ApparentGeometry apparentGeometry(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) => _evaluator.apparentGeometry(body, jdTT, options: options);
ApparentPosition apparentBodyPosition(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) => _evaluator.apparentBodyPosition(body, jdTT, options: options);
ApparentState apparentBodyState(
  SkyBody body,
  double jdTT, {
  ApparentOptions options = const ApparentOptions(),
}) => _evaluator.apparentBodyState(body, jdTT, options: options);
