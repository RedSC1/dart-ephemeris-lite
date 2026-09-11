// Modern cone/WGS84 solar eclipse solver, ported from js-ephemeris-lite.
import 'dart:math' as math;
import 'sun_moon_apparent.dart';
import 'coordinates.dart';
import 'sun_moon_ephemeris.dart';
import 'event_accurate.dart';
import 'sky_math.dart';
import 'time.dart';
import 'solar_time.dart';
import 'observer.dart';
import 'body_visibility.dart';
import 'solar_visibility.dart';
import 'disc_radii.dart';

const _re = 6378.137,
    _rm = .2725076 * _re,
    _rs = 695700.0,
    _b = 1 - 1 / 298.257223563,
    _d = math.pi / 180,
    _month = 29.5306;
const eclipseSearchInfo = {
  'interval': 'half-open [start,end)',
  'maximumLunations': 5000,
  'mapRenderer': false,
};

enum SolarEclipseKind { partial, total, annular, hybrid }

enum LocalSolarEclipseKind { none, partial, total, annular }

enum SolarEclipseContact {
  partialBegin,
  maximum,
  partialEnd,
  centralBegin,
  centralEnd,
}

enum SolarHorizonClipped { sunrise, sunset }

class EclipseLocation {
  final double longitudeDeg, latitudeDeg;
  const EclipseLocation(this.longitudeDeg, this.latitudeDeg);
  Map<String, Object> toJson() => {
    'longitudeDeg': longitudeDeg,
    'latitudeDeg': latitudeDeg,
  };
}

class TimedGroundPoint extends EclipseLocation {
  final JulianTime time;
  const TimedGroundPoint(this.time, super.longitudeDeg, super.latitudeDeg);
  @override
  Map<String, Object> toJson() => {'time': time.toJson(), ...super.toJson()};
}

class SolarEclipseContacts {
  final TimedGroundPoint? partialBegin, centralBegin, centralEnd, partialEnd;
  final JulianTime maximum;
  const SolarEclipseContacts(
    this.partialBegin,
    this.centralBegin,
    this.maximum,
    this.centralEnd,
    this.partialEnd,
  );
  Map<String, Object?> toJson() => {
    'partialBegin': partialBegin?.toJson(),
    'centralBegin': centralBegin?.toJson(),
    'maximum': maximum.toJson(),
    'centralEnd': centralEnd?.toJson(),
    'partialEnd': partialEnd?.toJson(),
  };
}

class SolarEclipse {
  final SolarEclipseKind kind;
  final JulianTime conjunction, maximum;
  final EclipseLocation maximumLocation;
  final double magnitude, pathWidthKm, centralDurationSeconds;
  final SolarEclipseContacts contacts;
  const SolarEclipse._(
    this.kind,
    this.conjunction,
    this.maximum,
    this.maximumLocation,
    this.magnitude,
    this.pathWidthKm,
    this.centralDurationSeconds,
    this.contacts,
  );
  String get code => switch (kind) {
    SolarEclipseKind.partial => 'P',
    SolarEclipseKind.total => 'T',
    SolarEclipseKind.annular => 'A',
    SolarEclipseKind.hybrid => 'H',
  };
  Map<String, Object?> toJson() => {
    'code': code,
    'kind': kind.name,
    'conjunction': conjunction.toJson(),
    'maximum': maximum.toJson(),
    'maximumLocation': maximumLocation.toJson(),
    'magnitude': magnitude,
    'pathWidthKm': pathWidthKm,
    'centralDurationSeconds': centralDurationSeconds,
    'contacts': contacts.toJson(),
  };
}

