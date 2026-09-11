import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final near = ZonedTime(
    year: 2026,
    month: 6,
    day: 21,
    hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();
  final solstice = solveSolarLongitude(
    math.pi / 2,
    near.jdTT,
    accuracy: Accuracy.accurate,
  );
  print('Solstice UTC+8: ${solstice.toZonedTime(480).toJson()}');
  print('Delta-T [s]: ${solstice.deltaTSeconds}');
  print('EOT [s]: ${equationOfTime(solstice).equationSeconds}');
  final clock = trueSolarTime(solstice, 116.4074);
  print('Apparent solar clock: ${clock.toJson()}');
  print('Original instant TT: ${clock.instant.jdTT}');
}
