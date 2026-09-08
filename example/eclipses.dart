import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final start = JulianTime.fromUT1(julianDay(year: 2024, month: 1, day: 1));
  final end = JulianTime.fromUT1(julianDay(year: 2025, month: 1, day: 1));
  for (final e in searchSolarEclipses(start, end)) {
    print(e.toJson());
  }
  for (final e in searchLunarEclipses(start, end)) {
    print(e.toJson());
  }
}
