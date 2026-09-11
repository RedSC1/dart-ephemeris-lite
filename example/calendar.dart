import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final options = CalendarOptions(mode: CalendarMode.chinaAstronomical);
  final lunar = solarToLunar(
    const CalendarDate(year: 2033, month: 12, day: 22),
    options: options,
  );
  print(lunar.toJson());
  print(lunarToSolar(lunar, options: options).toJson());

  final table = getQiShuoYear(
    2026,
    options: CalendarOptions(mode: CalendarMode.historical),
    lunarPhaseAnglesDeg: [0, 90, 180, 270],
  );
  final event = table.events.first;
  print('Actual local time: ${event.localTime.toJson()}');
  print('Calendar date: ${event.assignedDate.toJson()}');
}
