// TSC1 binary catalog and linear space-motion model. Catalog data is external.
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'apparent_core.dart';
import 'coordinates.dart';
import 'sun_moon_ephemeris.dart';
import 'sky_math.dart';

const tsc1Version = 1;
const tsc1HeaderSize = 132;
const tsc1StarRecordSize = 92;
const tsc1AliasRecordSize = 16;
const tsc1AstrometrySource = {
  'UNKNOWN': 0,
  'GAIA_DR3': 1,
  'HIPPARCOS': 2,
  'BSC5': 3,
  'MANUAL': 4,
};
const tsc1StarFlags = {
  'HAS_GAIA_ID': 1,
  'HAS_HIP_ID': 2,
  'HAS_HR_ID': 4,
  'HAS_HD_ID': 8,
  'HAS_RADIAL_VELOCITY': 16,
  'HAS_PARALLAX': 32,
  'SPECIAL_DIRECTION': 64,
};
String normalizeTsc1Alias(String value) {
  var result = '', last = false;
  for (final code in value.runes) {
    final c = String.fromCharCode(code);
    if (code >= 128) {
      result += c;
      last = false;
    } else if (code >= 48 && code <= 57 ||
        code >= 65 && code <= 90 ||
        code >= 97 && code <= 122) {
      result += c.toLowerCase();
      last = false;
    } else if (c == '_' || c == '-' || RegExp(r'\s').hasMatch(c)) {
      if (result.isNotEmpty && !last) {
        result += '_';
        last = true;
      }
    }
  }
  return result.endsWith('_') ? result.substring(0, result.length - 1) : result;
}

BigInt tsc1AliasHash(Object value) {
  final bytes = value is String
      ? utf8.encode(value)
      : value is List<int>
      ? value
      : throw ArgumentError('Expected string or bytes');
  var result = BigInt.parse('14695981039346656037');
  final prime = BigInt.parse('1099511628211'),
      mask = BigInt.parse('ffffffffffffffff', radix: 16);
  for (final b in bytes) {
    result = ((result ^ BigInt.from(b)) * prime) & mask;
  }
  return result;
}

class Tsc1StarRecord {
  final int index, hipId, hrId, hdId, astrometrySource, flags;
  final String canonicalId, displayName;
  final BigInt gaiaDr3SourceId;
  final double rightAscensionDeg,
      declinationDeg,
      properMotionRaMasPerYear,
      properMotionDecMasPerYear,
      parallaxMas,
      radialVelocityKmPerSecond,
      referenceEpoch,
      magnitude;
  const Tsc1StarRecord._(
    this.index,
    this.canonicalId,
    this.displayName,
    this.gaiaDr3SourceId,
    this.hipId,
    this.hrId,
    this.hdId,
    this.rightAscensionDeg,
    this.declinationDeg,
    this.properMotionRaMasPerYear,
    this.properMotionDecMasPerYear,
    this.parallaxMas,
    this.radialVelocityKmPerSecond,
    this.referenceEpoch,
    this.magnitude,
    this.astrometrySource,
    this.flags,
  );
  Map<String, Object?> toJson() =>
      {
        'index': index,
        'canonicalId': canonicalId,
        'displayName': displayName,
        'gaiaDr3SourceId': gaiaDr3SourceId.toString(),
        'hipId': hipId,
        'hrId': hrId,
        'hdId': hdId,
        'rightAscensionDeg': rightAscensionDeg,
        'declinationDeg': declinationDeg,
        'properMotionRaMasPerYear': properMotionRaMasPerYear,
        'properMotionDecMasPerYear': properMotionDecMasPerYear,
        'parallaxMas': parallaxMas,
        'radialVelocityKmPerSecond': radialVelocityKmPerSecond,
        'referenceEpoch': referenceEpoch,
        'magnitude': magnitude,
        'astrometrySource': astrometrySource,
        'flags': flags,
      }.map(
        (key, value) =>
            MapEntry(key, value is double && !value.isFinite ? null : value),
      );
}

