// Modern circular-limb lunar eclipse solver ported from js-ephemeris-lite.
// Internal geometry uses kilometres and TT days relative to J2000.
import 'dart:math' as math;
import 'apparent.dart';
import 'body_visibility.dart';
import 'ephemeris.dart';
import 'event_accurate.dart';
import 'observer.dart';
import 'sky_math.dart';
import 'time.dart';

const _re = 6378.137, _rm = .2725076 * _re, _rs = 695700.0;
const _month = 29.5306, _d = math.pi / 180;

enum LunarEclipseKind { penumbral, partial, total }

enum LunarEclipseContact {
  penumbralBegin,
  penumbralEnd,
  partialBegin,
  partialEnd,
  totalBegin,
  totalEnd,
  maximum,
}

enum LunarHorizonClipped { moonrise, moonset, both }

class LunarEclipse {
  final LunarEclipseKind kind;
  final JulianTime maximum;
  final double umbralMagnitude, penumbralMagnitude;
  final Map<LunarEclipseContact, JulianTime?> contacts;
  LunarEclipse._(
    this.kind,
    this.maximum,
    this.umbralMagnitude,
    this.penumbralMagnitude,
    Map<LunarEclipseContact, JulianTime?> contacts,
  ) : contacts = Map.unmodifiable(contacts);
  double get magnitude =>
      kind == LunarEclipseKind.penumbral ? penumbralMagnitude : umbralMagnitude;
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'maximum': maximum.toJson(),
    'magnitude': magnitude,
    'umbralMagnitude': umbralMagnitude,
    'penumbralMagnitude': penumbralMagnitude,
    'contacts': {
      for (final e in contacts.entries) e.key.name: e.value?.toJson(),
    },
  };
}

class LunarContactCircumstance {
  final JulianTime time;
  final double azimuthDeg, geometricAltitudeDeg, apparentAltitudeDeg;
  const LunarContactCircumstance._(
    this.time,
    this.azimuthDeg,
    this.geometricAltitudeDeg,
    this.apparentAltitudeDeg,
  );
  bool get visible => apparentAltitudeDeg > 0;
  Map<String, Object?> toJson() => {
    'time': time.toJson(),
    'azimuthDeg': azimuthDeg,
    'geometricAltitudeDeg': geometricAltitudeDeg,
    'apparentAltitudeDeg': apparentAltitudeDeg,
    'visible': visible,
  };
}

class LocalLunarEclipse {
  final LunarEclipse global;
  final Observer observer;
  final bool visible;
  final Map<LunarEclipseContact, LunarContactCircumstance?> contacts;
  final List<JulianTime> moonrises, moonsets;
  final LunarHorizonClipped? horizonClipped;
  LocalLunarEclipse._(
    this.global,
    this.observer,
    this.visible,
    Map<LunarEclipseContact, LunarContactCircumstance?> contacts,
    List<JulianTime> rises,
    List<JulianTime> sets,
    this.horizonClipped,
  ) : contacts = Map.unmodifiable(contacts),
      moonrises = List.unmodifiable(rises),
      moonsets = List.unmodifiable(sets);
  Map<String, Object?> toJson() => {
    'global': global.toJson(),
    'observer': {
      'longitudeDeg': observer.longitudeDeg,
      'latitudeDeg': observer.latitudeDeg,
      'heightMeters': observer.heightMeters,
    },
    'visible': visible,
    'contacts': {
      for (final e in contacts.entries) e.key.name: e.value?.toJson(),
    },
    'moonrises': moonrises.map((t) => t.toJson()).toList(),
    'moonsets': moonsets.map((t) => t.toJson()).toList(),
    'horizonClipped': horizonClipped?.name,
  };
}

bool _passes(int k) {
  if (k.abs() > 2500) return true;
  final h = k + .5, centuries = h / 1236.85;
  final f =
      (160.7108 +
          390.67050274 * h -
          .0016341 * centuries * centuries -
          .00000227 * centuries * centuries * centuries +
          .000000011 * centuries * centuries * centuries * centuries) *
      _d;
  return math.sin(f).abs() <= math.sin(23 * _d);
}

