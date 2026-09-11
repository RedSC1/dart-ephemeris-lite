# Solar eclipses

[中文](solar-eclipses.md) | [English](solar-eclipses.en.md) · [Documentation](README.en.md)

## Runnable examples

[local_solar_eclipse.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/local_solar_eclipse.dart)

```sh
dart run example/local_solar_eclipse.dart
```

<!-- example: example/local_solar_eclipse.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final date = ZonedTime(
    year: 2024,
    month: 4,
    day: 8,
    offsetMinutes: 0,
  ).toJulianTime();
  final global = getSolarEclipseDetails(date);
  if (global == null) {
    print('No solar eclipse in this lunation.');
    return;
  }
  print(global.toJson());
  final local = getLocalSolarEclipse(
    date,
    const Observer(longitudeDeg: -96.8, latitudeDeg: 32.8),
  );
  print(local?.toJson());
}
```

## Queries and results

`getSolarEclipseDetails(date)` returns the eclipse belonging to the new moon near the input, or `null`. It does not search for an arbitrary nearest eclipse. `searchSolarEclipses(start, end)` filters by global maximum in `[start, end)`. Inputs are `JulianTime`; end must be later than start. Each search allows at most 5,000 lunations including internal margins.

Global results include partial/total/annular/hybrid type, new moon and maximum, greatest-eclipse location, magnitude, width, central duration and geographical contact points. Global maximum is not the local maximum for every observer. Absent central contacts are `null`.

## Interpolation and geometry

Five-point Newton interpolation shares the three-dimensional apparent Sun/Moon vectors within ±0.25 days of its center. Outside that window, the geometry is evaluated directly. The shadow cone intersects a WGS84 ellipsoid; local circumstances use three-dimensional apparent disc overlap. This API uses a fixed model and has no additional accuracy switch.

## Local circumstances

`getLocalSolarEclipse(date, observer)` uses longitude, latitude and height with standard atmosphere (1013.25 mbar, 15°C), ignoring custom weather fields. It returns visible local magnitude/type, sunrise/sunset, horizon clipping and contact times. Local contacts below the horizon are set to `null`, unlike the retained geometric contacts in the local lunar-eclipse result.

Visibility uses the refracted upper solar limb. Terrain and lunar limb valleys are not modeled. Geographical contacts, greatest-eclipse location and instantaneous width are numeric results; the library does not render maps.

Historical/future ground locations and local times depend on ΔT. Computed results should not be read as observational certification. See also [lunar eclipses](lunar-eclipses.en.md).
