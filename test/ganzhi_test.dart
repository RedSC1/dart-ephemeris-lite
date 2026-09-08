import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

CalendarDate _clock(Map c) => CalendarDate(
  year: c['year'],
  month: c['month'],
  day: c['day'],
  hour: c['hour'],
  minute: c['minute'],
  second: (c['second'] as num).toDouble(),
);
CalendarOptions _options(Map o) => CalendarOptions(
  mode: o['mode'] == 'china-astronomical'
      ? CalendarMode.chinaAstronomical
      : CalendarMode.historical,
  eventAccuracy: Accuracy.values.byName(o['eventAccuracy'] ?? 'mid'),
);
RatHourMode _rat(String? value) => switch (value) {
  'current-day' => RatHourMode.currentDay,
  'current-day-tomorrow-stem' => RatHourMode.currentDayTomorrowStem,
  _ => RatHourMode.nextDay,
};
PillarHistoricalMode _historical(String? value) => switch (value) {
  'on' => PillarHistoricalMode.on,
  'off' => PillarHistoricalMode.off,
  _ => PillarHistoricalMode.followCalendar,
};
void main() {
  final f =
      jsonDecode(File('test/fixtures/ganzhi.json').readAsStringSync()) as Map;
  test('60 packed Ganzhi values, Nayin and signed advancement', () {
    for (var i = 0; i < 60; i++) {
      final g = makeGanzhi(i % 10, i % 12);
      expect(ganzhiIndex(g), i);
      expect(ganzhiStem(g), i % 10);
      expect(ganzhiBranch(g), i % 12);
      expect(
        ganzhiName(g),
        '${heavenlyStems[i % 10]}${earthlyBranches[i % 12]}',
      );
      expect(getNayinId(g), i ~/ 2);
      expect(
        getNayinElement(g),
        getNayinElement(advanceGanzhi(g, i.isEven ? 1 : -1)),
      );
      expect(advanceGanzhi(g, -121), advanceGanzhi(g, 59));
    }
    expect(getNayinElement(makeGanzhi(0, 0)), Wuxing.metal);
    expect(() => makeGanzhi(0, 1), throwsRangeError);
    expect(() => ganzhiStem(255), throwsRangeError);
    expect(() => getHourGanzhi(10, 0), throwsRangeError);
    expect(() => getMonthGanzhi(0, 12), throwsRangeError);
  });
  test('four pillars preserve rat-hour and historical term options', () {
    for (final row in f['rows']) {
      final o = row['options'];
      final result = calculateFourPillars(
        (row['jd'] as num).toDouble(),
        _clock(row['clock']),
        options: _options(o),
        ratHourMode: _rat(o['ratHourMode']),
        pillarHistoricalMode: _historical(o['pillarHistoricalMode']),
      );
      expect(result.toJson(), row['result'], reason: '${row['clock']} $o');
      expect(describeFourPillars(result)['year'], ganzhiName(result.year));
    }
  });
  test(
    'normalization preserves genuine sub-hour input and exact JD spellings',
    () {
      for (final row in f['normalizations']) {
        expect(
          normalizeChartVirtualTime(_clock(row['clock'])).toJson(),
          row['result'],
        );
      }
      expect(
        () => normalizeChartVirtualTime(
          const CalendarDate(year: 2026, month: 2, day: 30),
        ),
        throwsRangeError,
      );
      expect(
        () => calculateFourPillars(
          double.nan,
          const CalendarDate(year: 2026, month: 1, day: 1),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'mean and apparent solar clocks use the same physical-instant contract',
    () {
      for (final row in f['solar']) {
        final jd = (row['jd'] as num).toDouble(),
            longitude = (row['longitude'] as num).toDouble();
        final clock = row['kind'] == 'mean'
            ? meanSolarTime(jd, longitude)
            : trueSolarTime(jd, longitude);
        expect(
          calculateFourPillars(
            jd,
            clock,
            options: CalendarOptions(mode: CalendarMode.chinaAstronomical),
          ).toJson(),
          row['result'],
        );
      }
      final clock = ZonedTime(
        year: 2026,
        month: 4,
        day: 8,
        hour: 23,
        offsetMinutes: 480,
      );
      final next = fourPillarsForZonedTime(clock),
          current = fourPillarsForZonedTime(
            clock,
            ratHourMode: RatHourMode.currentDay,
          );
      expect(next.day, advanceGanzhi(current.day, 1));
      expect(calculateDayPillar(clock), current.day);
    },
  );
}
