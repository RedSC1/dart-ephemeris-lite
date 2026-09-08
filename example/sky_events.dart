import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final start = ZonedTime(
    year: 2026,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime().jdTT;
  final end = ZonedTime(
    year: 2027,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime().jdTT;
  for (final station in searchStations(SkyBody.mercury, start, end)) {
    print(
      '${station.time.toZonedTime(480).toJson()} ${station.direction.name}',
    );
  }
  print(moonIllumination(start).toJson());
}
