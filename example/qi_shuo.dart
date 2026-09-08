import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final table = getQiShuoYear(
    2026,
    options: CalendarOptions(mode: CalendarMode.historical),
    lunarPhaseAnglesDeg: [0, 90, 180, 270],
  );
  for (final event in table.events) {
    print('${event.name}: ${event.localTime.toJson()}');
    print(event.assignedDate.toJson());
  }
}