double _seed(int k) {
  final h = k + .5,
      centuries = h / 1236.85,
      t2 = centuries * centuries,
      t3 = t2 * centuries,
      t4 = t3 * centuries;
  final m = (2.5534 + 29.10535669 * h - .0000218 * t2 - .00000011 * t3) * _d;
  final p =
      (201.5643 +
          385.81693528 * h +
          .1017438 * t2 +
          .00001239 * t3 +
          .000000058 * t4) *
      _d;
  final e = 1 - .002516 * centuries - .0000074 * t2;
  final t =
      5.09765 +
      29.530588853 * h +
      .0001337 * t2 -
      .000000150 * t3 +
      .00000000073 * t4;
  final omega =
      (124.7746 - 1.56375580 * h + .0020691 * t2 + .00000215 * t3) * _d;
  final f =
      ((160.7108 +
                  390.67050274 * h -
                  .0016341 * t2 -
                  .00000227 * t3 +
                  .000000011 * t4) %
              180 -
          .02665 * math.sin(omega)) *
      _d;
  final a = (299.77 + .107408 * h - .009173 * t2) * _d;
  return t -
      .4065 * math.sin(p) +
      .1727 * e * math.sin(m) +
      .0161 * math.sin(2 * p) -
      .0097 * math.sin(2 * f) +
      .0073 * e * math.sin(p - m) -
      .0050 * e * math.sin(p + m) -
      .0023 * math.sin(p - 2 * f) +
      .0021 * e * math.sin(2 * m) +
      .0012 * math.sin(p + 2 * f) +
      .0006 * e * math.sin(2 * p + m) -
      .0004 * math.sin(3 * p) -
      .0003 * e * math.sin(m + 2 * f) +
      .0003 * math.sin(a) -
      .0002 * e * math.sin(m - 2 * f) -
      .0002 * e * math.sin(2 * p - m) -
      .0002 * math.sin(omega);
}

class _Geometry {
  final List<double> q;
  final double rho, umbra, penumbra;
  _Geometry(this.q, this.rho, this.umbra, this.penumbra);
  double radius(int b) => b == 0
      ? penumbra + _rm
      : b == 1
      ? umbra + _rm
      : umbra - _rm;
  double contact(int b) => dot(q, q) - radius(b) * radius(b);
}

_Geometry _at(double t) {
  List<double> position(SkyBody body) => scale(
    apparentBodyPosition(
      body,
      j2000 + t,
      options: const ApparentOptions(solarDeflection: false),
    ).equatorialPositionAu,
    auKm,
  );
  final moon = position(SkyBody.moon),
      sun = position(SkyBody.sun),
      sd = norm(sun),
      axis = scale(sun, -1 / sd),
      z = dot(moon, axis);
  if (!(z > 0)) throw StateError('Moon not on night-side shadow axis');
  final q = sub(moon, scale(axis, z));
  return _Geometry(
    q,
    norm(q),
    _re * 1.02 * .99834 - z * (_rs - _re) * 1.02 / sd,
    _re * 1.02 * .99834 + z * (_rs + _re) * 1.02 / sd,
  );
}

List<double> _fit(List<double> values) {
  final a = List.generate(4, (_) => List.filled(5, 0.0));
  for (var i = 0; i < 5; i++) {
    final x = (i - 2) / 2;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        a[r][c] += math.pow(x, r + c);
      }
      a[r][4] += values[i] * math.pow(x, r);
    }
  }
  for (var c = 0; c < 4; c++) {
    var p = c;
    for (var r = c + 1; r < 4; r++) {
      if (a[r][c].abs() > a[p][c].abs()) p = r;
    }
    final row = a[c];
    a[c] = a[p];
    a[p] = row;
    final d = a[c][c];
    for (var j = c; j < 5; j++) {
      a[c][j] /= d;
    }
    for (var r = 0; r < 4; r++) {
      if (r != c) {
        final f = a[r][c];
        for (var j = c; j < 5; j++) {
          a[r][j] -= f * a[c][j];
        }
      }
    }
  }
  return a.map((row) => row[4]).toList();
}

