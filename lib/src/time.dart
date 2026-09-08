// Port of js-ephemeris-lite/src/time.js. MPL-2.0.
import 'dart:math' as math;
import 'generated/delta_t_data.dart';

const secondsPerDay = 86400.0;
const unixEpochJd = 2440587.5;

/// Civil fields in the hybrid Julian/Gregorian calendar; year 0 is 1 BCE.
class CalendarDate {
  final int year, month, day, hour, minute;
  final double second;
  const CalendarDate({
    required this.year,
    required this.month,
    required this.day,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  });
  Map<String, num> toJson() => {
    'year': year,
    'month': month,
    'day': day,
    'hour': hour,
    'minute': minute,
    'second': second,
  };
}

/// Low-level conversion, including JS-style day overflow normalization.
/// Use [ZonedTime] when civil fields must be validated.
double julianDay({
  required int year,
  required int month,
  required int day,
  int hour = 0,
  int minute = 0,
  double second = 0,
}) {
  if (!second.isFinite) throw ArgumentError.value(second, 'second');
  var y = year, m = month;
  if (m <= 2) {
    y--;
    m += 12;
  }
  final gregorian =
      year > 1582 ||
      (year == 1582 && (month > 10 || (month == 10 && day >= 15)));
  var correction = 0;
  if (gregorian) {
    final c = (y / 100).truncate();
    correction = 2 - c + (c / 4).truncate();
  }
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      (hour + (minute + second / 60) / 60) / 24 +
      correction -
      1524.5;
}

CalendarDate calendarDateFromJulianDay(double jd) {
  if (!jd.isFinite) throw ArgumentError.value(jd, 'jd');
  final shifted = jd + 0.5, z = shifted.floor();
  final fraction = shifted - z;
  var a = z;
  if (z >= 2299161) {
    final alpha = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + alpha - (alpha / 4).truncate();
  }
  final b = a + 1524, c = ((b - 122.1) / 365.25).floor();
  final d = (365.25 * c).floor(), e = ((b - d) / 30.6001).floor();
  final dd = b - d - (30.6001 * e).floor() + fraction;
  final day = dd.floor(), month = e < 14 ? e - 1 : e - 13;
  final year = month > 2 ? c - 4716 : c - 4715;
  var seconds = (dd - day) * secondsPerDay;
  final hour = (seconds / 3600).floor();
  seconds -= hour * 3600;
  final minute = (seconds / 60).floor();
  return CalendarDate(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: seconds - minute * 60,
  );
}

double decimalYearFromJulianDay(double jd) {
  if (!jd.isFinite) return jd;
  final year = calendarDateFromJulianDay(jd).year;
  final start = julianDay(year: year, month: 1, day: 1);
  final next = julianDay(year: year + 1, month: 1, day: 1);
  return year + (jd - start) / (next - start);
}

double _longTerm(double y) {
  final u = (y - 1820) / 100;
  return -20 + 32 * u * u;
}

double _longTermRate(double y) => 64 * (y - 1820) / 10000;
double _future(double y) {
  final t = (y - 1825) / 100;
  return -293.95181375822420 +
      32.50725 * t * t +
      348.7880578 * math.cos(0.41887902047863906 * t) +
      0.58635 * math.sin(0.33756972584642919 * (y - 2013.91314));
}

double _futureRate(double y) {
  final t = (y - 1825) / 100;
  return 0.650145 * t -
      1.4610000000591095 * math.sin(0.41887902047863906 * t) +
      0.19793400875005376 * math.cos(0.33756972584642919 * (y - 2013.91314));
}

double _s15(double y, {bool derivative = false}) {
  final r = s15Spline.firstWhere(
    (r) => y >= r[0] && y < r[1],
    orElse: () => s15Spline.last,
  );
  final x = y >= 1953 ? 1.0 : (y - r[0]) / (r[1] - r[0]);
  return derivative
      ? (3 * r[2] * x * x + 2 * r[3] * x + r[4]) / (r[1] - r[0])
      : ((r[2] * x + r[3]) * x + r[4]) * x + r[5];
}

