# Sun/Moon modules and code size

[中文](module-loading.md) | [English](module-loading.en.md) · [Documentation](README.en.md)

## Runnable examples

[sun_moon.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/sun_moon.dart)

```sh
dart run example/sun_moon.dart
```

<!-- example: example/sun_moon.dart -->
```dart
import 'package:ephemeris_lite/sun_moon.dart';

void main() {
  const jdTT = 2451545.0;
  final earth = earthState(jdTT, accuracy: Accuracy.mid);
  final moon = moonState(jdTT, accuracy: Accuracy.fast);
  print('Earth [AU]: ${earth.position}');
  print('Moon [km]: ${moon.position}');
}
```

## Choosing an entry point

The main `package:ephemeris_lite/ephemeris_lite.dart` entry remains compatible. For Sun/Moon geometric states alone, use `package:ephemeris_lite/sun_moon.dart`. Time, calendar and general sky APIs remain in the main entry.

Dart removes unreachable code. The important change is that Sun/Moon evaluation no longer traverses a map containing every planet, not merely that one source file was divided into several files. Generic planetary observation and local eclipse visibility that reuses it can still depend on other planets.

## Internal organization

`generated/*_series.dart` stores coefficients by body; `generated/series.dart` is an internal compatibility aggregate. Earth reads its table directly, while the Moon retains shared-phase evaluation. The generic `planet_evaluator.dart` imports no body-specific table.

`sun_moon_ephemeris.dart` contains Sun/Moon states, and `planet_models.dart` the other planets and Pluto. `apparent_core.dart` shares the apparent algorithm through immutable evaluator parameters, without a global registry or asynchronous API. Upper-level BaZi/Ziwei imports need not change.

## Recorded Dart Web measurement

`tool/bundle_probe.dart` constructs angles from current milliseconds and calls accurate solar-longitude and lunar-phase solvers, preventing the benchmark from becoming a constant result.

```sh
dart compile js -O2 tool/bundle_probe.dart -o /tmp/lunisolar.js
```

| Same probe program | Before split | After split |
| --- | ---: | ---: |
| dart2js bytes | 930484 | 355331 |
| Node.js default gzip bytes | 374925 | 140823 |

This is a recorded measurement of one compiled program, not the pub archive, a whole Flutter app or a promise about native AOT savings. The source package still contains all coefficients.

Coefficients, accuracy prefixes and algorithms are unchanged. Generated values were compared individually, with Moon/Pluto declarations preserved. `tool/state_snapshot.dart` compared 1,386 states over 33 epochs around −6000 through 10000 and three tiers: serialized JSON matched byte for byte. Tests also compare the dedicated and general apparent paths and constrain calendar/solar-time dependencies.

The importer uses `tool/split_series.mjs`, so regeneration preserves the split. Provenance hashes cover the actual upstream body tables, not only aggregate exports.