double _poly(List<double> c, double t) {
  final x = t / .25;
  return c[0] + x * (c[1] + x * (c[2] + x * c[3]));
}

double _bisect(double Function(double) fn, double lo, double hi) {
  var fl = fn(lo);
  if (fl * fn(hi) > 0) throw StateError('Unbracketed lunar contact');
  for (var i = 0; i < 60 && hi - lo > 1e-10; i++) {
    final m = (lo + hi) / 2, f = fn(m);
    if (fl * f <= 0) {
      hi = m;
    } else {
      lo = m;
      fl = f;
    }
  }
  return (lo + hi) / 2;
}

LunarEclipse? _solve(int k) {
  if (!_passes(k)) return null;
  var t = k.abs() <= 2500
      ? _seed(k)
      : lunarPhaseTimeAccurate((k + .5) * 2 * math.pi) - j2000;
  const h = 60 / 86400;
  for (var i = 0; i < 4; i++) {
    final a = _at(t - h),
        g = _at(t),
        b = _at(t + h),
        fm = dot(a.q, a.q),
        fc = dot(g.q, g.q),
        fp = dot(b.q, b.q),
        curv = fm - 2 * fc + fp;
    double offset;
    if (curv > 0) {
      offset = .5 * h * (fm - fp) / curv;
    } else {
      final v = scale(sub(b.q, a.q), 1 / (2 * h));
      offset = -dot(g.q, v) / dot(v, v);
    }
    offset = offset.clamp(-.25, .25);
    t += offset;
    if (offset.abs() < .001 / 86400) break;
  }
  final g = _at(t);
  if (g.rho > g.penumbra + _rm) return null;
  final kind = g.rho <= g.umbra - _rm
      ? LunarEclipseKind.total
      : g.rho <= g.umbra + _rm
      ? LunarEclipseKind.partial
      : LunarEclipseKind.penumbral;
  final samples = [-.25, -.125, 0.0, .125, .25].map((x) => _at(t + x)).toList();
  final q = List.generate(3, (j) => _fit(samples.map((g) => g.q[j]).toList()));
  final contacts = <LunarEclipseContact, JulianTime?>{};
  for (var b = 0; b < 3; b++) {
    final names = [
      LunarEclipseContact.values[b * 2],
      LunarEclipseContact.values[b * 2 + 1],
    ];
    for (final name in names) {
      contacts[name] = null;
    }
    if (b == 1 && kind == LunarEclipseKind.penumbral ||
        b == 2 && kind != LunarEclipseKind.total) {
      continue;
    }
    final r = _fit(samples.map((g) => g.radius(b)).toList());
    double fun(double x) =>
        q.fold<double>(0, (s, c) => s + math.pow(_poly(c, x), 2)) -
        math.pow(_poly(r, x), 2);
    for (var side = 0; side < 2; side++) {
      final sign = side == 0 ? -1 : 1;
      double? answer;
      for (var i = 0; i < 2; i++) {
        final left = math.min(sign * i * .125, sign * (i + 1) * .125),
            right = math.max(sign * i * .125, sign * (i + 1) * .125);
        if (samples[(left / .125).round() + 2].contact(b) *
                samples[(right / .125).round() + 2].contact(b) >
            0) {
          continue;
        }
        answer = _bisect(
          fun(left) * fun(right) > 0 ? (x) => _at(t + x).contact(b) : fun,
          left,
          right,
        );
        break;
      }
      if (answer == null) throw StateError('Lunar contact bracket failed k=$k');
      contacts[names[side]] = JulianTime.fromTT(j2000 + t + answer);
    }
  }
  final maximum = JulianTime.fromTT(j2000 + t);
  contacts[LunarEclipseContact.maximum] = maximum;
  return LunarEclipse._(
    kind,
    maximum,
    math.max(0, (g.umbra + _rm - g.rho) / (2 * _rm)),
    (g.penumbra + _rm - g.rho) / (2 * _rm),
    contacts,
  );
}

