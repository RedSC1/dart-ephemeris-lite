# Time and celestial positions

[中文](time-and-positions.md) | [English](time-and-positions.en.md) · [Documentation](README.en.md)

## Runnable example

[positions.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/positions.dart)

```sh
dart run example/positions.dart
```

<!-- example: example/positions.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final time = JulianTime.fromTT(2451545.0);
  final geometric = planetHeliocentricState(
    Planet.mars,
    time.jdTT,
    accuracy: Accuracy.mid,
  );
  print('Heliocentric J2000 [AU]: ${geometric.position}');
  print('Analytic velocity [AU/day]: ${geometric.velocity}');
  final apparent = apparentBodyState(
    SkyBody.mars,
    time.jdTT,
    options: const ApparentOptions(
      frame: SkyFrame.trueOfDate,
      accuracy: Accuracy.accurate,
    ),
  );
  print('Apparent longitude [deg]: ${apparent.longitudeDeg}');
  print('Longitude rate [deg/day]: ${apparent.longitudeSpeedDegPerDay}');
}
```

## Choose a time scale first

Represent a fixed-offset civil time with `ZonedTime`, then convert to `JulianTime`. Geometric/apparent positions and general sky-event searches use `jdTT`. Instant-to-calendar conversion, horizontal coordinates and day boundaries use `jdUT1`. Do not interchange bare numbers.

An existing `ZonedTime` can be displayed directly in another fixed offset with
`clock.toZonedTime(480)` or `clock.toUtc()`. Both preserve the physical instant;
fixed offsets do not apply daylight-saving rules.

`JulianTime.fromTT` and `fromUT1` use the built-in ΔT model. `fromValues` accepts external TT, UT1 and ΔT in seconds and checks consistency. UTC labels approximate UT1; there is no complete UTC/TAI leap-second or EOP model.

`DateTime` is imported by timestamp, not by reinterpreting civil fields. Civil dates use the hybrid Julian/Gregorian calendar with the 1582-10-15 cutover and astronomical year numbering (0 = 1 BCE). Use `ZonedTime` to validate dates; low-level `julianDay` permits day-overflow normalization.

## Geometric versus apparent positions

| Result | Center/frame | Units |
| --- | --- | --- |
| `earthState`, `planetHeliocentricState` | Heliocentric, mean J2000 ecliptic/equinox | AU, AU/day |
| `moonState` | Geocentric, same frame | km, km/day |
| `moonHeliocentricState`, `embState` | Heliocentric, same frame | AU, AU/day |
| `apparentBodyPosition`, `apparentBodyState` | Geocentric, selected ecliptic/equatorial frame | Degrees, AU; rates in degrees/day and AU/day |

Geometric velocities are analytic series derivatives; apparent velocities are finite differences of the full correction chain. Direction interfaces return dimensionless vectors and daily derivatives, not linear velocities.

`SkyFrame.j2000` means mean J2000 ecliptic/equinox, not ICRS. `meanOfDate` and `trueOfDate` select mean and true date frames. Apparent positions default to light time, aberration and solar deflection, without multi-body deflection or Shapiro delay.

## Accuracy and range

Position accuracy defaults to `Accuracy.accurate`; the three tiers use offline-prepared coefficient prefixes. Full means all coefficients published in this package, not the complete original VSOP2013/ELP tables. There is no global mutable accuracy setting.

The ordinary models target roughly −6000 through 10000, but errors vary by body and epoch; computable range is not a uniform accuracy guarantee. Pluto represents its system barycenter and is recommended for 1600–2200, with a coarse outer model and blending outside that interval. Future ΔT includes an experimental fit.

Solar-term and lunar-phase tiers additionally change models and solvers; see [events and solar time](qi-shuo-solar-time.en.md).
