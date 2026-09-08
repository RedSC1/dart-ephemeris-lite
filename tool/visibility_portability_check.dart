// GENERATED from JS visibility oracles.
import 'package:ephemeris_lite/ephemeris_lite.dart';

void check(List<JulianTime> actual, List<double> expected) {
  if (actual.length != expected.length) {
    throw StateError('Event count mismatch');
  }
  for (var i = 0; i < actual.length; i++) {
    if ((actual[i].jdUT1 - expected[i]).abs() * 86400 >= 0.02) {
      throw StateError('Event time mismatch');
    }
  }
}

void main() {
  {
    final a = bodyRiseSetForDay(
      SkyBody.sun,
      2461120,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, [2461120.4284317126]);
    check(a.sets, [2461120.9353747857]);
    check(a.upperTransits, [2461120.6816706033]);
    check(a.lowerTransits, [2461120.181773101]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.moon,
      2461395,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, [2461395.7487941417]);
    check(a.sets, [2461395.339986249]);
    check(a.upperTransits, [2461395.027448818]);
    check(a.lowerTransits, [2461395.5469187424]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.venus,
      2461212,
      Observer(
        longitudeDeg: -104.9903,
        latitudeDeg: 39.7392,
        heightMeters: 1609,
      ),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, [2461212.1080413368]);
    check(a.sets, [2461212.7108771172]);
    check(a.upperTransits, [2461212.4097248167]);
    check(a.lowerTransits, [2461212.9099920914]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.sun,
      2461212,
      Observer(longitudeDeg: 18.9553, latitudeDeg: 69.6492, heightMeters: 10),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.alwaysAbove) {
      throw StateError('Altitude state');
    }
    check(a.rises, []);
    check(a.sets, []);
    check(a.upperTransits, [2461212.9486005753]);
    check(a.lowerTransits, [2461212.448524669]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.moon,
      2461120,
      Observer(longitudeDeg: 0, latitudeDeg: -80, heightMeters: 0),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.alwaysBelow) {
      throw StateError('Altitude state');
    }
    check(a.rises, []);
    check(a.sets, []);
    check(a.upperTransits, [2461120.0519348728]);
    check(a.lowerTransits, [2461120.5695922105]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.venus,
      2461395,
      Observer(longitudeDeg: 0, latitudeDeg: -80, heightMeters: 0),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.alwaysAbove) {
      throw StateError('Altitude state');
    }
    check(a.rises, []);
    check(a.sets, []);
    check(a.upperTransits, [2461395.866437073]);
    check(a.lowerTransits, [2461395.366568044]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.sun,
      2461395,
      Observer(longitudeDeg: 180, latitudeDeg: 0, heightMeters: 0),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, [2461395.2458761563]);
    check(a.sets, [2461395.7510910532]);
    check(a.upperTransits, [2461395.4984835414]);
    check(a.lowerTransits, [2461395.9986555055]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.moon,
      2461212,
      Observer(longitudeDeg: -180, latitudeDeg: 90, heightMeters: 0),
      options: BodyVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, []);
    check(a.sets, [2461212.9881410035]);
    check(a.upperTransits, [2461212.728477503]);
    check(a.lowerTransits, [2461212.2131537944]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.moon,
      2460409.5,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: BodyVisibilityOptions(
        limb: DiscLimb.center,
        refraction: true,
        horizonDegrees: 2,
        apparent: ApparentOptions(accuracy: Accuracy.mid),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, [2460410.4418119485]);
    check(a.sets, [2460409.9721888066]);
    check(a.upperTransits, [2460409.692345664]);
    check(a.lowerTransits, [2460410.2107245577]);
  }
  {
    final a = bodyRiseSetForDay(
      SkyBody.sun,
      2460409.5,
      Observer(longitudeDeg: 0, latitudeDeg: 0, heightMeters: 0),
      options: BodyVisibilityOptions(
        limb: DiscLimb.center,
        refraction: false,
        horizonDegrees: 82.13378780917505,
        apparent: ApparentOptions(accuracy: Accuracy.accurate),
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Altitude state');
    }
    check(a.rises, [2460410.0009373166]);
    check(a.sets, [2460410.001007203]);
    check(a.upperTransits, [2460410.0009948835]);
    check(a.lowerTransits, [2460409.501088217]);
  }
  {
    final a = computeSolarRiseSetFast(
      2461120.5,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: SolarVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [2461120.4284321317]);
    check(a.set == null ? [] : [a.set!], [2461120.9353743745]);
  }
  {
    final a = computeSolarRiseSetFast(
      2461120.5,
      Observer(
        longitudeDeg: -104.9903,
        latitudeDeg: 39.7392,
        heightMeters: 1609,
      ),
      options: SolarVisibilityOptions(
        limb: DiscLimb.center,
        refraction: false,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [2461120.046865414]);
    check(a.set == null ? [] : [a.set!], [2461120.5470774695]);
  }
  {
    final a = computeSolarRiseSetFast(
      2461120.5,
      Observer(longitudeDeg: 18.9553, latitudeDeg: 69.6492, heightMeters: 10),
      options: SolarVisibilityOptions(
        limb: DiscLimb.lower,
        refraction: true,
        horizonDegrees: 0,
        fixedDiscSize: true,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [2461120.698282336]);
    check(a.set == null ? [] : [a.set!], [2461120.205093324]);
  }
  {
    final a = computeSolarRiseSetFast(
      2461120.5,
      Observer(longitudeDeg: 0, latitudeDeg: -80, heightMeters: 0),
      options: SolarVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: false,
        horizonDegrees: -6,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [2461120.651122695]);
    check(a.set == null ? [] : [a.set!], [2461120.3612829475]);
  }
  {
    final a = computeSolarRiseSetFast(
      2461212.5,
      Observer(longitudeDeg: 180, latitudeDeg: 0, heightMeters: 0),
      options: SolarVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [2461212.2486534533]);
    check(a.set == null ? [] : [a.set!], [2461212.753719073]);
  }
  {
    final a = computeSolarRiseSetFast(
      2461212.5,
      Observer(longitudeDeg: -180, latitudeDeg: 90, heightMeters: 0),
      options: SolarVisibilityOptions(
        limb: DiscLimb.center,
        refraction: false,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.alwaysAbove) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], []);
    check(a.set == null ? [] : [a.set!], []);
  }
  {
    final a = computeSolarRiseSetFast(
      -470270.5,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: SolarVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [-470270.6235347137]);
    check(a.set == null ? [] : [a.set!], [-470270.03937370254]);
  }
  {
    final a = computeSolarRiseSetFast(
      1721229.5,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: SolarVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [1721229.3610880813]);
    check(a.set == null ? [] : [a.set!], [1721229.987582226]);
  }
  {
    final a = computeSolarRiseSetFast(
      5373656.5,
      Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042, heightMeters: 50),
      options: SolarVisibilityOptions(
        limb: DiscLimb.upper,
        refraction: true,
        horizonDegrees: 0,
        fixedDiscSize: false,
      ),
    );
    if (a.altitudeState != AltitudeState.crosses) {
      throw StateError('Solar state');
    }
    check(a.rise == null ? [] : [a.rise!], [5373656.376346787]);
    check(a.set == null ? [] : [a.set!], [5373656.9959236]);
  }
  print('Passed 10 body and 9 solar cross-runtime windows.');
}
