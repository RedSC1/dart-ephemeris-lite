import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final data = jsonDecode(
    File('test/fixtures/js_calendar_events.json').readAsStringSync(),
  );
  test('dedicated calendar values and analytic rates match JS', () {
    for (final row in data['states']) {
      final jd = (row['jd'] as num).toDouble();
      final values = {
        'solar': solarLongitudeState(jd),
        'moon': moonLongitudeState(jd),
        'elongation': elongationState(jd),
        'lowSolar': lowSolarLongitudeState(jd),
        'lowPhase': lowElongationState(jd),
      };
      for (final entry in values.entries) {
        expect(
          entry.value.value,
          closeTo(row[entry.key]['value'], 1e-10),
          reason: '$jd ${entry.key}',
        );
        expect(entry.value.rate, closeTo(row[entry.key]['rate'], 1e-12));
      }
    }
  });
  test(
    '224 nearest-event queries match JS for every tier and both solvers',
    () {
      for (final row in data['rows']) {
        final options = row['options'],
            near = (row['near'] as num).toDouble(),
            target = (row['target'] as num).toDouble();
        final accuracy = Accuracy.values.byName(options['accuracy']),
            solver = options['solver'] == 'safeguarded'
                ? EventSolver.safeguarded
                : EventSolver.auto;
        final result = row['lunar']
            ? solveLunarPhase(target, near, accuracy: accuracy, solver: solver)
            : solveSolarLongitude(
                target,
                near,
                accuracy: accuracy,
                solver: solver,
              );
        expect(
          result.jdTT,
          closeTo(row['result']['jdTT'], 2e-8),
          reason: '$near ${row['lunar']} $accuracy $solver',
        );
        expect(result.jdUT1, closeTo(row['result']['jdUT1'], 2e-8));
      }
    },
  );
  test('defaults use mid and fast rejects unsupported solver controls', () {
    expect(
      solveNewMoon(j2000).jdTT,
      solveLunarPhase(0, j2000, accuracy: Accuracy.mid).jdTT,
    );
    expect(
      () => solveNewMoon(j2000, accuracy: Accuracy.fast, toleranceSeconds: 1),
      throwsArgumentError,
    );
    expect(
      () => solveSolarLongitude(
        0,
        j2000,
        accuracy: Accuracy.fast,
        solver: EventSolver.safeguarded,
      ),
      throwsArgumentError,
    );
    expect(() => solveNewMoon(j2000, toleranceSeconds: 0), throwsArgumentError);
    expect(() => solveNewMoon(double.nan), throwsArgumentError);
  });
}