/// Owns an immutable snapshot; 64-bit IDs/hashes use BigInt on VM and web.
class Tsc1Catalog extends Iterable<Tsc1StarRecord> {
  final Uint8List bytes;
  late final ByteData _view;
  late final int version,
      flags,
      starCount,
      aliasCount,
      _stars,
      _aliases,
      _strings,
      _stringSize;
  late final double catalogMinEpoch, catalogMaxEpoch;
  final _stringCache = <int, String>{0: ''},
      _recordCache = <int, Tsc1StarRecord>{};
  Tsc1Catalog(Uint8List input)
    : bytes = Uint8List.fromList(input).asUnmodifiableView() {
    _view = ByteData.sublistView(bytes);
    if (bytes.length < tsc1HeaderSize ||
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) != 'TSC1') {
      throw FormatException('Not a TSC1 catalog');
    }
    version = _u32(4);
    if (version != 1) {
      throw FormatException('Unsupported TSC1 version $version');
    }
    flags = _u32(8);
    starCount = _u32(12);
    aliasCount = _u32(16);
    _stars = _offset(20);
    _aliases = _offset(28);
    _strings = _offset(36);
    _stringSize = _offset(44);
    catalogMinEpoch = _f64(52);
    catalogMaxEpoch = _f64(60);
    _range(_stars, starCount, 92);
    _range(_aliases, aliasCount, 16);
    _range(_strings, _stringSize, 1);
    if (_stringSize == 0 || bytes[_strings] != 0) {
      throw FormatException('Invalid TSC1 string table');
    }
    var previous = BigInt.from(-1);
    var previousAlias = <int>[];
    for (var i = 0; i < starCount; i++) {
      _encoded(_u32(_stars + i * 92));
      _encoded(_u32(_stars + i * 92 + 4));
    }
    for (var i = 0; i < aliasCount; i++) {
      final o = _aliases + i * 16,
          encoded = _encoded(_u32(o)),
          hash = _u64(o + 8);
      if (_u32(o + 4) >= starCount) {
        throw RangeError('Alias outside star table');
      }
      if (hash < previous ||
          hash == previous && _compare(encoded, previousAlias) < 0) {
        throw FormatException('Unsorted TSC1 aliases');
      }
      previous = hash;
      previousAlias = encoded;
    }
  }
  int _u32(int o) => _view.getUint32(o, Endian.little);
  double _f64(int o) => _view.getFloat64(o, Endian.little);
  BigInt _u64(int o) => (BigInt.from(_u32(o + 4)) << 32) | BigInt.from(_u32(o));
  int _offset(int o) {
    final n = _u64(o);
    if (n > BigInt.from(9007199254740991)) {
      throw RangeError('Unsafe catalog offset');
    }
    return n.toInt();
  }

  void _range(int o, int count, int size) {
    if (o < 0 ||
        count < 0 ||
        o > bytes.length ||
        count * size > bytes.length - o) {
      throw RangeError('TSC1 range outside file');
    }
  }

  List<int> _encoded(int o) {
    if (o < 0 || o >= _stringSize) {
      throw RangeError('String offset outside table');
    }
    final start = _strings + o, limit = _strings + _stringSize;
    var end = start;
    while (end < limit && bytes[end] != 0) {
      end++;
    }
    if (end == limit) throw FormatException('Unterminated TSC1 string');
    return Uint8List.sublistView(bytes, start, end);
  }

  String string(int offset) =>
      _stringCache.putIfAbsent(offset, () => utf8.decode(_encoded(offset)));
  Tsc1StarRecord getStar(int index) {
    if (index < 0 || index >= starCount) {
      throw RangeError('Star index outside catalog');
    }
    return _recordCache.putIfAbsent(index, () {
      final o = _stars + index * 92;
      return Tsc1StarRecord._(
        index,
        string(_u32(o)),
        string(_u32(o + 4)),
        _u64(o + 8),
        _u32(o + 16),
        _u32(o + 20),
        _u32(o + 24),
        _f64(o + 28),
        _f64(o + 36),
        _f64(o + 44),
        _f64(o + 52),
        _f64(o + 60),
        _f64(o + 68),
        _f64(o + 76),
        _view.getFloat32(o + 84, Endian.little),
        _view.getUint16(o + 88, Endian.little),
        _view.getUint16(o + 90, Endian.little),
      );
    });
  }

  Tsc1StarRecord? find(String key) {
    final normalized = normalizeTsc1Alias(key);
    if (normalized.isEmpty) return null;
    final encoded = utf8.encode(normalized), hash = tsc1AliasHash(encoded);
    var low = 0, high = aliasCount;
    while (low < high) {
      final mid = low + (high - low) ~/ 2;
      if (_u64(_aliases + mid * 16 + 8) < hash) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    for (var i = low; i < aliasCount; i++) {
      final o = _aliases + i * 16;
      if (_u64(o + 8) != hash) break;
      if (_compare(_encoded(_u32(o)), encoded) == 0) {
        return getStar(_u32(o + 4));
      }
    }
    return null;
  }

  Iterable<Tsc1StarRecord> _records() sync* {
    for (var i = 0; i < starCount; i++) {
      yield getStar(i);
    }
  }

  @override
  Iterator<Tsc1StarRecord> get iterator => _records().iterator;
}