double _hermite(double x, double p0, double p1, double m0, double m1) {
  final x2 = x * x, x3 = x2 * x;
  return (2 * x3 - 3 * x2 + 1) * p0 +
      (x3 - 2 * x2 + x) * m0 +
      (-2 * x3 + 3 * x2) * p1 +
      (x3 - x2) * m1;
}

/// Estimated TT − UT1 in seconds, matching the pinned JS model.
/// The post-2027 transition/future fit is experimental, not an IERS forecast.
double deltaTSeconds(double year) {
  if (!year.isFinite) return year;
  if (year >= -720 && year < 1953) return _s15(year);
  const start = 1953;
  final end = start + annualDeltaT.length - 1;
  if (year >= start && year < end) {
    final i = year.floor() - start;
    final i0 = math.max(i - 1, 0),
        i2 = math.min(i + 1, annualDeltaT.length - 1),
        i3 = math.min(i + 2, annualDeltaT.length - 1);
    final p0 = annualDeltaT[i0],
        p1 = annualDeltaT[i],
        p2 = annualDeltaT[i2],
        p3 = annualDeltaT[i3];
    final dt = (i2 - i).toDouble();
    return _hermite(
      (year - start - i) / dt,
      p1,
      p2,
      (p2 - p0) / (i2 - i0) * dt,
      (p3 - p1) / (i3 - i) * dt,
    );
  }
  if (year < -820) return _longTerm(year);
  if (year < -720) {
    return _hermite(
      (year + 820) / 100,
      _longTerm(-820),
      _s15(-720),
      _longTermRate(-820) * 100,
      _s15(-720, derivative: true) * 100,
    );
  }
  if (year < end + 1) {
    return _hermite(
      year - end,
      annualDeltaT.last,
      _future((end + 1).toDouble()),
      annualDeltaT.last - annualDeltaT[annualDeltaT.length - 2],
      _futureRate((end + 1).toDouble()),
    );
  }
  return _future(year);
}

double deltaTSecondsFromUt1(double jd) =>
    deltaTSeconds(decimalYearFromJulianDay(jd));
double deltaTSecondsFromTt(double jd) {
  var ut1 = jd, dt = 0.0;
  for (var i = 0; i < 2; i++) {
    dt = deltaTSecondsFromUt1(ut1);
    ut1 = jd - dt / secondsPerDay;
  }
  return dt;
}

double ttToUt1(double jdTT, {double? deltaT}) =>
    jdTT - (deltaT ?? deltaTSecondsFromTt(jdTT)) / secondsPerDay;
double ut1ToTt(double jdUT1, {double? deltaT}) =>
    jdUT1 + (deltaT ?? deltaTSecondsFromUt1(jdUT1)) / secondsPerDay;

/// Physical instant. UTC labels are treated as UT1, as in the JS lite runtime.
/// This is not a leap-second-aware UTC/TAI implementation.
class JulianTime {
  final double jdUT1, jdTT, deltaT;
  double get deltaTSeconds => deltaT;
  const JulianTime._(this.jdUT1, this.jdTT, this.deltaT);
  factory JulianTime.fromUT1(double jd) {
    if (!jd.isFinite) throw ArgumentError.value(jd, 'jdUT1');
    final dt = deltaTSecondsFromUt1(jd);
    return JulianTime._(jd, ut1ToTt(jd, deltaT: dt), dt);
  }
  factory JulianTime.fromTT(double jd) {
    if (!jd.isFinite) throw ArgumentError.value(jd, 'jdTT');
    final dt = deltaTSecondsFromTt(jd);
    return JulianTime._(ttToUt1(jd, deltaT: dt), jd, dt);
  }
  factory JulianTime.fromValues({
    required double jdUT1,
    required double jdTT,
    required double deltaTSeconds,
  }) {
    if (![jdUT1, jdTT, deltaTSeconds].every((v) => v.isFinite)) {
      throw ArgumentError('Time fields must be finite');
    }
    final tolerance =
        2 *
        2.220446049250313e-16 *
        math.max(1, math.max(jdTT.abs(), jdUT1.abs()));
    if ((jdTT - ut1ToTt(jdUT1, deltaT: deltaTSeconds)).abs() > tolerance) {
      throw ArgumentError('Inconsistent TT, UT1 and Delta-T');
    }
    return JulianTime._(jdUT1, jdTT, deltaTSeconds);
  }
  factory JulianTime.fromUnixMilliseconds(double ms) {
    if (!ms.isFinite) throw ArgumentError.value(ms, 'milliseconds');
    return JulianTime.fromUT1(unixEpochJd + ms / 86400000);
  }
  factory JulianTime.fromDateTime(DateTime date) => JulianTime.fromUT1(
    unixEpochJd + date.microsecondsSinceEpoch / 86400000000,
  );
  double toUnixMilliseconds() => (jdUT1 - unixEpochJd) * 86400000;