class LocalSolarEclipse {
  final SolarEclipse global;
  final Observer observer;
  final bool visible;
  final LocalSolarEclipseKind kind;
  final double magnitude;
  final SolarHorizonClipped? horizonClipped;
  final Map<SolarEclipseContact, JulianTime?> contacts;
  final JulianTime? sunrise, sunset;
  LocalSolarEclipse._(
    this.global,
    this.observer,
    this.visible,
    this.kind,
    this.magnitude,
    this.horizonClipped,
    Map<SolarEclipseContact, JulianTime?> contacts,
    this.sunrise,
    this.sunset,
  ) : contacts = Map.unmodifiable(contacts);
  Map<String, Object?> toJson() => {
    'global': global.toJson(),
    'observer': {
      'longitudeDeg': observer.longitudeDeg,
      'latitudeDeg': observer.latitudeDeg,
      'heightMeters': observer.heightMeters,
    },
    'visible': visible,
    'kind': kind.name,
    'magnitude': magnitude,
    'horizonClipped': horizonClipped?.name,
    'contacts': {
      for (final e in contacts.entries) e.key.name: e.value?.toJson(),
    },
    'sunrise': sunrise?.toJson(),
    'sunset': sunset?.toJson(),
  };
}

List<List<double>> _exact(double t) => [
  for (final body in [SkyBody.moon, SkyBody.sun])
    scale(
      apparentBodyPosition(
        body,
        j2000 + t,
        options: const ApparentOptions(solarDeflection: false),
      ).equatorialPositionAu,
      auKm,
    ),
];

class _Provider {
  final double center;
  final nodes = [-1.0, -.5, 0.0, .5, 1.0];
  late final List<List<List<double>>> coefficients;
  _Provider(this.center) {
    final samples = nodes.map((x) => _exact(center + x * .25)).toList();
    coefficients = List.generate(
      2,
      (body) => List.generate(3, (coord) {
        final a = samples.map((p) => p[body][coord]).toList();
        for (var order = 1; order < 5; order++) {
          for (var i = 4; i >= order; i--) {
            a[i] = (a[i] - a[i - 1]) / (nodes[i] - nodes[i - order]);
          }
        }
        return a;
      }),
    );
  }
  List<List<double>> evaluate(double t) {
    final x = (t - center) / .25;
    if (x.abs() > 1) return _exact(t);
    return coefficients
        .map(
          (body) => body.map((a) {
            var v = a[4];
            for (var i = 3; i >= 0; i--) {
              v = v * (x - nodes[i]) + a[i];
            }
            return v;
          }).toList(),
        )
        .toList();
  }
}

class _Elements {
  final double x, y, z, d, l1, l2;
  final List<double> axis, xh, yh, moon, sun;
  _Elements._(
    this.x,
    this.y,
    this.z,
    this.d,
    this.l1,
    this.l2,
    this.axis,
    this.xh,
    this.yh,
    this.moon,
    this.sun,
  );
  factory _Elements(List<List<double>> pair) {
    final moon = pair[0],
        sun = pair[1],
        axis = unit(sub(moon, sun)),
        xh = unit(cross([0, 0, 1], axis)),
        yh = unit(cross(axis, xh)),
        z = -dot(moon, axis) / _re,
        dist = norm(sub(moon, sun));
    return _Elements._(
      dot(moon, xh) / _re,
      dot(moon, yh) / _re,
      z,
      math.asin(axis[2]),
      _rm / _re + z * (_rs + _rm) / dist,
      _rm / _re - z * (_rs - _rm) / dist,
      axis,
      xh,
      yh,
      moon,
      sun,
    );
  }
}

({double disc, double vertex, List<double>? point}) _axis(_Elements e) {
  final origin = [-e.x, e.y, 2.0],
      direction = [0.0, 0.0, -2.0],
      o = rotateX(origin, math.pi / 2 + e.d),
      v = rotateX(direction, math.pi / 2 + e.d);
  double qdot(List<double> a, List<double> b) =>
      a[0] * b[0] + a[1] * b[1] + a[2] * b[2] / (_b * _b);
  final a = qdot(v, v),
      b = qdot(o, v),
      c = qdot(o, o) - 1,
      disc = b * b - a * c,
      vertex = -b / a;
  return (
    disc: disc / a,
    vertex: vertex,
    point: disc >= 0
        ? add(origin, scale(direction, (-b - math.sqrt(disc)) / a))
        : null,
  );
}

