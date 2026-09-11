import 'dart:convert';
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final rows = <Object>[];
  for (var i = 0; i <= 32; i++) {
    final jd = 2451545.0 - 2922000 + i * 182625;
    for (final accuracy in Accuracy.values) {
      for (final planet in Planet.values) {
        final s = planetHeliocentricState(planet, jd, accuracy: accuracy);
        rows.add([s.position, s.velocity]);
      }
      for (final s in [
        earthState(jd, accuracy: accuracy),
        moonState(jd, accuracy: accuracy),
        earthDirectionState(jd, accuracy: accuracy),
        moonDirectionState(jd, accuracy: accuracy),
        embState(jd, accuracy: accuracy),
      ]) {
        rows.add([s.position, s.velocity]);
      }
    }
  }
  print(jsonEncode(rows));
}
