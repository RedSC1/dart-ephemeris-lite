import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final date = ZonedTime(
    year: 2024,
    month: 4,
    day: 8,
    offsetMinutes: 0,
  ).toJulianTime();
  final global = getSolarEclipseDetails(date);
  if (global == null) {
    print('No solar eclipse in this lunation.');
    return;
  }
  print(global.toJson());
  final local = getLocalSolarEclipse(
    date,
    const Observer(longitudeDeg: -96.8, latitudeDeg: 32.8),
  );
  print(local?.toJson());
}
