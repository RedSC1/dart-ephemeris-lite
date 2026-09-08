import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final clock = ZonedTime(
    year: 2003,
    month: 3,
    day: 13,
    hour: 11,
    offsetMinutes: 480,
  );
  final pillars = fourPillarsForZonedTime(
    clock,
    options: CalendarOptions(mode: CalendarMode.chinaAstronomical),
    ratHourMode: RatHourMode.nextDay,
  );
  print(describeFourPillars(pillars));
  for (final era in getChineseEraNames(clock.toJulianTime().jdUT1)) {
    print('${era.text} (${era.precision.name}, ${era.boundarySource})');
  }
}
