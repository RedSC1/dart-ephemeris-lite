import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final angle = 4.9 + DateTime.now().millisecond / 1000000;
  print(solarLongitudeTimeAccurate(angle));
  print(lunarPhaseTimeAccurate(angle));
}