({double disc, List<double> point}) _cone(_Elements e, double radius) {
  final angle = math.pi / 2 + e.d,
      c = math.cos(angle),
      s = math.sin(angle),
      inv = 1 / (_b * _b),
      r = _rm / _re,
      delta = radius - r;
  final ox = -e.x,
      oy = e.y * c - e.z * s,
      oz = e.y * s + e.z * c,
      vy = e.z * s,
      vz = -e.z * c;
  final oo = ox * ox + oy * oy + oz * oz * inv,
      vv = vy * vy + vz * vz * inv,
      ov = oy * vy + oz * vz * inv,
      os = oy * c + oz * s * inv,
      vs = vy * c + vz * s * inv,
      ns = c * c + s * s * inv;
  double value(double cosine, double sine) {
    final nn = cosine * cosine + ns * sine * sine,
        on = ox * cosine + os * sine,
        vn = vs * sine,
        a = vv + 2 * delta * vn + delta * delta * nn,
        b = ov + delta * on + r * vn + r * delta * nn;
    if (-b / a <= 0) return double.negativeInfinity;
    final cc = oo + 2 * r * on + r * r * nn - 1;
    return b * b / a - cc;
  }

  double evaluate(double t) => value(math.cos(t), math.sin(t));
  const step = math.pi / 12;
  var best = double.negativeInfinity, at = 0.0;
  for (var i = 0; i < 24; i++) {
    final f = evaluate(i * step);
    if (f > best) {
      best = f;
      at = i * step;
    }
  }
  var lo = at - step, hi = at + step;
  final g = (math.sqrt(5) - 1) / 2;
  var a = hi - g * (hi - lo),
      b = lo + g * (hi - lo),
      fa = evaluate(a),
      fb = evaluate(b);
  for (var i = 0; i < 28; i++) {
    if (fa > fb) {
      hi = b;
      b = a;
      fb = fa;
      a = hi - g * (hi - lo);
      fa = evaluate(a);
    } else {
      lo = a;
      a = b;
      fa = fb;
      b = lo + g * (hi - lo);
      fb = evaluate(b);
    }
  }
  final theta = fa > fb ? a : b,
      cosine = math.cos(theta),
      sine = math.sin(theta),
      origin = [-e.x + r * cosine, e.y + r * sine, e.z],
      direction = [delta * cosine, delta * sine, -e.z];
  final nn = cosine * cosine + ns * sine * sine,
      on = ox * cosine + os * sine,
      vn = vs * sine,
      qa = vv + 2 * delta * vn + delta * delta * nn,
      qb = ov + delta * on + r * vn + r * delta * nn;
  return (
    disc: math.max(fa, fb),
    point: List.generate(3, (i) => origin[i] - direction[i] * qb / qa),
  );
}

double? _contact(double Function(double) fn, double t, int side) {
  var inner = t, fi = fn(t);
  double? outer, fo;
  if (fi < 0) return null;
  for (final h in [.5, 1, 2, 4, 8, 12]) {
    final x = t + side * h / 24, f = fn(x);
    if (f <= 0) {
      outer = x;
      fo = f;
      break;
    }
    inner = x;
    fi = f;
  }
  if (outer == null) throw StateError('Contact outside 12-hour bracket');
  var lo = side < 0 ? outer : inner,
      hi = side < 0 ? inner : outer,
      fl = side < 0 ? fo! : fi,
      fh = side < 0 ? fi : fo!,
      last = 0;
  for (var i = 0; i < 40 && hi - lo > .02 / 86400; i++) {
    var fraction = -fl / (fh - fl);
    if (!(fraction > .05 && fraction < .95)) fraction = .5;
    final m = lo + fraction * (hi - lo), f = fn(m);
    if (fl * f <= 0) {
      hi = m;
      fh = f;
      if (last == 1) fl *= .5;
      last = 1;
    } else {
      lo = m;
      fl = f;
      if (last == -1) fh *= .5;
      last = -1;
    }
  }
  return (lo + hi) / 2;
}

class _Solar {
  SolarEclipseKind kind;
  final double maximum, conjunction;
  final Map<SolarEclipseContact, double?> contacts;
  final _Provider provider;
  _Solar(
    this.kind,
    this.maximum,
    this.conjunction,
    this.contacts,
    this.provider,
  );
  _Elements at(double t) => _Elements(provider.evaluate(t));
}

