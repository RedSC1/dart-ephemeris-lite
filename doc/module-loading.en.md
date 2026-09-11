# Sun/Moon entry point and Web code size

[中文](module-loading.md) | [English](module-loading.en.md) · [Documentation](README.en.md)

If an application only needs geometric Sun/Moon states, import the lightweight entry point:

```dart
import 'package:ephemeris_lite/sun_moon.dart';
```

It provides `Accuracy`, Earth and Moon states, the geocentric Sun, the heliocentric Moon, and Earth-Moon barycenter geometry with the same coefficients and accuracy tiers as the main entry point. Time, calendar, apparent-position, rise/set, and eclipse APIs remain available from `package:ephemeris_lite/ephemeris_lite.dart`.

## Runnable example

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

## Code-size notes

Dart Web removes unreachable code. The lightweight entry point does not import coefficients for the other planets, so a Sun/Moon-only web program can usually compile to less JavaScript. One fixed probe produced the following result:

| Same probe program | Before split | After split |
| --- | ---: | ---: |
| dart2js bytes | 930484 | 355331 |
| Node.js default gzip bytes | 374925 | 140823 |

These numbers illustrate tree shaking for that probe; they are not fixed Flutter, Web, or native application sizes. Actual output depends on the compiler, build options, and APIs reached by the application. The pub source archive still contains every coefficient. The lightweight entry reduces reachable output code without reducing Sun/Moon accuracy.

General planetary apparent positions and some local-eclipse APIs may require other planets; import the main entry point for those features.
