# Historical calendars and lunar conversion

[中文](calendar-history.md) | [English](calendar-history.en.md) · [Documentation](README.en.md)

## Runnable examples

[calendar.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/calendar.dart)

```sh
dart run example/calendar.dart
```

<!-- example: example/calendar.dart -->
```dart
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
```

## Dates and instants

`calculateChineseCalendarYear(jdUT1)` builds a window around the preceding winter solstice: 25 solar terms, 15 new moons and 14 lunar months. An event's `time` is its astronomical instant; `civilDayNumber` is the date assigned by the selected calendar.

| Mode | Month construction |
| --- | --- |
| `CalendarMode.historical` | Historical civil-day profiles where available; astronomical assignment outside their coverage |
| `CalendarMode.chinaAstronomical` | Astronomical events assigned to UTC+8 dates |
| `CalendarMode.localAstronomical` | Astronomical events assigned using the selected offset or mean-solar meridian |

`solarToLunar(CalendarDate)` uses only year, month and day. `instantToLunar(jdUT1)` first resolves the date at the selected local day boundary. Use the same options when converting back with `lunarToSolar`. `getLunarMonthDays` distinguishes leap months and historical month names.

## Historical month and year labels

`MonthName` can be `normal`, `thirteen`, `laterNine`, `altTwelve`, `altOne` or `laterSameName`. Month names and `isLeap` are separate fields; a special name does not imply a leap month. The core returns a number and name code, not formatted Chinese month text.

- `lunarYear` / `LunarDate.year` is the source lunar-year label.
- `historicalYear` records the historical year used by the calendar and Ganzhi rules. It can differ around reforms.
- The documented 28-day month during the Jingchu reform is retained; historical months are not unconditionally forced to 29 or 30 days.

## Known reverse-lookup limitations

The current lookup selects the first matching lunar year, month, leap flag and name. It does not disambiguate repeated labels by `historicalYear`:

1. Civil date −221-10-31 converts to lunar year −221, historical year −220, month 10 day 1; reverse lookup returns −221-09-01.
2. Around the 762 reform, converting 762-04-29 and back returns 762-03-01.
3. At −721-12-07, the required window can extend before the historical profile and throw a range error.

These examples are not an exhaustive list of affected dates. Do not rely on reverse conversion in these reform windows for chart construction or historical data editing until the ambiguity has been resolved.

Era lookup shares these limits. For −456-06-01 at UT1 midnight, it throws `lunar date not found`; do not reinterpret that error as an empty list of active eras.
