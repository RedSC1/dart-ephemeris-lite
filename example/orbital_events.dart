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
  for (final event in searchLunarApsides(start, end)) {
    print(event.toJson());
  }
  for (final event in searchGreatestElongations(
    SkyBody.mercury,
    start,
    end,
    apparent: const ApparentOptions(accuracy: Accuracy.mid),
  )) {
    print(event.toJson());
  }
}
