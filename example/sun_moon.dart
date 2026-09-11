import 'package:ephemeris_lite/sun_moon.dart';

void main() {
  const jdTT = 2451545.0;
  final earth = earthState(jdTT, accuracy: Accuracy.mid);
  final moon = moonState(jdTT, accuracy: Accuracy.fast);
  print('Earth [AU]: ${earth.position}');
  print('Moon [km]: ${moon.position}');
}