int _compare(List<int> a, List<int> b) {
  for (var i = 0; i < math.min(a.length, b.length); i++) {
    if (a[i] != b[i]) return a[i] - b[i];
  }
  return a.length - b.length;
}

Tsc1Catalog parseTsc1Catalog(Uint8List bytes) => Tsc1Catalog(bytes);
Tsc1StarRecord _resolve(Tsc1Catalog c, Object star) => switch (star) {
  int i => c.getStar(i),
  String s => c.find(s) ?? (throw RangeError('Star not present: $s')),
  Tsc1StarRecord r => c.getStar(r.index),
  _ => throw ArgumentError('Expected catalog key, index or record'),
};

class FixedStarIcrfState {
  final Tsc1StarRecord star;
  final double jdTT, referenceJdTT;
  final List<double> positionAu, velocityAuPerDay;
  FixedStarIcrfState._(
    this.star,
    this.jdTT,
    this.referenceJdTT,
    List<double> p,
    List<double> v,
  ) : positionAu = List.unmodifiable(p),
      velocityAuPerDay = List.unmodifiable(v);
  Map<String, Object> toJson() => {
    'star': star.toJson(),
    'jdTT': jdTT,
    'referenceJdTT': referenceJdTT,
    'positionAu': positionAu,
    'velocityAuPerDay': velocityAuPerDay,
  };
}

class FixedStarOptions {
  final SkyFrame frame;
  final bool aberration, solarDeflection;
  const FixedStarOptions({
    this.frame = SkyFrame.trueOfDate,
    this.aberration = true,
    this.solarDeflection = true,
  });
}

class FixedStarPosition {
  final Tsc1StarRecord star;
  final double jdTT,
      longitudeDeg,
      latitudeDeg,
      distanceAu,
      rightAscensionDeg,
      declinationDeg;
  final SkyFrame frame;
  final List<double> astrometricPositionAu,
      eclipticPositionAu,
      equatorialPositionAu;
  FixedStarPosition._(
    this.star,
    this.jdTT,
    this.frame,
    List<double> a,
    List<double> e,
    List<double> q,
  ) : astrometricPositionAu = List.unmodifiable(a),
      eclipticPositionAu = List.unmodifiable(e),
      equatorialPositionAu = List.unmodifiable(q),
      longitudeDeg = spherical(e).longitudeDeg,
      latitudeDeg = spherical(e).latitudeDeg,
      distanceAu = norm(e),
      rightAscensionDeg = spherical(q).longitudeDeg,
      declinationDeg = spherical(q).latitudeDeg;
  Map<String, Object> toJson() => {
    'star': star.toJson(),
    'jdTT': jdTT,
    'frame': switch (frame) {
      SkyFrame.j2000 => 'j2000',
      SkyFrame.meanOfDate => 'mean-of-date',
      SkyFrame.trueOfDate => 'true-of-date',
    },
    'longitudeDeg': longitudeDeg,
    'latitudeDeg': latitudeDeg,
    'distanceAu': distanceAu,
    'rightAscensionDeg': rightAscensionDeg,
    'declinationDeg': declinationDeg,
    'astrometricPositionAu': astrometricPositionAu,
    'eclipticPositionAu': eclipticPositionAu,
    'equatorialPositionAu': equatorialPositionAu,
  };
}

