import 'package:ephemeris_lite/ephemeris_lite.dart';

List<OrbitalEvent> runOrbital(Map<String, dynamic> row) {
  final a = row['args'] as List;
  final o = row['options'] as Map;
  final ap = o['apparent'] as Map? ?? {};
  SkyFrame frame(dynamic f) => switch (f) {
    'j2000' => SkyFrame.j2000,
    'mean-of-date' => SkyFrame.meanOfDate,
    _ => SkyFrame.trueOfDate,
  };
  final options = ApparentOptions(
    frame: frame(ap['frame']),
    accuracy: Accuracy.values.byName(ap['accuracy'] as String? ?? 'accurate'),
  );
  double n(int i) => (a[i] as num).toDouble();
  SkyBody body(int i) => SkyBody.values.byName(a[i] as String);
  final step = (o['stepDays'] as num?)?.toDouble();
  final tol = (o['toleranceDays'] as num?)?.toDouble() ?? 1e-8;
  return switch (row['kind']) {
    'searchLunarApsides' => searchLunarApsides(
      n(0),
      n(1),
      stepDays: step ?? 1,
      toleranceDays: tol,
    ),
    'searchEarthApsides' => searchEarthApsides(
      n(0),
      n(1),
      stepDays: step ?? 2,
      toleranceDays: tol,
    ),
    'searchLunarNodes' => searchLunarNodes(
      n(0),
      n(1),
      frame: frame(o['frame'] ?? 'mean-of-date'),
      stepDays: step ?? 1,
      toleranceDays: tol,
    ),
    'searchGreatestElongations' => searchGreatestElongations(
      body(0),
      n(1),
      n(2),
      apparent: options,
      stepDays: step ?? 1,
      toleranceDays: tol,
    ),
    'searchRelativeRightAscension' => searchRelativeRightAscension(
      body(0),
      body(1),
      n(2),
      n(3),
      n(4),
      apparent: options,
      stepDays: step ?? .5,
      toleranceDays: tol,
    ),
    'searchRightAscensionStations' => searchRightAscensionStations(
      body(0),
      n(1),
      n(2),
      apparent: options,
      stepDays: step ?? .5,
      toleranceDays: tol,
    ),
    _ => throw StateError('Unknown orbital query'),
  };
}

// Event-root tolerances include finite-difference speed noise across runtimes.
void compareOrbital(dynamic actual, dynamic expected, [String path = '']) {
  if (expected is Map) {
    if (actual is! Map || actual.length != expected.length) {
      throw StateError('$path shape');
    }
    for (final key in expected.keys) {
      compareOrbital(actual[key], expected[key], '$path.$key');
    }
  } else if (expected is num && actual is num) {
    final tolerance = path.endsWith('jdTT') || path.endsWith('jdUT1')
        ? .1 / 86400
        : path.endsWith('distanceKm')
        ? .001
        : path.endsWith('distanceAu')
        ? 1e-10
        : path.endsWith('deltaTSeconds')
        ? 1e-5
        : path.endsWith('SpeedDegPerDay')
        ? 1e-6
        : 1e-5;
    if (!actual.isFinite || (actual - expected).abs() > tolerance) {
      throw StateError('$path: $actual != $expected (tolerance $tolerance)');
    }
  } else if (actual != expected) {
    throw StateError('$path: $actual != $expected');
  }
}
