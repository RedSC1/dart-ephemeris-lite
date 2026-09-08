import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

CalendarOptions options(Map o) => CalendarOptions(
  mode:
      const {
        'historical': CalendarMode.historical,
        'china-astronomical': CalendarMode.chinaAstronomical,
        'local-astronomical': CalendarMode.localAstronomical,
      }[o['mode']] ??
      CalendarMode.historical,
  eventAccuracy: Accuracy.values.byName(o['eventAccuracy'] ?? 'mid'),
  utcOffsetMinutes: (o['utcOffsetMinutes'] as num?)?.toDouble() ?? 480,
  dayBoundaryMode: o['dayBoundaryMode'] == 'mean-solar-meridian'
      ? CalendarDayBoundaryMode.meanSolarMeridian
      : CalendarDayBoundaryMode.fixedUtcOffset,
  meridianDeg: (o['meridianDeg'] as num?)?.toDouble(),
);
CalendarDate date(Map d) =>
    CalendarDate(year: d['year'], month: d['month'], day: d['day']);
Map<String, int> ymd(CalendarDate d) => {
  'year': d.year,
  'month': d.month,
  'day': d.day,
};
void checkEvent(CalendarNewMoon a, Map e) {
  expect(a.civilDayNumber, e['civilDayNumber']);
  expect((a.time.jdTT - e['time']['jdTT']).abs() * 86400, lessThan(0.002));
  if (a is CalendarSolarTerm) {
    expect(a.indexFromWinterSolstice, e['indexFromWinterSolstice']);
    expect(a.targetLongitude, closeTo(e['targetLongitude'], 1e-14));
  }
}

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/lunar.json').readAsStringSync()) as Map;
  test(
    'calendar windows preserve month sequence, reform labels and events',
    () {
      final seen = <MonthName>{};
      var has28 = false;
      for (final row in fixture['windows']) {
        final a = calculateChineseCalendarYear(
              (row['jd'] as num).toDouble(),
              options: options(row['options']),
            ),
            e = row['result'];
        expect(a.solarTerms.length, 25);
        expect(a.newMoons.length, 15);
        expect(a.months.length, 14);
        expect(a.leapMonthIndex, e['leapMonthIndex']);
        expect(
          a.firstWinterSolsticeDayNumber,
          e['firstWinterSolsticeDayNumber'],
        );
        expect(
          a.secondWinterSolsticeDayNumber,
          e['secondWinterSolsticeDayNumber'],
        );
        for (var i = 0; i < 25; i++) {
          checkEvent(a.solarTerms[i], e['solarTerms'][i]);
        }
        for (var i = 0; i < 15; i++) {
          checkEvent(a.newMoons[i], e['newMoons'][i]);
        }
        for (var i = 0; i < 14; i++) {
          final m = a.months[i], n = e['months'][i];
          expect(
            [
              m.lunarYear,
              m.historicalYear,
              m.month,
              m.isLeap,
              m.dayCount,
              m.monthName.index,
              m.monthBuildingBranch,
              m.firstCivilDayNumber,
            ],
            [
              n['lunarYear'],
              n['historicalYear'],
              n['month'],
              n['isLeap'],
              n['dayCount'],
              n['monthName'],
              n['monthBuildingBranch'],
              n['firstCivilDayNumber'],
            ],
            reason: '${row['jd']} month $i',
          );
          expect(identical(m.newMoon, a.newMoons[i].time), isTrue);
          seen.add(m.monthName);
          has28 |= m.dayCount == 28;
        }
        expect(() => a.months.clear(), throwsUnsupportedError);
      }
      expect(seen, containsAll(MonthName.values));
      expect(has28, isTrue);
    },
  );
  test(
    'solar/lunar conversion and month lengths match JS across month boundaries',
    () {
      for (final row in fixture['dates']) {
        final o = options(row['options']), d = date(row['date']);
        if (row['error'] != null) {
          expect(() => solarToLunar(d, options: o), throwsRangeError);
          continue;
        }
        final lunar = solarToLunar(d, options: o);
        expect(lunar.toJson(), row['lunar'], reason: '${row['date']}');
        if (row['reverseError'] != null) {
          expect(() => lunarToSolar(lunar, options: o), throwsRangeError);
        } else {
          expect(ymd(lunarToSolar(lunar, options: o)), row['solar']);
          // A separate audit below pins known upstream non-bijective rows;
          // the assertion above always compares the Dart result to JS.
        }
        if (row['monthError'] != null) {
          expect(
            () => getLunarMonthDays(
              lunar.year,
              lunar.month,
              isLeap: lunar.isLeap,
              options: o,
            ),
            throwsRangeError,
          );
        } else {
          expect(
            getLunarMonthDays(
              lunar.year,
              lunar.month,
              isLeap: lunar.isLeap,
              options: o,
            ),
            row['monthDays'],
          );
        }
      }
    },
  );
  test('known upstream historical round-trip limitations remain explicit', () {
    final ambiguous = (fixture['dates'] as List)
        .where(
          (row) =>
              row['solar'] != null &&
              (row['solar']['year'] != row['date']['year'] ||
                  row['solar']['month'] != row['date']['month'] ||
                  row['solar']['day'] != row['date']['day']),
        )
        .toList();
    expect(ambiguous.length, 24);
    expect(ambiguous.map((r) => r['date']['year']).toSet(), {-221, -220, 762});
    expect(
      (fixture['dates'] as List).where((r) => r['reverseError'] != null).length,
      2,
    );
    expect(
      (fixture['dates'] as List).where((r) => r['error'] != null).length,
      1,
    );
  });
  test(
    'instant conversion respects local clock and independent structure offset',
    () {
      for (final row in fixture['instants']) {
        expect(
          instantToLunar(
            (row['jd'] as num).toDouble(),
            options: options(row['options']),
          ).toJson(),
          row['result'],
        );
      }
    },
  );
  test(
    'specific terms and previous/next exact boundary semantics match JS',
    () {
      for (final row in fixture['terms']) {
        checkEvent(
          getSpecificSolarTerm(
            row['year'],
            row['index'],
            options: options(row['options']),
          ),
          row['result'],
        );
      }
      for (final row in fixture['searches']) {
        checkEvent(
          findSolarTerm(
            (row['jd'] as num).toDouble(),
            direction: SolarTermDirection.values.byName(row['direction']),
            filter: SolarTermFilter.values.byName(row['filter']),
          ),
          row['result'],
        );
      }
    },
  );
  test(
    'invalid dates, missing leap months and non-finite instants are rejected',
    () {
      for (final d in [
        const CalendarDate(year: 2026, month: 2, day: 30),
        const CalendarDate(year: 1582, month: 10, day: 10),
      ]) {
        expect(() => solarToLunar(d), throwsRangeError);
      }
      expect(
        () => lunarToSolar(
          const LunarDate(year: 2026, month: 1, day: 1, isLeap: true),
        ),
        throwsRangeError,
      );
      expect(
        () => lunarToSolar(const LunarDate(year: 2026, month: 14, day: 1)),
        throwsRangeError,
      );
      expect(() => getLunarMonthDays(2026, 0), throwsRangeError);
      expect(() => findSolarTerm(double.nan), throwsArgumentError);
      expect(
        () => calculateChineseCalendarYear(double.infinity),
        throwsArgumentError,
      );
      expect(() => getSpecificSolarTerm(2026, 24), throwsRangeError);
    },
  );
}