class FixedStarState extends FixedStarPosition {
  final double longitudeSpeedDegPerDay,
      latitudeSpeedDegPerDay,
      rightAscensionSpeedDegPerDay,
      declinationSpeedDegPerDay,
      distanceSpeedAuPerDay;
  final List<double> eclipticVelocityAuPerDay, equatorialVelocityAuPerDay;
  FixedStarState._(
    FixedStarPosition c,
    FixedStarPosition before,
    FixedStarPosition after,
    double dt,
  ) : longitudeSpeedDegPerDay =
          signedDeg(after.longitudeDeg - before.longitudeDeg) / dt,
      latitudeSpeedDegPerDay = (after.latitudeDeg - before.latitudeDeg) / dt,
      rightAscensionSpeedDegPerDay =
          signedDeg(after.rightAscensionDeg - before.rightAscensionDeg) / dt,
      declinationSpeedDegPerDay =
          (after.declinationDeg - before.declinationDeg) / dt,
      distanceSpeedAuPerDay = (after.distanceAu - before.distanceAu) / dt,
      eclipticVelocityAuPerDay = List.unmodifiable(
        scale(sub(after.eclipticPositionAu, before.eclipticPositionAu), 1 / dt),
      ),
      equatorialVelocityAuPerDay = List.unmodifiable(
        scale(
          sub(after.equatorialPositionAu, before.equatorialPositionAu),
          1 / dt,
        ),
      ),
      super._(
        c.star,
        c.jdTT,
        c.frame,
        c.astrometricPositionAu,
        c.eclipticPositionAu,
        c.equatorialPositionAu,
      );
  @override
  Map<String, Object> toJson() => {
    ...super.toJson(),
    'longitudeSpeedDegPerDay': longitudeSpeedDegPerDay,
    'latitudeSpeedDegPerDay': latitudeSpeedDegPerDay,
    'rightAscensionSpeedDegPerDay': rightAscensionSpeedDegPerDay,
    'declinationSpeedDegPerDay': declinationSpeedDegPerDay,
    'distanceSpeedAuPerDay': distanceSpeedAuPerDay,
    'eclipticVelocityAuPerDay': eclipticVelocityAuPerDay,
    'equatorialVelocityAuPerDay': equatorialVelocityAuPerDay,
  };
}

