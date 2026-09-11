import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final start = ZonedTime(
    year: 2025,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime();
  final end = ZonedTime(
    year: 2026,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime();
  const site = Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042);
  for (final eclipse in searchLunarEclipses(start, end)) {
    print('Global maximum: ${eclipse.maximum.toZonedTime(480).toJson()}');
    final local = getLocalLunarEclipse(eclipse.maximum, site);
    print(local?.toJson());
  }
}