_Solar? _solve(int k) {
  if (k.abs() <= 2500) {
    final h = k.toDouble(),
        t = h / 1236.85,
        f =
            (160.7108 +
                390.67050274 * h -
                .0016341 * t * t -
                .00000227 * t * t * t +
                .000000011 * t * t * t * t) *
            _d;
    if (math.sin(f).abs() > math.sin(23 * _d)) return null;
  }
  final seed = lunarPhaseTimeAccurate(k * 2 * math.pi) - j2000,
      provider = _Provider(seed);
  _Elements at(double t) => _Elements(provider.evaluate(t));
  double rho(double t) {
    final e = at(t);
    return (e.x * e.x + e.y * e.y) * _re * _re;
  }

  var t = seed;
  for (final h in [.0625, 1 / 1440, .25 / 1440, .0625 / 1440]) {
    final fm = rho(t - h), f = rho(t), fp = rho(t + h), c = fm - 2 * f + fp;
    if (c.abs() > 1e-12) t += (.5 * (fm - fp) / c * h).clamp(-h, h);
  }
  final e = at(t);
  double partial(double t) {
    final g = at(t);
    return _cone(g, g.l1).disc;
  }

  double central(double t) => _axis(at(t)).disc;
  if (partial(t) < 0) return null;
  var kind = _cone(e, e.l2).disc >= 0
      ? (e.l2 >= 0 ? SolarEclipseKind.total : SolarEclipseKind.annular)
      : SolarEclipseKind.partial;
  final contacts = <SolarEclipseContact, double?>{
    SolarEclipseContact.partialBegin: _contact(partial, t, -1),
    SolarEclipseContact.partialEnd: _contact(partial, t, 1),
    SolarEclipseContact.centralBegin: null,
    SolarEclipseContact.centralEnd: null,
  };
  if (central(t) >= 0) {
    contacts[SolarEclipseContact.centralBegin] = _contact(central, t, -1);
    contacts[SolarEclipseContact.centralEnd] = _contact(central, t, 1);
    final signs = <double>[];
    for (final time in [
      t,
      contacts[SolarEclipseContact.centralBegin]! + 10 / 86400,
      contacts[SolarEclipseContact.centralEnd]! - 10 / 86400,
    ]) {
      final g = at(time), hit = _axis(g);
      if (hit.point == null) continue;
      signs.add(g.l2 + (_rm / _re - g.l2) / g.z * hit.point![2]);
    }
    if (signs.any((x) => x > 0) && signs.any((x) => x < 0)) {
      kind = SolarEclipseKind.hybrid;
    } else if (signs.isNotEmpty) {
      kind = signs[0] > 0 ? SolarEclipseKind.total : SolarEclipseKind.annular;
    }
  }
  return _Solar(kind, t, seed, contacts, provider);
}

double _sidereal(double t) {
  final time = JulianTime.fromTT(j2000 + t);
  return greenwichApparentSiderealTimeRadians(
    time.jdUT1,
    time.jdTT,
    nutation: iau2000bNutation(time.jdTT),
  );
}

List<double> _shadow(_Elements e, List<double> p) => add(
  add(scale(e.xh, -p[0] * _re), scale(e.yh, p[1] * _re)),
  scale(e.axis, -p[2] * _re),
);
List<double> _surface(List<double> v) => scale(
  v,
  _re / math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2] / (_b * _b)),
);
EclipseLocation _location(List<double> v, double t) => EclipseLocation(
  signedDeg((math.atan2(v[1], v[0]) - _sidereal(t)) / _d),
  math.atan2(v[2] / (_b * _b), math.sqrt(v[0] * v[0] + v[1] * v[1])) / _d,
);
List<double> _observer(double t, Observer o) {
  final phi = o.latitudeDeg * _d,
      theta = o.longitudeDeg * _d + _sidereal(t),
      n = _re / math.sqrt(1 - (1 - _b * _b) * math.pow(math.sin(phi), 2)),
      h = o.heightMeters / 1000;
  return [
    (n + h) * math.cos(phi) * math.cos(theta),
    (n + h) * math.cos(phi) * math.sin(theta),
    (n * _b * _b + h) * math.sin(phi),
  ];
}

