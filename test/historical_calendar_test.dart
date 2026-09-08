import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';
import '../tool/historical_check.dart' as oracle;

void main() {
  test(
    'all historical profile event ordinals match JS',
    oracle.checkHistoricalProfiles,
  );
  test('profile coverage is not extrapolated', () {
    for (final kind in HistoricalEventKind.values) {
      for (final jd in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
        0.0,
        2436935.0,
        2451545.0,
      ]) {
        expect(historicalEventCivilDay(kind, jd), isNull);
      }
    }
  });
  test('civil-day boundaries and calendar structure offsets', () {
    expect(civilDayNumber(2451545), 2451545);
    expect(civilDayNumber(2451545.5, 0), 2451546);
    expect(civilDayNumber(2451545.5 - 1e-8, 0), 2451545);
    final historical = CalendarOptions(utcOffsetMinutes: -300);
    expect(historical.structureOffset, 480 / 1440);
    final local = CalendarOptions(
      mode: CalendarMode.localAstronomical,
      dayBoundaryMode: CalendarDayBoundaryMode.meanSolarMeridian,
      meridianDeg: 116.4074,
    );
    expect(local.structureOffset, 116.4074 / 360);
    expect(() => CalendarOptions(meridianDeg: 0), throwsArgumentError);
    expect(
      () => CalendarOptions(
        dayBoundaryMode: CalendarDayBoundaryMode.meanSolarMeridian,
      ),
      throwsArgumentError,
    );
    expect(
      () => CalendarOptions(utcOffsetMinutes: double.nan),
      throwsRangeError,
    );
    expect(() => civilDayNumber(double.nan), throwsArgumentError);
  });
}
