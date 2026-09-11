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
