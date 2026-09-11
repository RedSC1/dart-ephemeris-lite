# ephemeris_lite

[简体中文](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/README.md) | [English](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/README.en.md)

A pure Dart astronomy and calendar library for Dart and Flutter. It provides
planetary and lunar positions, solar terms and phases, Chinese and arithmetic
Hijri calendars, solar time, rise and set, eclipses, and calculations using
external star catalogs. It has no runtime dependencies and supports Dart VM
and Dart Web.

The package is ported from
[js-ephemeris-lite](https://github.com/RedSC1/js-ephemeris-lite). Planetary
models are derived from VSOP2013/TOP2013, the lunar model from ELP/MPP02, and
selected compact coefficients are calibrated against DE441. See the
third-party notices for historical-calendar sources, data provenance, licenses,
and limitations.

Current stable version: `1.1.0`. This package is the astronomy and calendar
core. Complete BaZi and Ziwei chart systems belong to separate packages. Star
catalog data is loaded by applications and is not bundled in the core package.

## Installation

```yaml
dependencies:
  ephemeris_lite: ^1.1.0
```

Run `dart pub get`, or `flutter pub get` in a Flutter project.

## Runnable example

```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final time = ZonedTime(
    year: 2000,
    month: 1,
    day: 1,
    hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();
  final earth = earthState(time.jdTT, accuracy: Accuracy.accurate);
  final moon = moonState(time.jdTT, accuracy: Accuracy.mid);
  print('TT: ${time.jdTT}; Delta-T: ${time.deltaTSeconds} s');
  print('Earth heliocentric J2000 [AU]: ${earth.position}');
  print('Moon geocentric J2000 [km]: ${moon.position}');
}
```

The complete runnable source is
[example/main.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/main.dart).

## Documentation by task

| Task | Guide |
| --- | --- |
| Time scales, positions, and frames | [Time and positions](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/time-and-positions.en.md) |
| Solar terms, phases, and solar time | [Qi, Shuo, and solar time](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/qi-shuo-solar-time.en.md) |
| Chinese and historical calendars | [Calendar history](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/calendar-history.en.md) |
| Arithmetic Hijri calendar | [Hijri calendar](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/hijri-calendar.en.md) |
| Ganzhi, Four Pillars, and era names | [Ganzhi](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/ganzhi.en.md) |
| Rise/set and horizontal coordinates | [Visibility](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/visibility.en.md) |
| Illumination and sky events | [Sky events](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/sky-events.en.md) |
| Global and local lunar eclipses | [Lunar eclipses](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/lunar-eclipses.en.md) |
| Global and local solar eclipses | [Solar eclipses](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/solar-eclipses.en.md) |
| Fixed stars and external catalogs | [Fixed stars](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/fixed-stars.en.md) |
| Sun/Moon-only imports and code size | [Module loading](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/module-loading.en.md) |

See the [English documentation index](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/README.en.md),
the [JS to Dart API map](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/api-map.en.md),
and the [pub.dev API reference](https://pub.dev/documentation/ephemeris_lite/latest/).

## Core conventions

- **Time scales:** positions and general event searches use TT; civil-day and
  horizon calculations use UT1. Construct a `JulianTime` and select the field
  required by the API. UTC is approximated as UT1; this is not a leap-second
  model.
- **Units:** geometric heliocentric planet states use AU and AU/day;
  geocentric lunar states use km and km/day; apparent-position angles use
  degrees.
- **Accuracy:** positions default to `accurate`, while Qi/Shuo defaults to
  `mid`. Position tiers select coefficient prefixes. Qi/Shuo tiers also change
  the event model and solver. There is no mutable global accuracy setting.
- **Calendar assignment:** astronomical instants and calendar-day assignment
  are stored separately. Historical reform windows can contain ambiguous
  reverse conversions.
- **Range:** accuracy varies by body and epoch. Pluto is recommended for
  1600–2200, and future Delta-T includes an experimental fit. Numerical test
  tolerances are not guarantees of astronomical accuracy.

## License and attribution

[MPL-2.0](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/LICENSE) ·
[Third-party notices](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/THIRD_PARTY_NOTICES.md) ·
[中文第三方声明](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/THIRD_PARTY_NOTICES.zh-CN.md)
