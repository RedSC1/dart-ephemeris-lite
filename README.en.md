# ephemeris_lite

[简体中文](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/README.md) | [English](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/README.en.md)

A pure Dart astronomy and calendar library for Dart and Flutter. It provides celestial positions, solar terms, lunar phases, Chinese and arithmetic Hijri calendars, solar time, rise/set, eclipses and external star-catalog calculations. No runtime dependencies; supports Dart VM and Dart Web.

Ported from [js-ephemeris-lite](https://github.com/RedSC1/js-ephemeris-lite). Planetary models derive from VSOP2013/TOP2013, the Moon from ELP/MPP02, with selected coefficients calibrated against DE441. Historical-calendar and other data sources are documented in the third-party notices. APIs use Dart named parameters, enums and result types, without a JavaScript engine or FFI.

Current version: `1.0.0-beta.2`. This is the astronomy/calendar core; Ten Gods and full BaZi/Ziwei charts belong to separate higher-level packages. Star catalogs are supplied by the application, not bundled.

## Installation

```yaml
dependencies:
  ephemeris_lite: 1.0.0-beta.2
```

Run `dart pub get`, or `flutter pub get` in a Flutter project. Pin the prerelease initially and adjust the constraint after validating compatibility.

## Runnable example

[main.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/main.dart)

```sh
dart run example/main.dart
```

<!-- example: example/main.dart -->
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

## Examples by task

| Task | Guide |
| --- | --- |
| Time scales, positions and frames | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/time-and-positions.en.md) |
| Solar terms, phases and solar time | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/qi-shuo-solar-time.en.md) |
| Chinese and historical calendars | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/calendar-history.en.md) |
| Arithmetic Hijri calendar | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/hijri-calendar.en.md) |
| Ganzhi, pillars and era names | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/ganzhi.en.md) |
| Rise/set, horizontal coordinates and polar regions | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/visibility.en.md) |
| Illumination, conjunctions, stations and orbital events | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/sky-events.en.md) |
| Global and local lunar eclipses | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/lunar-eclipses.en.md) |
| Global and local solar eclipses | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/solar-eclipses.en.md) |
| Fixed stars and external catalogs | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/fixed-stars.en.md) |
| Sun/Moon entry point and code size | [Open guide](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/module-loading.en.md) |

[Complete documentation](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/README.en.md) · [API reference](https://pub.dev/documentation/ephemeris_lite/latest/)

## Key conventions

- **Time scales:** positions and general event searches use TT; day boundaries and horizontal observations use UT1. Construct `JulianTime` and select the appropriate field. UTC approximates UT1; this is not a complete leap-second model.
- **Units:** planetary/heliocentric geometric states use AU and AU/day; the geocentric Moon uses km and km/day; apparent angles use degrees. Event `solve*` targets use radians, while annual-table phase options use degrees.
- **Accuracy:** positions default to accurate, calendar events to mid. Position tiers control coefficient prefixes; event tiers also change models and solvers. There is no mutable global default.
- **Historical calendars:** physical events and assigned civil dates are separate. Known reform-era reverse-lookup ambiguities prevent unique round trips for every historical date.
- **Limits:** errors vary by body and epoch. Pluto is recommended for 1600–2200; future ΔT includes an experimental fit. Solver tolerance is not an astronomical accuracy guarantee.

## License and provenance

[MPL-2.0](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/LICENSE) · [中文第三方声明](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/THIRD_PARTY_NOTICES.zh-CN.md) · [Third-party notices](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/THIRD_PARTY_NOTICES.md)