FixedStarIcrfState fixedStarIcrfState(
  Tsc1Catalog catalog,
  Object star,
  double jdTT,
) {
  if (!jdTT.isFinite) throw ArgumentError('jdTT must be finite');
  final r = _resolve(catalog, star),
      ra = r.rightAscensionDeg / rad,
      dec = r.declinationDeg / rad;
  final direction = [
    math.cos(dec) * math.cos(ra),
    math.cos(dec) * math.sin(ra),
    math.sin(dec),
  ];
  final parallax =
          (r.flags & 32) != 0 && r.parallaxMas.isFinite && r.parallaxMas > 0,
      distance = parallax ? 648000000 / math.pi / r.parallaxMas : 1e9;
  final alpha = [-math.sin(ra), math.cos(ra), 0.0],
      beta = [
        -math.sin(dec) * math.cos(ra),
        -math.sin(dec) * math.sin(ra),
        math.cos(dec),
      ];
  final pmRa = r.properMotionRaMasPerYear.isFinite
          ? r.properMotionRaMasPerYear
          : 0.0,
      pmDec = r.properMotionDecMasPerYear.isFinite
          ? r.properMotionDecMasPerYear
          : 0.0,
      rv = (r.flags & 16) != 0 && r.radialVelocityKmPerSecond.isFinite
          ? r.radialVelocityKmPerSecond
          : 0.0;
  final alphaSpeed = parallax
          ? pmRa / (r.parallaxMas * 365.25)
          : pmRa * (math.pi / 648000) / 1000 / 365.25 * distance,
      betaSpeed = parallax
          ? pmDec / (r.parallaxMas * 365.25)
          : pmDec * (math.pi / 648000) / 1000 / 365.25 * distance;
  final velocity = add(
    scale(direction, rv * 86400 / auKm),
    add(scale(alpha, alphaSpeed), scale(beta, betaSpeed)),
  );
  final epoch = r.referenceEpoch.isFinite ? r.referenceEpoch : 2000.0,
      reference = j2000 + (epoch - 2000) * 365.25;
  return FixedStarIcrfState._(
    r,
    jdTT,
    reference,
    add(scale(direction, distance), scale(velocity, jdTT - reference)),
    velocity,
  );
}

FixedStarPosition fixedStarPosition(
  Tsc1Catalog catalog,
  Object star,
  double jdTT, {
  FixedStarOptions options = const FixedStarOptions(),
}) {
  final icrf = fixedStarIcrfState(catalog, star, jdTT),
      target = icrfEquatorialToJ2000Ecliptic(icrf.positionAu),
      earth = earthState(jdTT);
  var position = sub(target, earth.position);
  final astrometric = position;
  if (options.solarDeflection) {
    final distance = norm(position),
        ed = norm(earth.position),
        p = unit(position),
        e = unit(earth.position),
        q = unit(target),
        limb = 695700 / auKm / ed,
        denominator = math.max(1 + dot(q, e), limb * limb / 2),
        weight = 1.97412574336e-8 / ed / denominator;
    position = scale(
      unit(add(p, scale(cross(p, cross(e, q)), weight))),
      distance,
    );
  }
  if (options.aberration) {
    final distance = norm(position),
        p = scale(position, 1 / distance),
        beta = scale(earth.velocity, (auKm / 299792.458 / 86400)),
        inverseGamma = math.sqrt(1 - dot(beta, beta)),
        product = dot(p, beta);
    position = scale(
      unit(
        add(
          scale(p, inverseGamma),
          scale(beta, 1 + product / (1 + inverseGamma)),
        ),
      ),
      distance,
    );
  }
  final n = iau2000bNutation(jdTT);
  var ecliptic = position, obliquity = 84381.406 * math.pi / 648000;
  if (options.frame != SkyFrame.j2000) {
    ecliptic = transform(meanEclipticOfDateMatrixState(jdTT).matrix, position);
    obliquity = n.meanObliquity;
    if (options.frame == SkyFrame.trueOfDate) {
      ecliptic = rotateZ(ecliptic, n.dpsi);
      obliquity = n.trueObliquity;
    }
  }
  return FixedStarPosition._(
    icrf.star,
    jdTT,
    options.frame,
    astrometric,
    ecliptic,
    rotateX(ecliptic, obliquity),
  );
}

FixedStarState fixedStarState(
  Tsc1Catalog catalog,
  Object star,
  double jdTT, {
  FixedStarOptions options = const FixedStarOptions(),
}) {
  const h = .0005;
  final current = fixedStarPosition(catalog, star, jdTT, options: options),
      before = fixedStarPosition(
        catalog,
        current.star.index,
        jdTT - h,
        options: options,
      ),
      after = fixedStarPosition(
        catalog,
        current.star.index,
        jdTT + h,
        options: options,
      );
  return FixedStarState._(current, before, after, (jdTT + h) - (jdTT - h));
}
