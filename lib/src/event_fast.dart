// Fixed-stage event route from calendar-events.js, event-fast-values.js and
// event-rates.js. This is not the position Accuracy.fast model. MPL-2.0.
import 'dart:math' as math;
import 'coordinates.dart';
import 'ephemeris.dart' show j2000;
import 'generated/event_data.dart';
import 'generated/series.dart';

const _tau = 2 * math.pi;
const _scale = 2922000.0;
const _aberration = 20.4898 * arcsecToRad;
double _wrap(double a) => a - _tau * ((a + math.pi) / _tau).floor();
ScalarState _poly(List<double> a, double x) {
  var value = 0.0, rate = 0.0;
  for (var i = a.length - 1; i >= 0; i--) {
    rate = rate * x + value;
    value = value * x + a[i];
  }
  return (value: value, rate: rate / _scale);
}

double _value(List<double> a, double x) {
  var v = 0.0;
  for (var i = a.length - 1; i >= 0; i--) {
    v = v * x + a[i];
  }
  return v;
}

List<double> _earthValues(double jd, int? l, int? b, int? r) {
  final t = (jd - j2000) / 365250, groups = planetSeries['earth']!;
  final degree = groups.map((a) => a.length).reduce(math.max) - 1;
  final basis = List<double>.filled(degree + 1, 0);
  basis[0] = 1;
  for (var n = 1; n <= degree; n++) {
    basis[n] = basis[n - 1] * t;
  }
  final limits = [l, b, r], values = [0.0, 0.0, 0.0];
  for (var c = 0; c < 3; c++) {
    final counts = limits[c] == null
        ? null
        : earthEventPrefixes[c]['${limits[c]}'];
    if (limits[c] != null && counts == null) {
      throw ArgumentError('Unsupported Earth prefix');
    }
    for (var n = 0; n < groups[c].length; n++) {
      final rows = groups[c][n],
          end = counts == null
              ? rows.length
              : math.min((n < counts.length ? counts[n] : 0) * 3, rows.length);
      var sum = 0.0;
      for (var i = 0; i < end; i += 3) {
        sum += rows[i] * math.cos(rows[i + 1] + rows[i + 2] * t);
      }
      values[c] += sum * basis[n];
    }
  }
  return values;
}

List<double> _moonValues(double jd, int? longitudeTerms, int latitudeTerms) {
  final x = (jd - j2000) / _scale;
  final powers = List<double>.filled(9, 0);
  powers[0] = 1;
  for (var i = 1; i < powers.length; i++) {
    powers[i] = powers[i - 1] * x;
  }
  final values = [0.0, 0.0];
  for (var c = 0; c < 2; c++) {
    final key = c == 0
        ? (longitudeTerms?.toString() ?? 'full')
        : latitudeTerms.toString();
    final groups = fastMoonTerms[c][key]!;
    for (var n = 0; n < groups.length; n++) {
      final rows = groups[n];
      var sum = 0.0;
      for (var i = 0; i < rows.length; i += 3) {
        final a = moonArguments[rows[i + 2].toInt()];
        var arg = a[7];
        for (var k = 6; k >= 0; k--) {
          arg = arg * x + a[k];
        }
        arg *= x;
        sum += rows[i] * math.cos(arg + rows[i + 1]);
      }
      values[c] += sum * powers[n];
    }
  }
  values[0] += _value(moonW1, x);
  return values;
}

double _longitude(List<double> v, double x, int offset) {
  final c = math.cos(v[0]), s = math.sin(v[0]), b = math.tan(v[1]);
  double component(int row) => _value(fastEventFrames[offset + row], x);
  return math.atan2(
    component(3) * c + component(4) * s + component(5) * b,
    component(0) * c + component(1) * s + component(2) * b,
  );
}

double _solar(double jd, {int? l, int nutation = 10, int? b, int r = 30}) {
  final e = _earthValues(jd, l, b, r);
  return _wrap(_longitude(e, (jd - j2000) / _scale, 0) + math.pi) +
      iau2000bNutationLongitude(jd, termCount: nutation) -
      _aberration / e[2];
}

double _phase(
  double jd, {
  int? ml,
  int el = 129,
  int mb = 10,
  int? eb,
  int er = 30,
}) {
  final e = _earthValues(jd, el, eb, er),
      m = _moonValues(jd, ml, mb),
      x = (jd - j2000) / _scale;
  return _wrap(
    _longitude(m, x, 6) -
        _longitude(e, x, 0) -
        math.pi -
        3.4e-6 +
        _aberration / e[2],
  );
}

double _earthRate(double jd) {
  final x = (jd - j2000) / _scale, t = (jd - j2000) / 365250;
  var rate = _poly(lowSolarRateSecular, x).rate;
  for (final (f, cosine, sine) in lowSolarRateHarmonics) {
    final c = _poly(cosine, x),
        s = _poly(sine, x),
        p = f * t,
        cp = math.cos(p),
        sp = math.sin(p);
    rate +=
        c.rate * cp + s.rate * sp + f / 365250 * (s.value * cp - c.value * sp);
  }
  return rate;
}

