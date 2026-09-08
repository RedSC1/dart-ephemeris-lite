import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final date = solarToHijri(const CalendarDate(year: 2000, month: 1, day: 1));
  print('Arithmetic Hijri: $date');
  print('Civil date: ${hijriToSolar(date).toJson()}');
  print(instantToHijri(JulianTime.fromUT1(2451545), offsetMinutes: 480));
}
