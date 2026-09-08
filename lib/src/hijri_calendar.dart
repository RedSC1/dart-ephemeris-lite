// Arithmetic Hijri rules compatible with Shou Xing oba.getHuiLi().
// Integer cycle arithmetic and reverse conversion; see doc/hijri-calendar.md.
import 'time.dart';

const _epochDay = 1948440, _cycleDays = 10631;
int _yearStart(int n) => 354 * n + ((11 * n + 14) / 30).floor();
int _monthStart(int n) => 29 * n + (n + 1) ~/ 2;
void _validateYear(int year) {
  if (year.abs() > 10000) {
    throw RangeError('Hijri year must be within -10000..10000');
  }
}

bool isHijriLeapYear(int year) {
  _validateYear(year);
  final n = (year - 1) % 30;
  return _yearStart(n + 1) - _yearStart(n) == 355;
}

int hijriMonthDays(int year, int month) {
  _validateYear(year);
  if (month < 1 || month > 12) {
    throw RangeError('Hijri month must be within 1..12');
  }
  return month == 12
      ? (isHijriLeapYear(year) ? 30 : 29)
      : (month.isOdd ? 30 : 29);
}

/// Arithmetic Hijri date. Nonpositive years are proleptic, not historical AH.
class HijriDate {
  final int year, month, day;
  HijriDate({required this.year, required this.month, required this.day}) {
    final length = hijriMonthDays(year, month);
    if (day < 1 || day > length) {
      throw RangeError('Invalid day in the arithmetic Hijri month');
    }
  }
  Map<String, int> toJson() => {'year': year, 'month': month, 'day': day};
  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;
  @override
  int get hashCode => Object.hash(year, month, day);
  @override
  String toString() => '$year-$month-$day AH';
}

int _civilDay(CalendarDate date) {
  if (date.year < -6000 || date.year > 10000) {
    throw RangeError('Civil year must be within -6000..10000');
  }
  // Date-only API: validate date fields without interpreting the supplied clock.
  ZonedTime(
    year: date.year,
    month: date.month,
    day: date.day,
    hour: 12,
    offsetMinutes: 0,
  );
  return (julianDay(
            year: date.year,
            month: date.month,
            day: date.day,
            hour: 12,
          ) +
          .5)
      .floor();
}

HijriDate _fromDay(int dayNumber) {
  final days = dayNumber - _epochDay, cycle = (days / _cycleDays).floor();
  final inCycle = days - cycle * _cycleDays;
  var n = (inCycle ~/ 354).clamp(0, 29);
  if (_yearStart(n) > inCycle) n--;
  final dayOfYear = inCycle - _yearStart(n);
  final month = ((dayOfYear / 29.5).floor() + 1).clamp(1, 12);
  return HijriDate(
    year: cycle * 30 + n + 1,
    month: month,
    day: dayOfYear - _monthStart(month - 1) + 1,
  );
}

/// Hybrid Julian/Gregorian civil date -> arithmetic Hijri; clock fields ignored.
/// Supports civil years -6000..10000, with no implicit timezone.
HijriDate solarToHijri(CalendarDate date) => _fromDay(_civilDay(date));

/// Arithmetic Hijri -> hybrid Julian/Gregorian civil date, not an instant.
CalendarDate hijriToSolar(HijriDate date) {
  final cycle = ((date.year - 1) / 30).floor(), n = date.year - 1 - cycle * 30;
  final dayNumber =
      _epochDay +
      cycle * _cycleDays +
      _yearStart(n) +
      _monthStart(date.month - 1) +
      date.day -
      1;
  final result = calendarDateFromJulianDay(dayNumber - .5);
  _civilDay(result);
  return result;
}

/// An instant with a required fixed offset (±14 hours); midnight day boundary.
HijriDate instantToHijri(JulianTime time, {required int offsetMinutes}) =>
    solarToHijri(time.toZonedTime(offsetMinutes));
