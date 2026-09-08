// GENERATED from JS oracle fixtures.
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  {
    final a = calculateFourPillars(
      1554575.1666666667,
      CalendarDate(
        year: -456,
        month: 3,
        day: 13,
        hour: 0,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 8 || a.month != 51 || a.day != 81 || a.hour != 0) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      1683143.1666666667,
      CalendarDate(
        year: -104,
        month: 3,
        day: 13,
        hour: 0,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.currentDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 32 || a.month != 115 || a.day != 49 || a.hour != 96) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      1721129.1666666667,
      CalendarDate(year: 0, month: 3, day: 13, hour: 0, minute: 0, second: 0),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.currentDayTomorrowStem,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 104 || a.month != 83 || a.day != 151 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      1973151.625,
      CalendarDate(
        year: 690,
        month: 3,
        day: 13,
        hour: 11,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 98 || a.month != 83 || a.day != 21 || a.hour != 134) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2298954.625,
      CalendarDate(
        year: 1582,
        month: 3,
        day: 13,
        hour: 11,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.currentDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 134 || a.month != 147 || a.day != 72 || a.hour != 70) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415091.625,
      CalendarDate(
        year: 1900,
        month: 3,
        day: 13,
        hour: 11,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.currentDayTomorrowStem,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 96 || a.month != 83 || a.day != 25 || a.hour != 134) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2452712.083333333,
      CalendarDate(
        year: 2003,
        month: 3,
        day: 13,
        hour: 22,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 151 || a.month != 19 || a.day != 25 || a.hour != 59) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461113.083333333,
      CalendarDate(
        year: 2026,
        month: 3,
        day: 13,
        hour: 22,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.currentDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 115 || a.day != 42 || a.hour != 91) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2816859.083333333,
      CalendarDate(
        year: 3000,
        month: 3,
        day: 13,
        hour: 22,
        minute: 0,
        second: 0,
      ),
      options: CalendarOptions(
        mode: CalendarMode.historical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.currentDayTomorrowStem,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 104 || a.month != 83 || a.day != 132 || a.hour != 123) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415054.1666608793,
      CalendarDate(
        year: 1900,
        month: 2,
        day: 3,
        hour: 23,
        minute: 59,
        second: 59.499982595443726,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.fast,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.off,
    );
    if (a.year != 91 || a.month != 49 || a.day != 72 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415084.5151738157,
      CalendarDate(
        year: 1900,
        month: 3,
        day: 6,
        hour: 8,
        minute: 21,
        second: 51.01768612861633,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.fast,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.on,
    );
    if (a.year != 96 || a.month != 83 || a.day != 66 || a.hour != 36) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415084.1666724537,
      CalendarDate(
        year: 1900,
        month: 3,
        day: 6,
        hour: 0,
        minute: 0,
        second: 0.5000174045562744,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.fast,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 96 || a.month != 66 || a.day != 66 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415114.1666666665,
      CalendarDate(year: 1900, month: 4, day: 5, hour: 0, minute: 0, second: 0),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.fast,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.off,
    );
    if (a.year != 96 || a.month != 83 || a.day != 72 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415054.744095595,
      CalendarDate(
        year: 1900,
        month: 2,
        day: 4,
        hour: 13,
        minute: 51,
        second: 29.859429001808167,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.on,
    );
    if (a.year != 96 || a.month != 66 || a.day != 72 || a.hour != 87) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415084.515155294,
      CalendarDate(
        year: 1900,
        month: 3,
        day: 6,
        hour: 8,
        minute: 21,
        second: 49.41741317510605,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 96 || a.month != 66 || a.day != 66 || a.hour != 36) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415084.1666724537,
      CalendarDate(
        year: 1900,
        month: 3,
        day: 6,
        hour: 0,
        minute: 0,
        second: 0.5000174045562744,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.off,
    );
    if (a.year != 96 || a.month != 66 || a.day != 66 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415114.1666608793,
      CalendarDate(
        year: 1900,
        month: 4,
        day: 4,
        hour: 23,
        minute: 59,
        second: 59.499982595443726,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.on,
    );
    if (a.year != 96 || a.month != 83 || a.day != 72 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415054.744091263,
      CalendarDate(
        year: 1900,
        month: 2,
        day: 4,
        hour: 13,
        minute: 51,
        second: 29.48514014482498,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.accurate,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 96 || a.month != 66 || a.day != 72 || a.hour != 87) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415084.5151566234,
      CalendarDate(
        year: 1900,
        month: 3,
        day: 6,
        hour: 8,
        minute: 21,
        second: 49.53227877616882,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.accurate,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.off,
    );
    if (a.year != 96 || a.month != 66 || a.day != 66 || a.hour != 36) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415084.1666666665,
      CalendarDate(year: 1900, month: 3, day: 6, hour: 0, minute: 0, second: 0),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.accurate,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.on,
    );
    if (a.year != 96 || a.month != 83 || a.day != 66 || a.hour != 128) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2415114.7449042243,
      CalendarDate(
        year: 1900,
        month: 4,
        day: 5,
        hour: 13,
        minute: 52,
        second: 39.724992513656616,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.accurate,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 96 || a.month != 100 || a.day != 72 || a.hour != 87) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461075.334814935,
      CalendarDate(
        year: 2026,
        month: 2,
        day: 4,
        hour: 4,
        minute: 2,
        second: 8.010396659374237,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.fast,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.off,
    );
    if (a.year != 38 || a.month != 98 || a.day != 89 || a.hour != 34) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461105.0826355196,
      CalendarDate(
        year: 2026,
        month: 3,
        day: 5,
        hour: 21,
        minute: 58,
        second: 59.708903431892395,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.fast,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.on,
    );
    if (a.year != 38 || a.month != 115 || a.day != 66 || a.hour != 155) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461075.3348108395,
      CalendarDate(
        year: 2026,
        month: 2,
        day: 4,
        hour: 4,
        minute: 2,
        second: 7.656546235084534,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 21 || a.month != 81 || a.day != 89 || a.hour != 34) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461105.082638124,
      CalendarDate(
        year: 2026,
        month: 3,
        day: 5,
        hour: 21,
        minute: 58,
        second: 59.93392735719681,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.off,
    );
    if (a.year != 38 || a.month != 115 || a.day != 66 || a.hour != 155) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461075.334808471,
      CalendarDate(
        year: 2026,
        month: 2,
        day: 4,
        hour: 4,
        minute: 2,
        second: 7.451920509338379,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.accurate,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.on,
    );
    if (a.year != 21 || a.month != 81 || a.day != 89 || a.hour != 34) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461105.082630007,
      CalendarDate(
        year: 2026,
        month: 3,
        day: 5,
        hour: 21,
        minute: 58,
        second: 59.23262357711792,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.accurate,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 115 || a.day != 66 || a.hour != 155) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461138.166666655,
      CalendarDate(
        year: 2026,
        month: 4,
        day: 7,
        hour: 23,
        minute: 59,
        second: 59.998994171619415,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 132 || a.day != 128 || a.hour != 96) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461138.333333333,
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 3,
        minute: 59,
        second: 59.999986588954926,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 132 || a.day != 128 || a.hour != 130) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461138.5000000116,
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 8,
        minute: 0,
        second: 0.0010192394256591797,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 132 || a.day != 128 || a.hour != 4) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461138.7083333214,
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 12,
        minute: 59,
        second: 59.99898076057434,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 132 || a.day != 128 || a.hour != 38) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461138.875,
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 17,
        minute: 0,
        second: 0.00001341104507446289,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 132 || a.day != 128 || a.hour != 89) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = calculateFourPillars(
      2461139.041666678,
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 21,
        minute: 0,
        second: 0.0010058283805847168,
      ),
      options: CalendarOptions(
        mode: CalendarMode.chinaAstronomical,
        eventAccuracy: Accuracy.mid,
      ),
      ratHourMode: RatHourMode.nextDay,
      pillarHistoricalMode: PillarHistoricalMode.followCalendar,
    );
    if (a.year != 38 || a.month != 132 || a.day != 128 || a.hour != 123) {
      throw StateError('Pillar parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 7,
        hour: 23,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 7 ||
        a.hour != 23 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(year: 2026, month: 4, day: 8, hour: 0, minute: 0, second: 0),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 0 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 0,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 0 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 0,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 0 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 0,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 1 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 1,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 1 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 1,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 1 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 2,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 2 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 2,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 2 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 2,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 2 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(year: 2026, month: 4, day: 8, hour: 3, minute: 0, second: 0),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 3 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 3,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 3 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 3,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 3 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 3,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 4 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 4,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 4 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 4,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 4 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 5,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 5 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 5,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 5 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 5,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 5 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(year: 2026, month: 4, day: 8, hour: 6, minute: 0, second: 0),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 6 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 6,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 6 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 6,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 6 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 6,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 7 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 7,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 7 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 7,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 7 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 8,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 8 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 8,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 8 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 8,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 8 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(year: 2026, month: 4, day: 8, hour: 9, minute: 0, second: 0),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 9 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 9,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 9 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 9,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 9 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 9,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 10 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 10,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 10 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 10,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 10 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 11,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 11 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 11,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 11 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 11,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 11 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 12,
        minute: 0,
        second: 0,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 12 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 12,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 12 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 12,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 12 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 12,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 13 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 13,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 13 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 13,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 13 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 14,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 14 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 14,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 14 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 14,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 14 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 15,
        minute: 0,
        second: 0,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 15 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 15,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 15 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 15,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 15 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 15,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 16 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 16,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 16 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 16,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 16 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 17,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 17 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 17,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 17 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 17,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 17 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 18,
        minute: 0,
        second: 0,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 18 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 18,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 18 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 18,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 18 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 18,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 19 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 19,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 19 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 19,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 19 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 20,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 20 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 20,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 20 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 20,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 20 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 21,
        minute: 0,
        second: 0,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 21 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 21,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 21 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 21,
        minute: 59,
        second: 59.99898076057434,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 21 ||
        a.minute != 59 ||
        a.second != 59.99898076057434) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 21,
        minute: 59,
        second: 59.999986588954926,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 22 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 22,
        minute: 0,
        second: 0.000992417335510254,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 22 ||
        a.minute != 0 ||
        a.second != 0.000992417335510254) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 22,
        minute: 59,
        second: 59.99900758266449,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 22 ||
        a.minute != 59 ||
        a.second != 59.99900758266449) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 23,
        minute: 0,
        second: 0.00001341104507446289,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 23 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 23,
        minute: 0,
        second: 0.0010192394256591797,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 23 ||
        a.minute != 0 ||
        a.second != 0.0010192394256591797) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 23,
        minute: 59,
        second: 59.998994171619415,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 23 ||
        a.minute != 59 ||
        a.second != 59.998994171619415) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(year: 2026, month: 4, day: 9, hour: 0, minute: 0, second: 0),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 9 ||
        a.hour != 0 ||
        a.minute != 0 ||
        a.second != 0) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 9,
        hour: 0,
        minute: 0,
        second: 0.0010058283805847168,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 9 ||
        a.hour != 0 ||
        a.minute != 0 ||
        a.second != 0.0010058283805847168) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = normalizeChartVirtualTime(
      CalendarDate(
        year: 2026,
        month: 4,
        day: 8,
        hour: 10,
        minute: 59,
        second: 59.99998,
      ),
    );
    if (a.year != 2026 ||
        a.month != 4 ||
        a.day != 8 ||
        a.hour != 10 ||
        a.minute != 59 ||
        a.second != 59.99998) {
      throw StateError('Clock normalization parity');
    }
  }
  {
    final a = getChineseEraNames(990709.5);
    if (a.length != 1) {
      throw StateError('Era count');
    }
    if (a[0].text != "[夏]太康 太康15年" ||
        a[0].startJd != 985503.1666666666 ||
        a[0].endJdExclusive != 994628.1666666666) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1874614.5);
    if (a.length != 1) {
      throw StateError('Era count');
    }
    if (a[0].text != "[北朝/北魏]明元帝 拓跋嗣 泰常5年" ||
        a[0].startJd != 1874492.1666666667 ||
        a[0].endJdExclusive != 1874876.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(2321670.5);
    if (a.length != 3) {
      throw StateError('Era count');
    }
    if (a[0].text != "[明]毅宗 朱由检 崇祯17年" ||
        a[0].startJd != 2315709.1666666665 ||
        a[0].endJdExclusive != 2321911.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[清]世祖 爱新觉罗福临 顺治1年" ||
        a[1].startJd != 2321556.1666666665 ||
        a[1].endJdExclusive != 2321911.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[2].text != "[大顺]李自成 永昌1年" ||
        a[2].startJd != 2321556.1666666665 ||
        a[2].endJdExclusive != 2321911.1666666665) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(2419402.1666666665);
    if (a.length != 2) {
      throw StateError('Era count');
    }
    if (a[0].text != "[清]无朝 爱新觉罗溥仪 宣统3年" ||
        a[0].startJd != 2418328.1666666665 ||
        a[0].endJdExclusive != 2419450.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[近、现代]中华民国 民国1年" ||
        a[1].startJd != 2419402.1666666665 ||
        a[1].endJdExclusive != 2433190.7916666665) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1694799.1666782408);
    if (a.length != 1) {
      throw StateError('Era count');
    }
    if (a[0].text != "[西汉]宣帝 刘询 本始1年" ||
        a[0].startJd != 1694799.1666666667 ||
        a[0].endJdExclusive != 1695153.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1814752.1666550927);
    if (a.length != 3) {
      throw StateError('Era count');
    }
    if (a[0].text != "[三国-魏]高贵乡公 曹髦 正元3年" ||
        a[0].startJd != 1814604.1666666667 ||
        a[0].endJdExclusive != 1814752.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[蜀汉]后主 刘禅 延熙19年" ||
        a[1].startJd != 1814604.1666666667 ||
        a[1].endJdExclusive != 1814958.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[2].text != "[孙吴]会稽王 孙亮 五凤3年" ||
        a[2].startJd != 1814604.1666666667 ||
        a[2].endJdExclusive != 1814875.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1901513.1666666667);
    if (a.length != 2) {
      throw StateError('Era count');
    }
    if (a[0].text != "[南朝/齐]欎林王 萧昭业 隆昌1年" ||
        a[0].startJd != 1901513.1666666667 ||
        a[0].endJdExclusive != 1901743.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[北朝/北魏]孝文帝 拓跋宏 太和18年" ||
        a[1].startJd != 1901513.1666666667 ||
        a[1].endJdExclusive != 1901897.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1889110.1666782408);
    if (a.length != 2) {
      throw StateError('Era count');
    }
    if (a[0].text != "[南朝/宋]孝武 帝刘骏 大明4年" ||
        a[0].startJd != 1889110.1666666667 ||
        a[0].endJdExclusive != 1889464.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[北朝/北魏]文成帝 拓跋浚 和平1年" ||
        a[1].startJd != 1889110.1666666667 ||
        a[1].endJdExclusive != 1889464.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1932579.1666550927);
    if (a.length != 3) {
      throw StateError('Era count');
    }
    if (a[0].text != "[南朝/陈]宣帝 陈顼 太建10年" ||
        a[0].startJd != 1932195.1666666667 ||
        a[0].endJdExclusive != 1932579.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[南朝/后梁]明帝 萧岿 天保17年" ||
        a[1].startJd != 1932195.1666666667 ||
        a[1].endJdExclusive != 1932579.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[2].text != "[北朝/北周]武帝 宇文邕 宣政1年" ||
        a[2].startJd != 1932278.1666666667 ||
        a[2].endJdExclusive != 1932579.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1980615.1666666667);
    if (a.length != 1) {
      throw StateError('Era count');
    }
    if (a[0].text != "[唐]睿宗 李旦 景云1年" ||
        a[0].startJd != 1980615.1666666667 ||
        a[0].endJdExclusive != 1980773.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(2129755.1666782405);
    if (a.length != 4) {
      throw StateError('Era count');
    }
    if (a[0].text != "[北宋]徽宗 赵佶 重和1年" ||
        a[0].startJd != 2129755.1666666665 ||
        a[0].endJdExclusive != 2129814.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[辽]天祚帝 耶律延禧 天庆8年" ||
        a[1].startJd != 2129430.1666666665 ||
        a[1].endJdExclusive != 2129814.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[2].text != "[西夏]李乾顺 雍宁5年" ||
        a[2].startJd != 2129430.1666666665 ||
        a[2].endJdExclusive != 2129814.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[3].text != "[金]太祖 完颜阿骨打 天辅2年" ||
        a[3].startJd != 2129430.1666666665 ||
        a[3].endJdExclusive != 2129814.1666666665) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(1814875.1666550927);
    if (a.length != 3) {
      throw StateError('Era count');
    }
    if (a[0].text != "[三国-魏]高贵乡公 曹髦 甘露1年" ||
        a[0].startJd != 1814752.1666666667 ||
        a[0].endJdExclusive != 1814958.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[蜀汉]后主 刘禅 延熙19年" ||
        a[1].startJd != 1814604.1666666667 ||
        a[1].endJdExclusive != 1814958.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[2].text != "[孙吴]会稽王 孙亮 五凤3年" ||
        a[2].startJd != 1814604.1666666667 ||
        a[2].endJdExclusive != 1814875.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(2075777.1666666667);
    if (a.length != 2) {
      throw StateError('Era count');
    }
    if (a[0].text != "[北宋]太祖 赵匡胤 开宝4年" ||
        a[0].startJd != 2075744.1666666667 ||
        a[0].endJdExclusive != 2076098.1666666667) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[辽]景宗 耶律贤 保宁3年" ||
        a[1].startJd != 2075744.1666666667 ||
        a[1].endJdExclusive != 2076098.1666666667) {
      throw StateError('Era boundary parity');
    }
  }
  {
    final a = getChineseEraNames(2165158.1666782405);
    if (a.length != 4) {
      throw StateError('Era count');
    }
    if (a[0].text != "[南宋]宁宗 赵扩 嘉定8年" ||
        a[0].startJd != 2164867.1666666665 ||
        a[0].endJdExclusive != 2165221.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[1].text != "[西夏]李遵顼 光定5年" ||
        a[1].startJd != 2164867.1666666665 ||
        a[1].endJdExclusive != 2165221.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[2].text != "[金]宣宗 完颜珣 贞祐3年" ||
        a[2].startJd != 2164867.1666666665 ||
        a[2].endJdExclusive != 2165221.1666666665) {
      throw StateError('Era boundary parity');
    }
    if (a[3].text != "[大真]蒲鲜万奴 天泰1年" ||
        a[3].startJd != 2165158.1666666665 ||
        a[3].endJdExclusive != 2165221.1666666665) {
      throw StateError('Era boundary parity');
    }
  }
  print('Passed 33 pillar, 76 clock, 14 era cross-runtime cases.');
}
