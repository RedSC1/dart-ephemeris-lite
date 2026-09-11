// Port of solar-visibility.js. MPL-2.0.
import 'dart:math' as math;
import 'sun_moon_ephemeris.dart';
import 'observer.dart';
import 'sky_math.dart';
import 'solar_time.dart';
import 'time.dart';

const _deg = math.pi / 180, _tau = 2 * math.pi;

/// 太阳升落的圆面、折射、固定圆面大小与地平线高度选项。
///
/// 默认太阳上缘、启用折射，圆面大小随距离变化；地平线高度单位为度。
class SolarVisibilityOptions {
  final DiscLimb limb;
  final bool refraction, fixedDiscSize;
  final double horizonDegrees;
  const SolarVisibilityOptions({
    this.limb = DiscLimb.upper,
    this.refraction = true,
    this.fixedDiscSize = false,
    this.horizonDegrees = 0,
  });
}

/// 太阳高度采样：角度为弧度，高度变化率为弧度/日。
class SolarAltitudeSample {
  final double slopeRadPerDay,
      centerAltitudeRad,
      apparentAltitudeRad,
      azimuthRad;
  final double _residual;
  const SolarAltitudeSample._(
    this.slopeRadPerDay,
    this.centerAltitudeRad,
    this.apparentAltitudeRad,
    this.azimuthRad,
    this._residual,
  );
}

/// 太阳升落结果；没有对应事件时 rise 或 set 为 null。
///
/// 需结合 altitudeState 判断极昼、极夜或相切情况。
class SolarRiseSetResult {
  final AltitudeState altitudeState;
  final JulianTime? rise, set;
  final DiscLimb limb;
  final bool refraction;
  const SolarRiseSetResult._(
    this.altitudeState,
    this.rise,
    this.set,
    this.limb,
    this.refraction,
  );
}

/// Bennett below 14°, Smart above 16°, linearly blended between. Input/output
/// are radians. Refraction is zero below −1° or in a non-positive atmosphere.
double hybridAtmosphericRefraction(
  double altitudeRad, {
  double pressureMbar = 1010,
  double temperatureCelsius = 10,
}) {
  if (!altitudeRad.isFinite ||
      !pressureMbar.isFinite ||
      !temperatureCelsius.isFinite) {
    throw ArgumentError('refraction arguments must be finite');
  }
  final kelvin = 273 + temperatureCelsius;
  if (pressureMbar <= 0 || kelvin <= 0 || altitudeRad < -_deg) {
    return 0;
  }
  final altitude = altitudeRad * rad;
  final tanZ = math.tan((90 - altitude) * _deg);
  final smart = (58.276 * tanZ - 0.0824 * math.pow(tanZ, 3)) / 60;
  final bennett = 1.02 / math.tan((altitude + 10.3 / (altitude + 5.11)) * _deg);
  final weight = (altitude - 14) / 2;
  final refraction = altitude >= 16
      ? smart
      : altitude <= 14
      ? bennett
      : bennett * (1 - weight) + smart * weight;
  if (!(refraction > 0)) {
    return 0;
  }
  return refraction * (pressureMbar / 1010 * (283 / kelvin)) * _deg / 60;
}

double _ut1(Object time) {
  final jd = switch (time) {
    ZonedTime t => t.toJulianTime().jdUT1,
    JulianTime t => t.jdUT1,
    num n => n.toDouble(),
    _ => throw ArgumentError('Expected a UT1 JD, JulianTime or ZonedTime'),
  };
  if (!jd.isFinite) {
    throw ArgumentError('UT1 must be finite');
  }
  return jd;
}

void _validate(Observer observer, SolarVisibilityOptions options) {
  validateVisibilityObserver(observer, solar: true);
  if (!options.horizonDegrees.isFinite || options.horizonDegrees.abs() > 90) {
    throw RangeError('horizonDegrees must be within ±90');
  }
}

