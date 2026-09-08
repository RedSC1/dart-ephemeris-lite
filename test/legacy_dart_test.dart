// Scenarios ported from sxwnl_spa_dart's precision and moon-phase tests.
// Retain behavioral expectations, not values tied to the retired ephemeris.
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

extension on CalendarSolarTerm {
  String get name => solarTermNames[(indexFromWinterSolstice + 18) % 24];
}

void main() {
  test('legacy day-pillar anchors and exact 13:00 branch transition', () {
    for (final r in [
      (2000, 1, 1, '戊午'),
      (2000, 1, 2, '己未'),
      (2026, 2, 17, '壬戌'),
      (2024, 2, 10, '甲辰'),
    ]) {
      expect(
        ganzhiName(
          calculateDayPillar(CalendarDate(year: r.$1, month: r.$2, day: r.$3)),
        ),
        r.$4,
      );
    }
    for (final second in [0.0, .0001]) {
      final clock = ZonedTime(
        year: 2026,
        month: 4,
        day: 8,
        hour: 13,
        second: second,
        offsetMinutes: 480,
      );
      expect(ganzhiBranch(fourPillarsForZonedTime(clock).hour), 7);
    }
    final before = ZonedTime(
      year: 2026,
      month: 4,
      day: 8,
      hour: 12,
      minute: 59,
      second: 59.999,
      offsetMinutes: 480,
    );
    expect(ganzhiBranch(fourPillarsForZonedTime(before).hour), 6);
  });
  test(
    'legacy solar-term exact boundary, epoch, negative slots and filters',
    () {
      final lichun = getSpecificSolarTerm(2025, 21);
      expect(getPreviousSolarTerm(lichun.time.jdUT1).name, '立春');
      expect(
        getPreviousSolarTerm(lichun.time.jdUT1).time.jdTT,
        lichun.time.jdTT,
      );
      expect(getNextSolarTerm(lichun.time.jdUT1).name, '雨水');
      final epoch = julianDay(year: 2000, month: 1, day: 1) - 1 / 3;
      expect(getPreviousSolarTerm(epoch).name, '冬至');
      expect(getNextSolarTerm(epoch).name, '小寒');
      final ancient = julianDay(year: -1999, month: 6, day: 1);
      expect(
        getPreviousSolarTerm(ancient).time.jdUT1,
        lessThanOrEqualTo(ancient),
      );
      expect(getNextSolarTerm(ancient).time.jdUT1, greaterThan(ancient));
      final august = julianDay(year: 2027, month: 8, day: 15);
      final previous = getPreviousSolarTerm(august),
          next = getNextSolarTerm(august);
      expect(previous.name, '立秋');
      expect(getNextSolarTerm(previous.time.jdUT1).name, '处暑');
      expect(getPreviousSolarTerm(next.time.jdUT1).time.jdTT, next.time.jdTT);
      final march = julianDay(year: 2025, month: 3, day: 1);
      expect(getPreviousJie(march).name, '立春');
      expect(getPreviousQi(march).name, '雨水');
      expect(
        getPreviousSolarTerm(julianDay(year: 2026, month: 1, day: 3)).name,
        '冬至',
      );
      expect(
        getPreviousSolarTerm(julianDay(year: 2026, month: 7, day: 4)).name,
        '夏至',
      );
    },
  );
  test('legacy BCE and reform-period solar/lunar round trips', () {
    for (final date in [
      const CalendarDate(year: -456, month: 4, day: 4, hour: 12, minute: 48),
      const CalendarDate(year: 10, month: 6, day: 1, hour: 12),
      const CalendarDate(year: 238, month: 6, day: 1, hour: 12),
      const CalendarDate(year: 690, month: 6, day: 1, hour: 12),
    ]) {
      final lunar = solarToLunar(date), back = lunarToSolar(lunar);
      expect(
        [back.year, back.month, back.day],
        [date.year, date.month, date.day],
      );
      if (date.year == -456) {
        expect([lunar.historicalYear, lunar.month, lunar.day], [-456, 5, 12]);
      }
    }
  });
  test(
    'legacy cross-year months resolve all days, and PMO 2026 month sizes',
    () {
      for (final pair in [
        (-100, 1),
        (-100, 10),
        (-456, 5),
        (2025, 11),
        (2025, 12),
        for (var m = 1; m <= 12; m++) (2026, m),
      ]) {
        final date = LunarDate(year: pair.$1, month: pair.$2, day: 1);
        final start = lunarToSolar(date), lunar = solarToLunar(start);
        expect(
          [lunar.historicalYear, lunar.month, lunar.day, lunar.isLeap],
          [pair.$1, pair.$2, 1, false],
        );
        if (pair.$1 == 2026) {
          expect(
            lunar.monthDays,
            [30, 29, 30, 29, 29, 30, 29, 29, 30, 30, 30, 29][pair.$2 - 1],
          );
        }
        if (pair.$1 == 2025) {
          for (var day = 1; day <= lunar.monthDays; day++) {
            final back = solarToLunar(
              lunarToSolar(LunarDate(year: 2025, month: pair.$2, day: day)),
            );
            expect(
              [back.historicalYear, back.month, back.day],
              [2025, pair.$2, day],
            );
          }
        }
      }
    },
  );
  test(
    'legacy historical term toggle changes assigned days, not astronomical instants',
    () {
      var changed = false;
      for (var year = 1645; year <= 1700; year++) {
        final h = getQiShuoYear(year, lunarPhaseAnglesDeg: []).events;
        final a = getQiShuoYear(
          year,
          lunarPhaseAnglesDeg: [],
          options: CalendarOptions(mode: CalendarMode.chinaAstronomical),
        ).events;
        expect(h.length, a.length);
        for (var i = 0; i < h.length; i++) {
          expect(h[i].time.jdTT, a[i].time.jdTT);
          changed |= h[i].assignedCivilDayNumber != a[i].assignedCivilDayNumber;
        }
      }
      expect(changed, isTrue);
    },
  );
  test('native Dart calendar and Julian-date frozen oracles', () {
    for (final r in [
      (2000, 1, 1, 12, 0, 0.0, 2451545.0),
      (2024, 4, 8, 18, 17, 20.0, 2460409.262037037),
      (1990, 4, 20, 6, 0, 0.0, 2448001.75),
    ]) {
      final jd = julianDay(
        year: r.$1,
        month: r.$2,
        day: r.$3,
        hour: r.$4,
        minute: r.$5,
        second: r.$6,
      );
      expect(jd, closeTo(r.$7, 1e-9));
      final back = calendarDateFromJulianDay(jd);
      expect(
        [back.year, back.month, back.day, back.hour, back.minute],
        [r.$1, r.$2, r.$3, r.$4, r.$5],
      );
      expect(back.second, closeTo(r.$6, 1e-5));
    }
  });
  test(
    'Dart DateTime retains sub-millisecond input within double JD resolution',
    () {
      for (final date in [
        DateTime.utc(2025, 1, 1, 12, 34, 56, 123, 456),
        DateTime.utc(1969, 12, 31, 23, 59, 59, 123, 456),
        DateTime.utc(2000, 1, 1, 12),
      ]) {
        final actual = JulianTime.fromDateTime(date).toDateTime();
        // A double JD near this epoch has an approximately 40 microsecond ULP.
        expect(
          actual.difference(date).inMicroseconds.abs(),
          lessThanOrEqualTo(25),
        );
        expect(actual.isUtc, isTrue);
        final zoned = ZonedTime.fromDateTime(date, offsetMinutes: 480);
        expect(
          zoned.toDateTime().difference(date).inMicroseconds.abs(),
          lessThanOrEqualTo(25),
        );
      }
    },
  );
  test('legacy principal-phase annual counts and chronological order', () {
    final phases = getQiShuoYear(
      2026,
      includeSolarTerms: false,
      lunarPhaseAnglesDeg: [0, 90, 180, 270],
    ).events;
    expect(phases, hasLength(50));
    for (final pair in [('朔', 12), ('上弦', 12), ('望', 13), ('下弦', 13)]) {
      expect(phases.where((p) => p.name == pair.$1), hasLength(pair.$2));
    }
    for (var i = 1; i < phases.length; i++) {
      expect(phases[i].time.jdTT, greaterThan(phases[i - 1].time.jdTT));
    }
    expect(phases.first.name, '望');
    expect(phases.last.name, '下弦');
    expect(phases.where((p) => p.localDate.month == 1), hasLength(4));
    final eight = getQiShuoYear(
      2026,
      includeSolarTerms: false,
      lunarPhaseAnglesDeg: [0, 45, 90, 135, 180, 225, 270, 315],
    ).events;
    expect(eight, hasLength(99));
  });
}
