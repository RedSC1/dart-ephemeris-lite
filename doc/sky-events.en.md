# Illumination and astronomical events

[中文](sky-events.md) | [English](sky-events.en.md) · [Documentation](README.en.md)

## Runnable examples

[sky_events.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/sky_events.dart)

```sh
dart run example/sky_events.dart
```

<!-- example: example/sky_events.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final start = ZonedTime(
    year: 2026,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime().jdTT;
  final end = ZonedTime(
    year: 2027,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime().jdTT;
  for (final station in searchStations(SkyBody.mercury, start, end)) {
    print(
      '${station.time.toZonedTime(480).toJson()} ${station.direction.name}',
    );
  }
  print(moonIllumination(start).toJson());
}
```

[orbital_events.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/orbital_events.dart)

```sh
dart run example/orbital_events.dart
```

<!-- example: example/orbital_events.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final start = ZonedTime(
    year: 2026,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime().jdTT;
  final end = ZonedTime(
    year: 2027,
    month: 1,
    day: 1,
    offsetMinutes: 0,
  ).toJulianTime().jdTT;
  for (final event in searchLunarApsides(start, end)) {
    print(event.toJson());
  }
  for (final event in searchGreatestElongations(
    SkyBody.mercury,
    start,
    end,
    apparent: const ApparentOptions(accuracy: Accuracy.mid),
  )) {
    print(event.toJson());
  }
}
```

## Illumination and apparent discs

`bodyPhenomena(body, jdTT)` returns geocentric distance, phase angle, illuminated fraction, solar elongation, apparent diameter and horizontal parallax. Phase angle and illuminated fraction are `null` for the Sun. Phase angle is calculated at the target from the heliocentric target and viewing vectors, not approximated as 180° minus geocentric elongation.

There is no empirical magnitude, terrain or satellite photocenter model. Disc radii are approximations. Pluto's position refers to its system barycenter, so its apparent diameter is not a resolved image boundary.

`moonIllumination` additionally returns `phaseCycle` (Moon-minus-Sun longitude divided by 360) and `waxing`. The cycle is not the illuminated fraction. Waxing/waning uses the date ecliptic regardless of the requested output frame.

`apparentGeometry` exposes read-only intermediate vectors. Its astrometric vector is after light time and before aberration and deflection.

## Longitude searches

| API | Event definition |
| --- | --- |
| `searchLongitudeCrossings` | A body's longitude reaches the target |
| `searchRelativeLongitude` | Body-minus-other longitude reaches the target; not minimum angular separation |
| `searchStations` | Apparent longitude rate crosses zero; direction is the motion after the station |
| `searchIngresses` | Every 30° boundary, including retrograde re-entry; signs 0–11 are coordinate sectors, not IAU constellations |

Bounds are JD(TT), with a half-open interval `[startTT, endTT)`. Returned `time` is a `JulianTime`. Convert UT1 before calling. `apparent` controls frame, position accuracy and physical corrections; different frames can produce different station or crossing times.

The default step is 0.5 days and root tolerance 1e-8 days. Tolerance is a numerical threshold, not an observational guarantee. Coarse sampling may miss tangencies or multiple crossings within one step. Apparent velocities are finite differences of the complete chain, not arbitrary-order analytic derivatives.

## Orbital and right-ascension searches

- `searchLunarApsides` / `searchEarthApsides`: full geometric geocentric lunar / heliocentric Earth distance extrema; no apparent-position accuracy or light-time options.
- `searchLunarNodes`: actual crossings of the selected ecliptic plane, default mean-of-date, optionally J2000 or true-of-date. These are not mean orbital nodes. Frame derivatives contribute to ascending/descending classification; nutation in longitude does not change the crossing time.
- `searchGreatestElongations`: Mercury/Venus local maxima of three-dimensional apparent separation from the Sun. East/west always uses the true-of-date ecliptic, independently of output frame. Accepts `ApparentOptions`.
- `searchRelativeRightAscension`: a specified RA difference, 0 for RA conjunction and 180 for RA opposition; distinct from longitude conjunction or closest approach.
- `searchRightAscensionStations`: apparent RA rate crosses zero, with direction determined after the event; accepts apparent options.

All use half-open TT intervals and immutable event lists with `JulianTime` and JSON output. Sampling must resolve the events; the scalar solver cannot guarantee all multiple or tangent roots. See [lunar](lunar-eclipses.en.md) and [solar eclipses](solar-eclipses.en.md) for eclipse-specific APIs.