({double separation, double mr, double sr, double magnitude}) _disks(
  List<List<double>> pair,
  List<double> position,
) {
  final moon = sub(pair[0], position),
      sun = sub(pair[1], position),
      separation = math.atan2(norm(cross(moon, sun)), dot(moon, sun)),
      mr = math.asin(_rm / norm(moon)),
      sr = math.asin(_rs / norm(sun));
  return (
    separation: separation,
    mr: mr,
    sr: sr,
    magnitude: (mr + sr - separation) / (2 * sr),
  );
}

double _minimize(double Function(double) fn, double lo, double hi) {
  final ratio = (math.sqrt(5) - 1) / 2;
  var a = hi - ratio * (hi - lo),
      b = lo + ratio * (hi - lo),
      fa = fn(a),
      fb = fn(b);
  for (var i = 0; i < 64 && hi - lo > .002 / 86400; i++) {
    if (fa < fb) {
      hi = b;
      b = a;
      fb = fa;
      a = hi - ratio * (hi - lo);
      fa = fn(a);
    } else {
      lo = a;
      a = b;
      fa = fb;
      b = lo + ratio * (hi - lo);
      fb = fn(b);
    }
  }
  return (lo + hi) / 2;
}

class _Local {
  final LocalSolarEclipseKind kind;
  final double magnitude;
  final Map<SolarEclipseContact, double?> contacts;
  _Local(this.kind, this.magnitude, this.contacts);
}

_Local _local(_Solar event, Observer observer) {
  at(double t) => _disks(event.provider.evaluate(t), _observer(t, observer));
  final maximum = _minimize(
        (t) => -at(t).magnitude,
        event.maximum - .2,
        event.maximum + .2,
      ),
      g = at(maximum),
      contacts = {
        for (final c in SolarEclipseContact.values) c: null as double?,
      };
  if (g.magnitude <= 0) return _Local(LocalSolarEclipseKind.none, 0, contacts);
  double partial(double t) {
    final g = at(t);
    return g.mr + g.sr - g.separation;
  }

  contacts[SolarEclipseContact.maximum] = maximum;
  contacts[SolarEclipseContact.partialBegin] = _contact(partial, maximum, -1);
  contacts[SolarEclipseContact.partialEnd] = _contact(partial, maximum, 1);
  var kind = LocalSolarEclipseKind.partial;
  if (g.separation < (g.mr - g.sr).abs()) {
    kind = g.mr > g.sr
        ? LocalSolarEclipseKind.total
        : LocalSolarEclipseKind.annular;
    double central(double t) {
      final g = at(t);
      return (g.mr - g.sr).abs() - g.separation;
    }

    contacts[SolarEclipseContact.centralBegin] = _contact(central, maximum, -1);
    contacts[SolarEclipseContact.centralEnd] = _contact(central, maximum, 1);
  }
  return _Local(kind, g.magnitude, contacts);
}

TimedGroundPoint? _ground(_Solar event, double? t, {bool central = false}) {
  if (t == null) return null;
  final e = event.at(t);
  List<double> point;
  if (central) {
    final hit = _axis(e);
    point = hit.point ?? [-e.x, e.y, 2 - 2 * hit.vertex];
  } else {
    point = _cone(e, e.l1).point;
  }
  final l = _location(_surface(_shadow(e, point)), t);
  return TimedGroundPoint(
    JulianTime.fromTT(j2000 + t),
    l.longitudeDeg,
    l.latitudeDeg,
  );
}

