# Lunar eclipses

[中文](lunar-eclipses.md) | [English](lunar-eclipses.en.md) · [Documentation](README.en.md)

## Runnable examples

[local_lunar_eclipse.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/local_lunar_eclipse.dart)

```sh
dart run example/local_lunar_eclipse.dart
```

<!-- example: example/local_lunar_eclipse.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final start = ZonedTime(
    year: 2025,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime();
  final end = ZonedTime(
    year: 2026,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime();
  const site = Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042);
  for (final eclipse in searchLunarEclipses(start, end)) {
    print('Global maximum: ${eclipse.maximum.toZonedTime(480).toJson()}');
    final local = getLocalLunarEclipse(eclipse.maximum, site);
    print(local?.toJson());
  }
}
```

## Queries and results

| API | Behavior |
| --- | --- |
| `getLunarEclipseDetails(date)` | Eclipse belonging to the full moon near the date, or `null`; not a nearest-eclipse search |
| `searchLunarEclipses(start, end)` | Eclipses whose maximum lies in `[start, end)` |
| `getLocalLunarEclipse(date, location)` | Global event, contact azimuths/altitudes/visibility and horizon crossings |

Inputs are explicit `JulianTime` values. Convert UT1 with `JulianTime.fromUT1`, TT with `JulianTime.fromTT`, and civil times with `ZonedTime.toJulianTime()`. Search end must be later than start; a request is limited to 5,000 lunations including internal margins. Split longer intervals.

Results, contact maps and event lists are immutable and provide `toJson()`. Absent partial or total phases are `null`, not fabricated zero timestamps.

## Model and correction window

The solver uses the full apparent chain in the true-of-date equatorial frame with solar deflection disabled, a three-dimensional Chauvenet Earth-shadow model and a circular lunar disc. The modern node filter is used only for absolute lunation indexes up to 2,500; outside that range, it is bypassed and full moon is located with the accurate phase solver.

After refining maximum, the solver samples a ±0.25-day window and fits cubic polynomials to relative shadow coordinates and shadow radii. Contacts use that fit; if a root cannot be bracketed, the solver falls back to direct geometry. There is no global mutable configuration or additional fast/mid/accurate argument.

## Local visibility

Only longitude, latitude and height are taken from `Observer`. Local circumstances use standard atmosphere, 1013.25 mbar and 15°C; custom observer weather fields are ignored. Contacts are visible when the apparent lunar-center altitude is positive; moonrise and moonset use the upper limb.

`visible` means some part is visible, not the whole eclipse. In addition to contacts, visibility is sampled at ten-minute intervals during the event. `horizonClipped` can indicate moonrise, moonset, both or neither. Geometric contacts are retained even below the horizon, with visibility recorded separately.

Terrain, lunar limb valleys and actual weather are not modeled. Historical/future UT1 and local visibility depend on uncertain ΔT, so results are not an observational accuracy guarantee. See also [solar eclipses](solar-eclipses.en.md).
