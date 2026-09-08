import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  test(
    'crossing roots include start, exclude end, deduplicate and validate samples',
    () {
      expect(
        searchCrossings(
          (t) => t * (t - 1) * (t - 2),
          0,
          2,
          stepDays: 0.25,
        ).map((r) => r.time),
        [0, 1],
      );
      expect(
        searchCrossings((t) => t - 0.1234, 0, 1).single.time,
        closeTo(0.1234, 1e-8),
      );
      expect(searchCrossings((t) => 1, 1, 1), isEmpty);
      expect(() => searchCrossings((t) => 0, 0, 1), throwsRangeError);
      expect(
        () => searchCrossings((t) => double.nan, 0, 1),
        throwsArgumentError,
      );
      expect(() => searchCrossings((t) => t, 1, 0), throwsRangeError);
      expect(
        () => searchCrossings((t) => t, 0, 1, stepDays: 1e-10),
        throwsRangeError,
      );
      expect(
        () => searchCrossings((t) => t, 0, 200001, stepDays: 1),
        throwsRangeError,
      );
    },
  );
  test('angle search rejects antipodes across 360 degrees', () {
    final roots = searchAngleCrossings(
      (t) => 350 + 360 * t,
      0,
      0,
      2,
      stepDays: 0.1,
    );
    expect(roots.length, 2);
    expect(roots[0].time, closeTo(10 / 360, 1e-8));
    expect(roots[1].time, closeTo(1 + 10 / 360, 1e-8));
  });
}