double _solarRate(double jd) {
  final t = (jd - j2000) / 36525;
  var rate = 0.0;
  for (final r in rateNutation) {
    final arg = r[0] + r[1] * t;
    rate +=
        (r[3] * math.sin(arg) +
            (r[2] + r[3] * t) * r[1] * math.cos(arg) -
            r[4] * r[1] * math.sin(arg)) /
        36525;
  }
  return _earthRate(jd) +
      _value(lowPrecessionRate, (jd - j2000) / _scale) +
      rate;
}

double _phaseRate(double jd) {
  final x = (jd - j2000) / _scale;
  var rate = _poly(moonW1, x).rate;
  for (final r in lunarRateTerms.take(10)) {
    final n = r[0].toInt(), s = r[1], c = r[2], p = moonArguments[r[3].toInt()];
    var a = p[7], d = a;
    for (var i = 6; i >= 0; i--) {
      a = a * x + p[i];
      d = d * x + a;
    }
    a *= x;
    final sn = math.sin(a), cs = math.cos(a);
    rate +=
        (s * cs - c * sn) * d / _scale * math.pow(x, n) +
        (n == 0 ? 0 : n * math.pow(x, n - 1) / _scale * (s * sn + c * cs));
  }
  return rate - _earthRate(jd);
}

double _checkedDate(double jd) {
  if (!jd.isFinite || (jd - j2000).abs() > _scale) {
    throw RangeError('Event must lie within J2000 ± 2922000 days');
  }
  return jd;
}

double _seed(double angle, bool lunar) {
  if (!angle.isFinite) throw ArgumentError.value(angle, 'angle');
  return _checkedDate(
    j2000 +
        (lunar
                ? (angle + 1.08472) / 7771.37714500204
                : (angle - 1.75347 - math.pi) / 628.3319653318) *
            36525,
  );
}

/// Fixed-stage fast solar-longitude event. Input is UNWRAPPED radians: add
/// 2π per revolution to select a year. Output is JD(TT), not a historical day.
/// No requested tolerance is promised by this fixed-stage algorithm.
double solarLongitudeTimeFast(double longitude) {
  var jd = _seed(longitude, false);
  jd = _checkedDate(
    jd - _wrap(_solar(jd, l: 28, b: 0, r: 3) - longitude) / _solarRate(jd),
  );
  return _checkedDate(jd - _wrap(_solar(jd) - longitude) / _solarRate(jd));
}

/// Fixed-stage fast elongation event. 2π*k selects successive new moons;
/// π+2π*k selects full moons. Returns JD(TT), without historical day assignment.
double lunarPhaseTimeFast(double elongation) {
  var jd = _seed(elongation, true);
  jd = _checkedDate(
    jd -
        _wrap(_phase(jd, ml: 8, el: 11, mb: 0, eb: 0, er: 3) - elongation) /
            (7771.37714500204 / 36525),
  );
  final velocity = _phaseRate(jd);
  jd = _checkedDate(
    jd -
        _wrap(_phase(jd, ml: 33, el: 48, mb: 10, eb: 0, er: 3) - elongation) /
            velocity,
  );
  return _checkedDate(jd - _wrap(_phase(jd) - elongation) / velocity);
}

// Internal approximate Newton slopes; not physical velocity APIs.
double solarApproximateRate(double jd) => _solarRate(jd);
double elongationApproximateRate(double jd) => _phaseRate(jd);
double elongationRefineRate(double jd) {
  final x = (jd - j2000) / _scale;
  var earth = _poly(refineEarthRateSecular, x).rate;
  for (final (f, cosine, sine) in refineEarthRateHarmonics) {
    final c = _poly(cosine, x),
        s = _poly(sine, x),
        p = f * x * 8,
        cp = math.cos(p),
        sp = math.sin(p);
    earth +=
        c.rate * cp + s.rate * sp + f / 365250 * (s.value * cp - c.value * sp);
  }
  var moon = _poly(moonW1, x).rate;
  for (final r in lunarRateTerms) {
    final n = r[0].toInt(), s = r[1], c = r[2], p = moonArguments[r[3].toInt()];
    var a = p[7], d = a;
    for (var i = 6; i >= 0; i--) {
      a = a * x + p[i];
      d = d * x + a;
    }
    a *= x;
    final sn = math.sin(a), cs = math.cos(a);
    moon +=
        (s * cs - c * sn) * d / _scale * math.pow(x, n) +
        (n == 0 ? 0 : n * math.pow(x, n - 1) / _scale * (s * sn + c * cs));
  }
  return moon - earth;
}
