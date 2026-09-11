# Solar terms, lunar phases and solar time

[中文](qi-shuo-solar-time.md) | [English](qi-shuo-solar-time.en.md) · [Documentation](README.en.md)

## Runnable example

[solar_time.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/solar_time.dart)

```sh
dart run example/solar_time.dart
```

<!-- example: example/solar_time.dart -->
```dart
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final near = ZonedTime(
    year: 2026,
    month: 6,
    day: 21,
    hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();
  final solstice = solveSolarLongitude(
    math.pi / 2,
    near.jdTT,
    accuracy: Accuracy.accurate,
  );
  print('Solstice UTC+8: ${solstice.toZonedTime(480).toJson()}');
  print('Delta-T [s]: ${solstice.deltaTSeconds}');
  print('EOT [s]: ${equationOfTime(solstice).equationSeconds}');
  final clock = trueSolarTime(solstice, 116.4074);
  print('Apparent solar clock: ${clock.toJson()}');
  print('Original instant TT: ${clock.instant.jdTT}');
}
```

## Nearest events and unwrapped angles

`solveSolarLongitude(targetLongitude, nearJdTT)` finds the nearest solar apparent-longitude event. `solveLunarPhase(targetElongation, nearJdTT)` finds the nearest apparent Moon-minus-Sun longitude event. Targets are radians; the estimate is JD(TT); results are `JulianTime`. Targets 0, π/2, π and 3π/2 are new moon, first quarter, full moon and last quarter. `solveNewMoon` is the zero-target convenience API.

Low-level `solarLongitudeTimeFast/Accurate` and `lunarPhaseTimeFast/Accurate` take unwrapped angles: adding 2π selects the next cycle. They return JD(TT) directly. Prefer the `solve*` APIs for application code.

| Tier | Event solver | Lunar latitude |
| --- | --- | --- |
| `fast` | Fixed stages; no custom tolerance or safeguarded solver | Fixed 10 terms |
| `mid` (default) | Dedicated iterative event model | Default 10; configurable 0–277 or `'full'` |
| `accurate` | Iteration through the complete apparent chain | Full |

`toleranceSeconds` is a convergence threshold, not an absolute astronomical error guarantee. Historical mode changes civil-day assignment, not these physical event roots.

## Annual event tables

`getQiShuoYear(year, options: ..., lunarPhaseAnglesDeg: [0, 90, 180, 270])` lists events within a fixed-offset civil year in physical-time order. These phase angles use **degrees**. By default only new moons are listed, with solar terms enabled. `includePentads: true` adds pentads; first pentads are not duplicated when solar terms are also included.

`time` and `localTime` describe the actual event; `assignedDate` is the calendar-assigned date. Historical profiles apply only to solar terms and new moons, not intermediate pentads or other phases. The table is not a lunar-month sequence. See the complete `example/qi_shuo.dart` example.

## Solar clocks and equation of time

`meanSolarTime` and `trueSolarTime` accept `ZonedTime`, `JulianTime` or a UT1 Julian day, with east-positive longitude in degrees. `equationOfTime` is apparent solar time minus mean solar time, exposed in days and seconds.

A `SolarClock` is a virtual clock reading, not a new physical instant. Its original instant is retained as `instant`. It can supply day/hour pillar clock fields, but do not apply the time-zone offset again. Fixed offsets do not automatically handle daylight saving.

## Annual-table example

```sh
dart run example/qi_shuo.dart
```

<!-- example: example/qi_shuo.dart -->
```dart
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
```
