import 'package:ephemeris_lite/ephemeris_lite.dart';

Object? runEclipse(Map<String, dynamic> row) {
  final args = row['args'] as List;
  final start = JulianTime.fromUT1((args[0] as num).toDouble());
  if (row['kind'] == 'search') {
    return searchLunarEclipses(
      start,
      JulianTime.fromUT1((args[1] as num).toDouble()),
    ).map((e) => e.toJson()).toList();
  }
  if (row['kind'] == 'details') {
    return getLunarEclipseDetails(start)?.toJson();
  }
  final o = row['observer'] as Map;
  return getLocalLunarEclipse(
    start,
    Observer(
      longitudeDeg: (o['longitudeDeg'] as num).toDouble(),
      latitudeDeg: (o['latitudeDeg'] as num).toDouble(),
    ),
  )?.toJson();
}

void compareEclipse(dynamic actual, dynamic expected, [String path = '']) {
  if (expected is Map) {
    if (actual is! Map || actual.length != expected.length) {
      throw StateError('$path map shape');
    }
    for (final k in expected.keys) {
      compareEclipse(actual[k], expected[k], '$path.$k');
    }
  } else if (expected is List) {
    if (actual is! List || actual.length != expected.length) {
      throw StateError('$path count');
    }
    for (var i = 0; i < expected.length; i++) {
      compareEclipse(actual[i], expected[i], '$path[$i]');
    }
  } else if (expected is num && actual is num) {
    final tol = path.endsWith('jdTT') || path.endsWith('jdUT1')
        ? 0.05 / 86400
        : path.endsWith('Deg')
        ? 1e-4
        : 1e-7;
    if (!actual.isFinite || (actual - expected).abs() > tol) {
      throw StateError('$path $actual != $expected tolerance=$tol');
    }
  } else if (actual != expected) {
    throw StateError('$path $actual != $expected');
  }
}