  /// Converts with microsecond rounding, limited by the resolution of double JD.
  DateTime toDateTime() => DateTime.fromMicrosecondsSinceEpoch(
    ((jdUT1 - unixEpochJd) * 86400000000).round(),
    isUtc: true,
  );
  ZonedTime toZonedTime(int offsetMinutes) =>
      ZonedTime.fromJulianTime(this, offsetMinutes: offsetMinutes);
  Map<String, double> toJson() => {
    'jdUT1': jdUT1,
    'jdTT': jdTT,
    'deltaTSeconds': deltaT,
  };
}

/// Validated civil time with an explicit fixed offset; no automatic DST.
class ZonedTime extends CalendarDate {
  final int offsetMinutes;
  ZonedTime({
    required super.year,
    required super.month,
    required super.day,
    super.hour,
    super.minute,
    super.second,
    required this.offsetMinutes,
  }) {
    _validateOffset(offsetMinutes);
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31 ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59 ||
        !second.isFinite ||
        second < 0 ||
        second >= 60) {
      throw ArgumentError('Civil field outside valid range');
    }
    final check = calendarDateFromJulianDay(
      julianDay(year: year, month: month, day: day, hour: 12),
    );
    if (check.year != year || check.month != month || check.day != day) {
      throw ArgumentError('Invalid hybrid-calendar date');
    }
  }
  factory ZonedTime.fromJulianTime(
    JulianTime time, {
    required int offsetMinutes,
  }) {
    _validateOffset(offsetMinutes);
    final d = calendarDateFromJulianDay(time.jdUT1 + offsetMinutes / 1440);
    return ZonedTime(
      year: d.year,
      month: d.month,
      day: d.day,
      hour: d.hour,
      minute: d.minute,
      second: d.second,
      offsetMinutes: offsetMinutes,
    );
  }
  factory ZonedTime.fromDateTime(DateTime date, {required int offsetMinutes}) =>
      JulianTime.fromDateTime(date).toZonedTime(offsetMinutes);
  JulianTime toJulianTime() => JulianTime.fromUT1(
    julianDay(
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
        ) -
        offsetMinutes / 1440,
  );
  DateTime toDateTime() => toJulianTime().toDateTime();
  @override
  Map<String, num> toJson() => {
    ...super.toJson(),
    'offsetMinutes': offsetMinutes,
  };
}

void _validateOffset(int minutes) {
  if (minutes.abs() > 840) {
    throw ArgumentError.value(
      minutes,
      'offsetMinutes',
      'must be within ±14 hours',
    );
  }
}

/// Normalize an explicit UT1 Julian day or JulianTime to JD(UT1).
double asUt1JulianDay(Object value) {
  final jd = value is JulianTime
      ? value.jdUT1
      : value is num
      ? value.toDouble()
      : double.nan;
  if (!jd.isFinite) {
    throw ArgumentError('Expected finite UT1 Julian day or JulianTime');
  }
  return jd;
}