SolarAltitudeSample _sample(
  double jd,
  Observer o,
  SolarVisibilityOptions options,
) {
  final tt = ut1ToTt(jd),
      sun = solarCoreEquatorial(tt),
      lat = o.latitudeDeg * _deg,
      lon = o.longitudeDeg * _deg;
  final gmst = greenwichMeanSiderealTimeRadians(jd, tt),
      gast = greenwichApparentSiderealTimeRadians(
        jd,
        tt,
        nutation: sun.nutation,
      );
  final sinLat = math.sin(lat), cosLat = math.cos(lat);
  final n = 6378137 / math.sqrt(1 - 6.69437999014e-3 * sinLat * sinLat);
  final x = (n + o.heightMeters) * cosLat,
      z = (n * (1 - 6.69437999014e-3) + o.heightMeters) * sinLat;
  // Preserve the dedicated JS solar solver's GMST site vector. The generic
  // body solver uses a separate GAST geometry; these paths are not identical.
  final site = [
    x * math.cos(gmst + lon) / (auKm * 1000),
    x * math.sin(gmst + lon) / (auKm * 1000),
    z / (auKm * 1000),
  ];
  final top = sub(sun.position, site), distance = norm(top);
  final ra = math.atan2(top[1], top[0]),
      dec = math.atan2(top[2], math.sqrt(top[0] * top[0] + top[1] * top[1]));
  var h = (gast + lon - ra + math.pi) % _tau - math.pi;
  if (h == -math.pi) {
    h = math.pi;
  }
  final center = math.asin(
    (sinLat * math.sin(dec) + cosLat * math.cos(dec) * math.cos(h)).clamp(
      -1,
      1,
    ),
  );
  final centerSlope =
      -_tau *
      cosLat *
      math.cos(dec) *
      math.sin(h) /
      math.max(1e-12, math.cos(center));
  final radius = math.asin(
    math.min(1, 695700 / ((options.fixedDiscSize ? 1 : distance) * auKm)),
  );
  final sign = options.limb == DiscLimb.upper
      ? 1
      : options.limb == DiscLimb.lower
      ? -1
      : 0;
  double eventAltitude(double a) {
    final limb = a + sign * radius;
    return limb +
        (options.refraction
            ? hybridAtmosphericRefraction(
                limb,
                pressureMbar: o.pressureMbar,
                temperatureCelsius: o.temperatureCelsius,
              )
            : 0);
  }

  final altitude = eventAltitude(center);
  var slope = centerSlope;
  if (options.refraction) {
    slope *=
        (eventAltitude(center + 1e-5) - eventAltitude(center - 1e-5)) / (2e-5);
  }
  final azimuth =
      (math.atan2(math.sin(h), math.cos(h) * sinLat - math.tan(dec) * cosLat) +
          math.pi) %
      _tau;
  return SolarAltitudeSample._(
    slope,
    center,
    altitude,
    azimuth,
    altitude - options.horizonDegrees * _deg,
  );
}

/// 计算给定时刻与观测地点的太阳高度及圆面判定信息。
///
/// 折射与圆面选项由 SolarVisibilityOptions 控制，不考虑地形遮挡。
SolarAltitudeSample solarAltitude(
  Object time,
  Observer observer, {
  SolarVisibilityOptions options = const SolarVisibilityOptions(),
}) {
  _validate(observer, options);
  return _sample(_ut1(time), observer, options);
}

double? _seed(
  double noon,
  Observer o,
  SolarVisibilityOptions options,
  bool rise,
) {
  final day = (noon - 2451545) % 365.2422, lat = o.latitudeDeg * _deg;
  final dec = 0.409092804222 * math.sin((day - 80) / 365.2422 * _tau);
  final denominator = math.cos(lat) * math.cos(dec);
  if (!denominator.isFinite || denominator.abs() < 1e-12) {
    return null;
  }
  final cosH =
      (math.sin(options.horizonDegrees * _deg) -
          math.sin(lat) * math.sin(dec)) /
      denominator;
  if (!(cosH.abs() <= 1)) {
    return null;
  }
  final b = _tau * (day - 81) / 364;
  final meanHour =
      12 -
      (9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b)) / 60;
  final hourAngle = math.acos(cosH) * 12 / math.pi;
  return noon + (meanHour + (rise ? -hourAngle : hourAngle) - 12) / 24;
}

double? _newton(
  double noon,
  double start,
  double end,
  Observer o,
  SolarVisibilityOptions opts,
  bool rise,
) {
  final seed = _seed(noon, o, opts, rise);
  if (seed == null) {
    return null;
  }
  var value = seed;
  for (var i = 0; i < (opts.refraction ? 3 : 2); i++) {
    final s = _sample(value, o, opts);
    if (!(rise ? s.slopeRadPerDay > 0.2 : s.slopeRadPerDay < -0.2)) {
      return null;
    }
    final next = value - s._residual / s.slopeRadPerDay;
    if (!next.isFinite ||
        (next - value).abs() > 0.25 ||
        next < start - 0.05 ||
        next > end + 0.05) {
      return null;
    }
    value = next;
  }
  return value >= start && value <= end ? value : null;
}