({EclipseLocation location, double magnitude, double width, double duration})
_details(_Solar event) {
  final t = event.maximum, e = event.at(t), hit = _axis(e);
  List<double> v;
  if (hit.point != null) {
    v = _shadow(e, hit.point!);
  } else {
    v = _surface(_shadow(e, _cone(e, e.l1).point));
    var step = .1;
    final pair = event.provider.evaluate(t);
    for (var i = 0; i < 60 && step > 1e-8; i++) {
      final normal = unit(v),
          east = unit(cross([0, 0, 1], normal)),
          north = unit(cross(normal, east));
      var best = v, score = _disks(pair, v).magnitude;
      for (final direction in [east, north]) {
        for (final sign in [-1, 1]) {
          final candidate = _surface(
                add(v, scale(direction, _re * step * sign)),
              ),
              value = _disks(pair, candidate).magnitude;
          if (value > score) {
            best = candidate;
            score = value;
          }
        }
      }
      if (identical(best, v)) step *= .5;
      v = best;
    }
  }
  final l = _location(v, t), g = _disks(event.provider.evaluate(t), v);
  var width = 0.0, duration = 0.0;
  if (hit.point != null) {
    final local = _local(
          event,
          Observer(longitudeDeg: l.longitudeDeg, latitudeDeg: l.latitudeDeg),
        ),
        begin = local.contacts[SolarEclipseContact.centralBegin],
        end = local.contacts[SolarEclipseContact.centralEnd];
    if (begin != null) duration = (end! - begin) * 86400;
    final positions = <List<double>?>[];
    for (final time in [t - 1 / 1440, t + 1 / 1440]) {
      final a = event.at(time), p = _axis(a).point;
      if (p == null) {
        positions.add(null);
      } else {
        final l = _location(_shadow(a, p), time);
        positions.add(
          _observer(
            t,
            Observer(longitudeDeg: l.longitudeDeg, latitudeDeg: l.latitudeDeg),
          ),
        );
      }
    }
    if (positions.every((p) => p != null)) {
      final normal = unit([v[0], v[1], v[2] / (_b * _b)]),
          across = unit(cross(normal, sub(positions[1]!, positions[0]!)));
      double boundary(double angle) {
        final point = _surface(
              add(
                scale(v, math.cos(angle)),
                scale(across, _re * math.sin(angle)),
              ),
            ),
            d = _disks(event.provider.evaluate(t), point);
        return (d.mr - d.sr).abs() - d.separation;
      }

      final widths = <double>[];
      for (final sign in [-1, 1]) {
        var lo = 0.0, hi = .001;
        while (hi < 1.5 && boundary(sign * hi) > 0) {
          hi *= 2;
        }
        if (boundary(sign * hi) > 0) break;
        for (var i = 0; i < 32; i++) {
          final mid = (lo + hi) / 2;
          if (boundary(sign * mid) > 0) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        widths.add((lo + hi) / 2 * _re);
      }
      if (widths.length == 2) width = widths[0] + widths[1];
    }
  }
  return (
    location: l,
    magnitude: hit.point != null ? g.mr / g.sr : math.max(0, g.magnitude),
    width: width,
    duration: duration,
  );
}

SolarEclipse _event(_Solar e) {
  final d = _details(e), maximum = JulianTime.fromTT(j2000 + e.maximum);
  return SolarEclipse._(
    e.kind,
    JulianTime.fromTT(j2000 + e.conjunction),
    maximum,
    d.location,
    d.magnitude,
    d.width,
    d.duration,
    SolarEclipseContacts(
      _ground(e, e.contacts[SolarEclipseContact.partialBegin]),
      _ground(e, e.contacts[SolarEclipseContact.centralBegin], central: true),
      maximum,
      _ground(e, e.contacts[SolarEclipseContact.centralEnd], central: true),
      _ground(e, e.contacts[SolarEclipseContact.partialEnd]),
    ),
  );
}

void _check(JulianTime t) {
  if (!t.jdTT.isFinite || !t.jdUT1.isFinite) {
    throw ArgumentError('Eclipse time must be finite');
  }
}

SolarEclipse? getSolarEclipseDetails(JulianTime date) {
  _check(date);
  final e = _solve(((date.jdTT - j2000 + 8) / _month).floor());
  return e == null ? null : _event(e);
}

List<SolarEclipse> searchSolarEclipses(JulianTime start, JulianTime end) {
  _check(start);
  _check(end);
  if (end.jdTT <= start.jdTT) throw RangeError('end must be later than start');
  if (((end.jdTT - start.jdTT) / _month).ceil() + 3 > 5000) {
    throw RangeError('Search exceeds 5000 lunations');
  }
  final first = ((start.jdTT - j2000 + 8) / _month).floor() - 1,
      last = ((end.jdTT - j2000 + 8) / _month).ceil() + 1,
      result = <SolarEclipse>[];
  for (var k = first; k <= last; k++) {
    final raw = _solve(k);
    if (raw == null) continue;
    final e = _event(raw);
    if (e.maximum.jdTT < start.jdTT || e.maximum.jdTT >= end.jdTT) continue;
    if (result.isEmpty ||
        (e.maximum.jdTT - result.last.maximum.jdTT).abs() > 1) {
      result.add(e);
    }
  }
  return List.unmodifiable(result);
}

LocalSolarEclipse? getLocalSolarEclipse(JulianTime date, Observer location) {
  final observer = Observer(
    longitudeDeg: location.longitudeDeg,
    latitudeDeg: location.latitudeDeg,
    heightMeters: location.heightMeters,
  );
  validateVisibilityObserver(observer);
  _check(date);
  final event = _solve(((date.jdTT - j2000 + 8) / _month).floor());
  if (event == null) return null;
  final global = _event(event),
      local = _local(event, observer),
      contacts = {
        for (final e in local.contacts.entries)
          e.key: e.value == null ? null : JulianTime.fromTT(j2000 + e.value!),
      };
  final horizon = <({JulianTime time, SolarHorizonClipped kind})>[];
  final day = (global.maximum.jdUT1 - .5).floor() + .5;
  for (var d = day - 1; d <= day + 1; d++) {
    final r = bodyRiseSetForDay(SkyBody.sun, d, observer);
    horizon.addAll(
      r.rises.map((t) => (time: t, kind: SolarHorizonClipped.sunrise)),
    );
    horizon.addAll(
      r.sets.map((t) => (time: t, kind: SolarHorizonClipped.sunset)),
    );
  }
  JulianTime? nearest(SolarHorizonClipped kind) {
    final a = horizon.where((e) => e.kind == kind).toList()
      ..sort(
        (a, b) => (a.time.jdTT - global.maximum.jdTT).abs().compareTo(
          (b.time.jdTT - global.maximum.jdTT).abs(),
        ),
      );
    return a.isEmpty ? null : a[0].time;
  }

  bool above(JulianTime time) {
    final p = bodyHorizontalPosition(SkyBody.sun, time.jdUT1, observer),
        limb =
            p.geometricAltitudeDeg * _d +
            math.asin(bodyDiscRadiusKm[SkyBody.sun]! / (auKm * p.distanceAu));
    return limb + hybridAtmosphericRefraction(limb) > 0;
  }

  var visible = false, magnitude = local.magnitude, kind = local.kind;
  SolarHorizonClipped? clipped;
  final begin = contacts[SolarEclipseContact.partialBegin],
      end = contacts[SolarEclipseContact.partialEnd];
  if (begin != null && end != null) {
    final crossings =
        horizon
            .where((e) => e.time.jdTT >= begin.jdTT && e.time.jdTT <= end.jdTT)
            .toList()
          ..sort((a, b) => a.time.jdTT.compareTo(b.time.jdTT));
    visible =
        above(contacts[SolarEclipseContact.maximum]!) || crossings.isNotEmpty;
    if (crossings.isNotEmpty) clipped = crossings[0].kind;
    for (final key in contacts.keys) {
      final t = contacts[key];
      if (t != null && !above(t)) contacts[key] = null;
    }
    if (visible &&
        contacts[SolarEclipseContact.maximum] == null &&
        crossings.isNotEmpty) {
      final candidates =
          crossings
              .map(
                (e) => _disks(
                  event.provider.evaluate(e.time.jdTT - j2000),
                  _observer(e.time.jdTT - j2000, observer),
                ).magnitude,
              )
              .toList()
            ..sort((a, b) => b.compareTo(a));
      magnitude = math.max(0, candidates.first);
    }
  }
  if (!visible) {
    kind = LocalSolarEclipseKind.none;
    magnitude = 0;
    for (final key in contacts.keys) {
      contacts[key] = null;
    }
  } else if (contacts[SolarEclipseContact.centralBegin] == null &&
      contacts[SolarEclipseContact.centralEnd] == null &&
      kind != LocalSolarEclipseKind.partial) {
    kind = LocalSolarEclipseKind.partial;
  }
  return LocalSolarEclipse._(
    global,
    observer,
    visible,
    kind,
    magnitude,
    clipped,
    contacts,
    nearest(SolarHorizonClipped.sunrise),
    nearest(SolarHorizonClipped.sunset),
  );
}
