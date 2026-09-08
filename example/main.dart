import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final time = ZonedTime(
    year: 2000,
    month: 1,
    day: 1,
    hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();
  final earth = earthState(time.jdTT, accuracy: Accuracy.accurate);
  final moon = moonState(time.jdTT, accuracy: Accuracy.mid);
  print('TT: ${time.jdTT}; Delta-T: ${time.deltaTSeconds} s');
  print('Earth heliocentric J2000 [AU]: ${earth.position}');
  print('Moon geocentric J2000 [km]: ${moon.position}');
}