double _bisect(
  double lower,
  double upper,
  double lowerValue,
  Observer o,
  SolarVisibilityOptions opts,
) {
  for (var i = 0; i < 60 && upper - lower > 5e-10; i++) {
    final middle = (lower + upper) / 2, v = _sample(middle, o, opts)._residual;
    if ((lowerValue <= 0 && v >= 0) || (lowerValue >= 0 && v <= 0)) {
      upper = middle;
    } else {
      lower = middle;
      lowerValue = v;
    }
  }
  return (lower + upper) / 2;
}

({double? rise, double? set, AltitudeState state}) _fallback(
  double start,
  double end,
  Observer o,
  SolarVisibilityOptions opts,
) {
  double? rise, set;
  var previousJd = start, previous = _sample(start, o, opts)._residual;
  var minimum = previous, maximum = previous;
  for (var jd = start + 2 / 24; ; jd += 2 / 24) {
    final currentJd = math.min(end, jd),
        current = _sample(currentJd, o, opts)._residual;
    minimum = math.min(minimum, current);
    maximum = math.max(maximum, current);
    if (rise == null && previous < 0 && current > 0) {
      rise = _bisect(previousJd, currentJd, previous, o, opts);
    }
    if (set == null && previous > 0 && current < 0) {
      set = _bisect(previousJd, currentJd, previous, o, opts);
    }
    previousJd = currentJd;
    previous = current;
    if (currentJd >= end) {
      break;
    }
  }
  return (
    rise: rise,
    set: set,
    state: rise != null || set != null
        ? AltitudeState.crosses
        : minimum > 0
        ? AltitudeState.alwaysAbove
        : maximum < 0
        ? AltitudeState.alwaysBelow
        : AltitudeState.tangent,
  );
}

/// 使用专用太阳模型计算中心时刻附近的升落。
///
/// 这是升落算法入口，名称中的 Fast 不是气朔 Accuracy.fast 档位。
///
/// 窗口为以 center 为中心的 24 小时，包含两端；极区或平缓穿越时
/// 退回每两小时采样和二分求解。
SolarRiseSetResult computeSolarRiseSetFast(
  Object center,
  Observer observer, {
  SolarVisibilityOptions options = const SolarVisibilityOptions(),
}) {
  final jd = _ut1(center);
  _validate(observer, options);
  final start = jd - 0.5, end = jd + 0.5, lon = observer.longitudeDeg / 360;
  final noon = (jd + lon + 0.5).floor() - lon;
  double? rise, set;
  if (observer.latitudeDeg.abs() <= 65) {
    rise = _newton(noon, start, end, observer, options, true);
    set = _newton(noon, start, end, observer, options, false);
  }
  var state = AltitudeState.crosses;
  if (rise == null || set == null) {
    final f = _fallback(start, end, observer, options);
    rise ??= f.rise;
    set ??= f.set;
    state = f.state;
  }
  if (rise != null || set != null) {
    state = AltitudeState.crosses;
  }
  return SolarRiseSetResult._(
    state,
    rise == null ? null : JulianTime.fromUT1(rise),
    set == null ? null : JulianTime.fromUT1(set),
    options.limb,
    options.refraction,
  );
}

/// 计算指定日期或中心时刻附近的太阳升落。
///
/// 使用专用太阳求解链，极昼／极夜不会伪造升落时刻；不包含地形遮挡。
///
/// ZonedTime 选取当地民用日期并忽略其钟面时间；数值 UT1 或 JulianTime
/// 则选择以该瞬间为中心的 24 小时窗口。
SolarRiseSetResult solarRiseSetForDate(
  Object dateOrCenter,
  Observer observer, {
  SolarVisibilityOptions options = const SolarVisibilityOptions(),
}) {
  final center = dateOrCenter is ZonedTime
      ? ZonedTime(
          year: dateOrCenter.year,
          month: dateOrCenter.month,
          day: dateOrCenter.day,
          hour: 12,
          offsetMinutes: dateOrCenter.offsetMinutes,
        ).toJulianTime()
      : dateOrCenter;
  return computeSolarRiseSetFast(center, observer, options: options);
}
