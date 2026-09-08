import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  const site = Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042);
  final date = ZonedTime(year: 2026, month: 6, day: 21, offsetMinutes: 480);
  final solar = solarRiseSetForDate(date, site);
  print('Sun: ${solar.altitudeState.name}');
  print(solar.rise?.toZonedTime(480).toJson());
  final moon = bodyRiseSetForDay(SkyBody.moon, date.toJulianTime().jdUT1, site);
  for (final rise in moon.rises) {
    print(rise.toZonedTime(480).toJson());
  }
}