void _checkTime(JulianTime t) {
  if (!t.jdTT.isFinite || !t.jdUT1.isFinite) {
    throw ArgumentError('Eclipse time must be finite');
  }
}

/// Eclipse belonging to the full moon near [date], or null. Not a nearest-eclipse search.
LunarEclipse? getLunarEclipseDetails(JulianTime date) {
  _checkTime(date);
  return _solve(((date.jdTT - j2000 - 4) / _month).floor());
}

/// Global lunar eclipses whose maximum lies in [start,end), at most 5000 lunations.
List<LunarEclipse> searchLunarEclipses(JulianTime start, JulianTime end) {
  _checkTime(start);
  _checkTime(end);
  if (end.jdTT <= start.jdTT) throw RangeError('end must be later than start');
  if (((end.jdTT - start.jdTT) / _month).ceil() + 3 > 5000) {
    throw RangeError('Search exceeds 5000 lunations; split the interval');
  }
  final first = ((start.jdTT - j2000 - 18) / _month).floor() - 1,
      last = ((end.jdTT - j2000 - 18) / _month).ceil() + 1,
      events = <LunarEclipse>[];
  for (var k = first; k <= last; k++) {
    final e = _solve(k);
    if (e == null ||
        e.maximum.jdTT < start.jdTT ||
        e.maximum.jdTT >= end.jdTT) {
      continue;
    }
    if (events.isEmpty ||
        (e.maximum.jdTT - events.last.maximum.jdTT).abs() > 1) {
      events.add(e);
    }
  }
  return List.unmodifiable(events);
}

/// Local contact altitudes and any visible portion. Atmosphere follows the
/// upstream standard 1013.25 mbar / 15 C; input Observer atmosphere is ignored.
LocalLunarEclipse? getLocalLunarEclipse(JulianTime date, Observer location) {
  final observer = Observer(
    longitudeDeg: location.longitudeDeg,
    latitudeDeg: location.latitudeDeg,
    heightMeters: location.heightMeters,
  );
  validateVisibilityObserver(observer);
  final global = getLunarEclipseDetails(date);
  if (global == null) return null;
  final contacts = <LunarEclipseContact, LunarContactCircumstance?>{};
  for (final e in global.contacts.entries) {
    final t = e.value;
    if (t == null) {
      contacts[e.key] = null;
      continue;
    }
    final p = bodyHorizontalPosition(SkyBody.moon, t.jdUT1, observer);
    contacts[e.key] = LunarContactCircumstance._(
      t,
      p.azimuthDeg,
      p.geometricAltitudeDeg,
      p.apparentAltitudeDeg,
    );
  }
  final start = global.contacts[LunarEclipseContact.penumbralBegin]!,
      end = global.contacts[LunarEclipseContact.penumbralEnd]!;
  final rises = <JulianTime>[], sets = <JulianTime>[];
  for (var day = (start.jdUT1 - .5).floor() + .5; day < end.jdUT1; day++) {
    final events = bodyRiseSetForDay(SkyBody.moon, day, observer);
    bool within(JulianTime t) => t.jdUT1 >= start.jdUT1 && t.jdUT1 <= end.jdUT1;
    rises.addAll(events.rises.where(within));
    sets.addAll(events.sets.where(within));
  }
  var visible = contacts.values.any((c) => c?.visible ?? false);
  for (var jd = start.jdUT1; !visible && jd <= end.jdUT1; jd += 1 / 144) {
    visible =
        bodyHorizontalPosition(SkyBody.moon, jd, observer).apparentAltitudeDeg >
        0;
  }
  final clipped = rises.isNotEmpty && sets.isNotEmpty
      ? LunarHorizonClipped.both
      : rises.isNotEmpty
      ? LunarHorizonClipped.moonrise
      : sets.isNotEmpty
      ? LunarHorizonClipped.moonset
      : null;
  return LocalLunarEclipse._(
    global,
    observer,
    visible,
    contacts,
    rises,
    sets,
    clipped,
  );
}
