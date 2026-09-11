# Horizontal coordinates, rise and set

[中文](visibility.md) | [English](visibility.en.md) · [Documentation](README.en.md)

## Runnable examples

[visibility.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/visibility.dart)

```sh
dart run example/visibility.dart
```

<!-- example: example/visibility.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  const site = Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042);
  final date = ZonedTime(year: 2026, month: 6, day: 21, offsetMinutes: 480);
  final solar = solarRiseSetForDate(date, site);
  print('Sun: ${solar.altitudeState.name}');
  print(solar.rise?.toZonedTime(480).toJson());
  final moon = bodyRiseSetForDay(SkyBody.moon, date.toJulianTime().jdUT1, site);
  for (final rise in moon.rises) {
    print(rise.toZonedTime(480).toJson());
  }
}
```

## Select the time window

| Call | Window |
| --- | --- |
| `solarRiseSetForDate(ZonedTime, observer)` | Local civil date; clock fields ignored, 24 hours centered on local noon |
| `computeSolarRiseSetFast(center, observer)` | 24 hours centered on the UT1 instant |
| `solarRiseSetForDate(numberOrJulianTime, observer)` | Same centered window |
| `bodyRiseSetForDay(body, dayStartUT1, observer)` | Exactly `[dayStartUT1, dayStartUT1 + 1)` |

For a local day, convert a midnight `ZonedTime` to the UT1 start. Longitude does not imply a time zone. Results use `JulianTime`, which can be displayed with `toZonedTime`.

The general API returns all rises, sets, upper transits and lower transits; lists can be empty or contain multiple events. The dedicated solar API returns one nullable rise and set, not the general all-events list.

## Geometry and options

`Observer` uses WGS84 geodetic coordinates, east-positive longitude and height in meters. Azimuth runs from north through east. `DiscLimb.upper/center/lower` selects the limb; refraction is applied to that limb's ray, not to the center followed by adding a radius.

`bodyHorizontalPosition` requires `SkyFrame.trueOfDate`. `BodyVisibilityOptions.apparent` retains position accuracy and light-time/aberration/solar-deflection options. The Fast in `computeSolarRiseSetFast` describes its rise/set seed and limited iterations, not `Accuracy.fast`; it has a fixed dedicated solar model.

The dedicated and general chains differ in apparent positions, observer rotation and solar-radius constants. Their results are not expected to agree second for second.

Default observer atmosphere is 1013.25 mbar and 15°C. The independent refraction function instead defaults to 1010 mbar and 10°C. Refraction is zero below −1°; the general solver rejects false roots caused by this cutoff. Its ten-minute scan refines local extrema to detect paired crossings within a sample interval. The dedicated solar fallback retains two-hour sampling and does not promise the same grazing-event detection.

## Missing events and limits

`AltitudeState` distinguishes crossing, always above, always below, tangent and not found. Above/below is relative to the selected limb, refraction and horizon threshold. No timestamp is invented when an event is absent.

Terrain obstruction, horizon dip, polar motion, diurnal aberration, clouds and naked-eye visibility are not modeled. Circular disc approximations are unsuitable for detailed occultation profiles.

Public `searchCrossings` / `searchAngleCrossings` only find sign-changing roots resolved by the sampling in `[start, end)`. They do not guarantee arbitrary tangencies or several roots within a step. Split large searches; increasing the step is not a lossless optimization.
