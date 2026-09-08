import 'package:ephemeris_lite/ephemeris_lite.dart';
export 'package:ephemeris_lite/ephemeris_lite.dart' show parseTsc1Catalog;

Object? runSolar(Map<String, dynamic> r) {
  final a = r['args'] as List, t = JulianTime.fromUT1((a[0] as num).toDouble());
  if (r['kind'] == 'search') {
    return searchSolarEclipses(
      t,
      JulianTime.fromUT1((a[1] as num).toDouble()),
    ).map((e) => e.toJson()).toList();
  }
  if (r['kind'] == 'details') return getSolarEclipseDetails(t)?.toJson();
  final o = r['observer'] as Map;
  return getLocalSolarEclipse(
    t,
    Observer(
      longitudeDeg: (o['longitudeDeg'] as num).toDouble(),
      latitudeDeg: (o['latitudeDeg'] as num).toDouble(),
    ),
  )?.toJson();
}

Object runStar(Tsc1Catalog c, Map<String, dynamic> r) {
  final t = (r['jd'] as num).toDouble(), key = r['key'] as String;
  if (r['kind'] == 'icrf') return fixedStarIcrfState(c, key, t).toJson();
  final o = r['options'] as Map,
      frame = switch (o['frame']) {
        'j2000' => SkyFrame.j2000,
        'mean-of-date' => SkyFrame.meanOfDate,
        _ => SkyFrame.trueOfDate,
      };
  return fixedStarState(
    c,
    key,
    t,
    options: FixedStarOptions(
      frame: frame,
      aberration: o['aberration'] as bool,
      solarDeflection: o['solarDeflection'] as bool,
    ),
  ).toJson();
}

void compareRemaining(
  dynamic actual,
  dynamic expected, {
  String path = '',
  bool star = false,
}) {
  if (expected is Map) {
    if (actual is! Map || actual.length != expected.length) {
      throw StateError('$path shape');
    }
    for (final k in expected.keys) {
      compareRemaining(actual[k], expected[k], path: '$path.$k', star: star);
    }
  } else if (expected is List) {
    if (actual is! List || actual.length != expected.length) {
      throw StateError('$path count');
    }
    for (var i = 0; i < expected.length; i++) {
      compareRemaining(actual[i], expected[i], path: '$path[$i]', star: star);
    }
  } else if (expected is num && actual is num) {
    final double tolerance;
    if (star) {
      tolerance =
          path.contains('VelocityAuPerDay') ||
              path.contains('distanceSpeedAuPerDay')
          ? 1e-3
          : path.contains('SpeedDegPerDay')
          ? 1e-7
          : 1e-9 + expected.abs() * 2e-14;
    } else {
      tolerance = path.endsWith('jdTT') || path.endsWith('jdUT1')
          ? 0.1 / 86400
          : path.endsWith('Seconds')
          ? 0.1
          : path.endsWith('Km')
          ? 0.02
          : path.endsWith('Deg')
          ? 0.002
          : 1e-6;
    }
    if (!actual.isFinite || (actual - expected).abs() > tolerance) {
      throw StateError(
        '$path $actual != $expected; diff=${actual - expected}, tol=$tolerance',
      );
    }
  } else if (actual != expected) {
    throw StateError('$path $actual != $expected');
  }
}
