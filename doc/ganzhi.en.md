# Ganzhi, four pillars and era names

[中文](ganzhi.md) | [English](ganzhi.en.md) · [Documentation](README.en.md)

## Runnable example

[four_pillars.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/four_pillars.dart)

```sh
dart run example/four_pillars.dart
```

<!-- example: example/four_pillars.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final clock = ZonedTime(
    year: 2003,
    month: 3,
    day: 13,
    hour: 11,
    offsetMinutes: 480,
  );
  final pillars = fourPillarsForZonedTime(
    clock,
    options: CalendarOptions(mode: CalendarMode.chinaAstronomical),
    ratHourMode: RatHourMode.nextDay,
  );
  print(describeFourPillars(pillars));
  for (final era in getChineseEraNames(clock.toJulianTime().jdUT1)) {
    print('${era.text} (${era.precision.name}, ${era.boundarySource})');
  }
}
```

## Primitives and package boundaries

This package provides Ganzhi encoding, Nayin and astronomical/calendar foundations for four pillars. Use `makeGanzhi`, `ganzhiStem`, `ganzhiBranch`, `ganzhiIndex` and `ganzhiName`; do not assume the packed code itself is a sexagenary-cycle index. Stem indexes start at Jia = 0, branches at Zi = 0.

Ten Gods, hidden stems, Shen Sha, fortune cycles and full BaZi charts belong to the independent `bazi_core` package. Its Ten Gods function is `getTenGod(dayStem, targetStem)`, not an export of this package. Full Ziwei charts belong to `ziwei_core`.

## Instants and late-Zi-hour rules

`fourPillarsForZonedTime` accepts a fixed-offset civil time. `calculateFourPillars(jdUT1, chartTime)` separates physical time from clock fields: year/month boundaries compare UT1, while day/hour pillars use the supplied clock, including independently resolved mean/apparent solar clocks. `normalizeChartTime` is the canonical validator; `normalizeChartVirtualTime` remains a deprecated alias.

The core changes year at Li Chun and month at Jie; it has no Lunar New Year switch.

| `RatHourMode` | Late Zi hour (23:00–24:00) |
| --- | --- |
| `nextDay` (default) | Next day's day pillar and hour-stem derivation |
| `currentDay` | Current day's day pillar and hour-stem derivation |
| `currentDayTomorrowStem` | Current day pillar; only the hour stem derives from the next day's stem |

`PillarHistoricalMode` follows calendar options by default. Historical assignment uses UTC+8 midnight of the assigned date as the pillar boundary; it does not rewrite the physical solar-term instant.

## Era candidates

`getChineseEraNames(jdUT1)` independently uses the historical China calendar, not the UI time zone. Concurrent regimes can produce several candidates. `EraPrecision.year` means the source is only year-precise, not an exact accession date.

Queries inherit [historical reverse-lookup limits](calendar-history.en.md). Results do not adjudicate historical disputes; errors must not automatically be interpreted as no active era.
