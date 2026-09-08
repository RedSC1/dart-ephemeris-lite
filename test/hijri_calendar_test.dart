import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';
import 'hijri_support.dart';

void main() {
  test('shared JS and old Dart Hijri frozen fixtures', () {
    final f = jsonDecode(
      File('test/fixtures/hijri-calendar.json').readAsStringSync(),
    );
    for (final r in f['samples']) {
      final date = calendarDateFromJulianDay(2451545.0 + r['d0']);
      final actual = solarToHijri(date);
      expect(actual.toJson(), r['expected']);
      final back = hijriToSolar(actual);
      expect(
        julianDay(year: back.year, month: back.month, day: back.day, hour: 12),
        2451545 + r['d0'],
      );
    }
  });
  test(
    'every day of five full cycles preserves legacy rules and reverse conversion',
    checkHijriCycles,
  );
  test('leap years, month ends and immutable date equality', () {
    expect(
      [
        for (var y = 1; y <= 30; y++)
          if (isHijriLeapYear(y)) y,
      ],
      [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29],
    );
    for (var year = -30; year <= 60; year++) {
      var days = 0;
      for (var month = 1; month <= 12; month++) {
        final length = hijriMonthDays(year, month);
        days += length;
        final date = HijriDate(year: year, month: month, day: length);
        expect(solarToHijri(hijriToSolar(date)), date);
        expect(date.hashCode, solarToHijri(hijriToSolar(date)).hashCode);
        expect(
          () => HijriDate(year: year, month: month, day: length + 1),
          throwsRangeError,
        );
      }
      expect(days, isHijriLeapYear(year) ? 355 : 354);
      expect(isHijriLeapYear(year), isHijriLeapYear(year + 30));
    }
  });
  test('explicit timezone and midnight boundary, not sunset', () {
    final before = JulianTime.fromUT1(
      julianDay(year: 2000, month: 1, day: 1, hour: 15, minute: 59, second: 59),
    );
    final boundary = JulianTime.fromUT1(
      julianDay(year: 2000, month: 1, day: 1, hour: 16),
    );
    expect(
      instantToHijri(before, offsetMinutes: 480),
      HijriDate(year: 1420, month: 9, day: 24),
    );
    expect(
      instantToHijri(boundary, offsetMinutes: 480),
      HijriDate(year: 1420, month: 9, day: 25),
    );
    expect(
      instantToHijri(boundary, offsetMinutes: 0),
      HijriDate(year: 1420, month: 9, day: 24),
    );
    for (final offset in [-840, -300, 0, 330, 480, 840]) {
      expect(
        instantToHijri(boundary, offsetMinutes: offset),
        solarToHijri(boundary.toZonedTime(offset)),
      );
    }
    for (final offset in [-841, 841]) {
      expect(
        () => instantToHijri(boundary, offsetMinutes: offset),
        throwsArgumentError,
      );
    }
  });
  test('civil gaps, invalid dates and support edges', () {
    for (final date in [
      const CalendarDate(year: 2026, month: 2, day: 30),
      const CalendarDate(year: 1582, month: 10, day: 10),
      const CalendarDate(year: 2000, month: 0, day: 1),
      const CalendarDate(year: -6001, month: 1, day: 1),
      const CalendarDate(year: 10001, month: 1, day: 1),
    ]) {
      expect(() => solarToHijri(date), throwsArgumentError);
    }
    for (final year in [-6000, 0, 10000]) {
      for (final pair in [(1, 1), (12, 31)]) {
        final date = CalendarDate(year: year, month: pair.$1, day: pair.$2),
            back = hijriToSolar(solarToHijri(date));
        expect(
          [back.year, back.month, back.day],
          [date.year, date.month, date.day],
        );
      }
    }
    expect(() => HijriDate(year: 1, month: 2, day: 30), throwsRangeError);
    expect(() => HijriDate(year: 1, month: 12, day: 30), throwsRangeError);
    expect(() => HijriDate(year: 2, month: 13, day: 1), throwsRangeError);
    expect(() => isHijriLeapYear(10001), throwsRangeError);
  });
}
