// Port of solar-core.js and solar-time.js. MPL-2.0.
import 'dart:math' as math;
import 'coordinates.dart';
import 'ephemeris.dart';
import 'sky_math.dart';
import 'time.dart';

const _tau = 2 * math.pi;
double _normalize(double a) => ((a.remainder(_tau)) + _tau).remainder(_tau);
double _signed(double a) {
  final n = _normalize(a + math.pi) - math.pi;
  return n == -math.pi ? math.pi : n;
}

void _finite(double v, String name) {
  if (!v.isFinite) throw ArgumentError.value(v, name);
}

void _longitude(double longitude) {
  if (!longitude.isFinite || longitude.abs() > 180) {
    throw ArgumentError.value(longitude, 'longitudeDeg');
  }
}

({JulianTime instant, ZonedTime? source}) _resolve(Object time) {
  if (time is ZonedTime) return (instant: time.toJulianTime(), source: time);
  if (time is JulianTime) return (instant: time, source: null);
  if (time is num) {
    return (instant: JulianTime.fromUT1(time.toDouble()), source: null);
  }
  throw ArgumentError('Expected ZonedTime, JulianTime or numeric UT1 JD');
}

double greenwichMeanSiderealTimeRadians(double jdUT1, double jdTT) {
  _finite(jdUT1, 'jdUT1');
  _finite(jdTT, 'jdTT');
  final era = _tau * (0.7790572732640 + 1.00273781191135448 * (jdUT1 - j2000)),
      t = (jdTT - j2000) / 36525;
  final correction =
      0.014506 +
      4612.156534 * t +
      1.3915817 * math.pow(t, 2) -
      0.00000044 * math.pow(t, 3) -
      0.000029956 * math.pow(t, 4) -
      0.0000000368 * math.pow(t, 5);
  return _normalize(era + correction * arcsecToRad);
}

double greenwichApparentSiderealTimeRadians(
  double jdUT1,
  double jdTT, {
  NutationState? nutation,
}) {
  final n = nutation ?? iau2000bNutation(jdTT);
  return _normalize(
    greenwichMeanSiderealTimeRadians(jdUT1, jdTT) +
        n.dpsi * math.cos(n.trueObliquity),
  );
}

/// GAST in degrees; UT1 controls Earth rotation and TT controls the date frame.
double greenwichSiderealTime(double jdUT1, {double? jdTT}) => normDeg(
  greenwichApparentSiderealTimeRadians(jdUT1, jdTT ?? ut1ToTt(jdUT1)) * rad,
);
({List<double> position, NutationState nutation}) _sun(double jd) {
  final earth = earthState(jd),
      mean = transform(
        meanEclipticOfDateMatrixState(jd).matrix,
        scale(earth.position, -1),
      );
  final distance = norm(mean),
      latitude = math.asin((mean[2] / distance).clamp(-1, 1)),
      geometricLongitude = math.atan2(mean[1], mean[0]);
  final n = iau2000bNutation(jd),
      longitude =
          geometricLongitude - 20.4898 * arcsecToRad / distance + n.dpsi;
  final cb = math.cos(latitude),
      cl = math.cos(longitude),
      sl = math.sin(longitude),
      ce = math.cos(n.trueObliquity),
      se = math.sin(n.trueObliquity);
  return (
    position: [
      distance * cb * cl,
      distance * (cb * sl * ce - math.sin(latitude) * se),
      distance * (cb * sl * se + math.sin(latitude) * ce),
    ],
    nutation: n,
  );
}

class EquationOfTime {
  final double jdUT1, jdTT, equationDays, apparentSunRightAscensionRad, gastRad;
  const EquationOfTime({
    required this.jdUT1,
    required this.jdTT,
    required this.equationDays,
    required this.apparentSunRightAscensionRad,
    required this.gastRad,
  });
  double get equationSeconds => equationDays * 86400;
}

/// Apparent solar time minus mean solar time at the same physical instant.
/// Uses the dedicated solar-time chain, as in JS (not the generic sky API).
EquationOfTime equationOfTime(Object time) {
  final instant = _resolve(time).instant,
      jd = instant.jdUT1,
      sun = _sun(instant.jdTT);
  final ra = _normalize(math.atan2(sun.position[1], sun.position[0]));
  final gast = greenwichApparentSiderealTimeRadians(
    jd,
    instant.jdTT,
    nutation: sun.nutation,
  );
  final fraction = jd + 0.5 - (jd + 0.5).floor(),
      mean = _normalize(_tau * fraction),
      apparent = _normalize(gast - ra + math.pi);
  return EquationOfTime(
    jdUT1: jd,
    jdTT: instant.jdTT,
    equationDays: _signed(apparent - mean) / _tau,
    apparentSunRightAscensionRad: ra,
    gastRad: gast,
  );
}

enum SolarClockMode { mean, apparent }

/// Virtual solar clock, intentionally not a ZonedTime. There is no implicit
/// conversion back to an instant; [instant] retains the original physical time.
class SolarClock extends CalendarDate {
  final SolarClockMode mode;
  final double longitudeDeg, jdSolar, equationOfTimeSeconds;
  final JulianTime instant;
  final ZonedTime? sourceClock;
  SolarClock._(
    CalendarDate fields, {
    required this.mode,
    required this.longitudeDeg,
    required this.jdSolar,
    required this.equationOfTimeSeconds,
    required this.instant,
    required this.sourceClock,
  }) : super(
         year: fields.year,
         month: fields.month,
         day: fields.day,
         hour: fields.hour,
         minute: fields.minute,
         second: fields.second,
       );
}

SolarClock _clock(Object time, double longitude, bool apparent) {
  _longitude(longitude);
  final input = _resolve(time),
      equation = apparent ? equationOfTime(input.instant).equationDays : 0.0;
  final jd = input.instant.jdUT1 + longitude / 360 + equation;
  return SolarClock._(
    calendarDateFromJulianDay(jd),
    mode: apparent ? SolarClockMode.apparent : SolarClockMode.mean,
    longitudeDeg: longitude,
    jdSolar: jd,
    equationOfTimeSeconds: equation * 86400,
    instant: input.instant,
    sourceClock: input.source,
  );
}

SolarClock meanSolarTime(Object time, double longitudeDeg) =>
    _clock(time, longitudeDeg, false);
SolarClock trueSolarTime(Object time, double longitudeDeg) =>
    _clock(time, longitudeDeg, true);
SolarClock localMeanSolarTime(Object time, double longitudeDeg) =>
    meanSolarTime(time, longitudeDeg);
SolarClock localApparentSolarTime(Object time, double longitudeDeg) =>
    trueSolarTime(time, longitudeDeg);
double localMeanToApparentSolarTime(double jdLocalMean, double longitudeDeg) {
  _longitude(longitudeDeg);
  _finite(jdLocalMean, 'jdLocalMean');
  return jdLocalMean +
      equationOfTime(jdLocalMean - longitudeDeg / 360).equationDays;
}

double localApparentToMeanSolarTime(
  double jdLocalApparent,
  double longitudeDeg,
) {
  _longitude(longitudeDeg);
  _finite(jdLocalApparent, 'jdLocalApparent');
  var mean = jdLocalApparent;
  for (var i = 0; i < 12; i++) {
    final next =
        jdLocalApparent -
        equationOfTime(mean - longitudeDeg / 360).equationDays;
    if (next == mean || (next - mean).abs() <= 5e-10) return next;
    mean = next;
  }
  throw StateError('Apparent-to-mean solar time did not converge');
}
