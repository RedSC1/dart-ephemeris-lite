# Arithmetic Hijri calendar

[中文](hijri-calendar.md) | [English](hijri-calendar.en.md) · [Documentation](README.en.md)

## Runnable examples

[hijri_calendar.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/hijri_calendar.dart)

```sh
dart run example/hijri_calendar.dart
```

<!-- example: example/hijri_calendar.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final date = solarToHijri(const CalendarDate(year: 2000, month: 1, day: 1));
  print('Arithmetic Hijri: $date');
  print('Civil date: ${hijriToSolar(date).toJson()}');
  print(instantToHijri(JulianTime.fromUT1(2451545), offsetMinutes: 480));
}
```

## API and model

Use `solarToHijri`, `hijriToSolar` and `instantToHijri` for conversion, and `hijriMonthDays` / `isHijriLeapYear` for calendar rules. The implementation uses integer cycle arithmetic and supports conversion in both directions between civil dates and the arithmetic Hijri calendar.

## Rules and limits

- A 30-year cycle contains 10,631 days. Leap years are 2, 5, 7, 10, 13, 16, 18, 21, 24, 26 and 29. Odd months have 30 days, even months 29; the twelfth month gains a day in a leap year.
- Civil dates use the library's hybrid Julian/Gregorian calendar. The epoch 1 AH corresponds to 622-07-16 in that calendar. Civil conversion supports years −6000 through 10000. Missing dates at the 1582 reform and impossible month/day combinations throw rather than normalize.
- Zero and negative Hijri years are proleptic labels, not historical AH numbering.
- `solarToHijri(CalendarDate)` ignores clock fields. `hijriToSolar` returns a civil date with zero clock fields, not a zoned physical instant.
- `instantToHijri` requires a `JulianTime` and an explicit integer offset in minutes within ±14 hours. It uses fixed-offset midnight boundaries and UTC ≈ UT1, without an implicit Beijing offset, sunset boundary or daylight-saving rule.
- This is an arithmetic calendar, not local crescent observation, religious announcements or the Umm al-Qura table.
- `HijriDate` validates the actual month length and is immutable. Leap-year and month-length helpers accept Hijri years −10000 through 10000; conversion is additionally limited by the civil-date range.

This feature needs no ephemeris evaluation, network access, or external data table. See the third-party notices for attribution.
