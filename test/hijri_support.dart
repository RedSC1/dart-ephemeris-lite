import 'package:ephemeris_lite/ephemeris_lite.dart';

// Original approximation, only for verifying compatibility of integer rules.
HijriDate legacyHijri(int d0) {
  var d = d0 + 503105;
  final cycle = (d / 10631).floor();
  d -= cycle * 10631;
  final year = ((d + .5) / 354.366).floor();
  d -= (year * 354.366 + .5).floor();
  final month = ((d + .11) / 29.51).floor();
  d -= (month * 29.5 + .5).floor();
  return HijriDate(year: cycle * 30 + year + 1, month: month + 1, day: d + 1);
}

void checkHijriCycles() {
  for (final cycle in [-100, -1, 0, 46, 100]) {
    for (var day = 0; day < 10631; day++) {
      final d0 = -503105 + cycle * 10631 + day;
      final date = calendarDateFromJulianDay(2451545.0 + d0),
          actual = solarToHijri(date);
      if (actual != legacyHijri(d0)) throw StateError('Legacy mismatch $d0');
      final back = hijriToSolar(actual);
      if (back.year != date.year ||
          back.month != date.month ||
          back.day != date.day) {
        throw StateError('Reverse mismatch $d0');
      }
    }
  }
}
