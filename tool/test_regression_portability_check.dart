// No dart:io: these regressions must also execute after dart compile js.
import 'package:ephemeris_lite/ephemeris_lite.dart';

void check(bool value, String label) {
  if (!value) throw StateError(label);
}

void main() {
  for (final source in [
    DateTime.utc(2025, 1, 1, 12, 34, 56, 123, 456),
    DateTime.utc(1969, 12, 31, 23, 59, 59, 123, 456),
  ]) {
    final back = JulianTime.fromDateTime(source).toDateTime();
    check(
      back.difference(source).inMicroseconds.abs() <= 25,
      'DateTime JD rounding',
    );
  }
  for (final accuracy in Accuracy.values) {
    final root = solveSolarLongitude(
      1.5707963267948966,
      2461212.851151956,
      accuracy: accuracy,
    );
    check(
      (root.jdTT - 2461212.851151956).abs() * 86400 <
          (accuracy == Accuracy.fast ? 2 : .5),
      'DE441 solstice $accuracy',
    );
  }
  check(
    getQiShuoYear(
          2026,
          includeSolarTerms: false,
          lunarPhaseAnglesDeg: [0, 45, 90, 135, 180, 225, 270, 315],
        ).events.length ==
        99,
    'eight phases',
  );
  final eclipse = getSolarEclipseDetails(
    JulianTime.fromTT(2451545 - 23737.277315980806),
  )!;
  check(
    eclipse.kind == SolarEclipseKind.partial &&
        eclipse.magnitude > 0 &&
        eclipse.magnitude < .01,
    'grazing eclipse',
  );
  print(
    'Migrated time, DE441 solstice, phase count and grazing eclipse regressions passed.',
  );
}
