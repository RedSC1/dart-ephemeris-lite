import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final f = jsonDecode(
    File('test/fixtures/upstream/events-2026.json').readAsStringSync(),
  );
  for (final accuracy in Accuracy.values) {
    test('2026 $accuracy solar terms vs DE441 and independent PMO minutes', () {
      final errors = <double>[];
      for (var i = 0; i < f['solar'].length; i++) {
        final r = f['solar'][i];
        final t = solveSolarLongitude(
          (r[0] as num) * math.pi / 180,
          (r[1] as num).toDouble(),
          accuracy: accuracy,
        );
        final error = (t.jdTT - r[1]).abs() * 86400;
        errors.add(error);
        expect(error, lessThan(accuracy == Accuracy.fast ? 2 : .5));
        final z = t.toZonedTime(480);
        final rounded = DateTime.utc(
          z.year,
          z.month,
          z.day,
          z.hour,
          z.minute + (z.second >= 30 ? 1 : 0),
        );
        expect(
          rounded.toIso8601String().substring(0, 16).replaceAll('T', ' '),
          '2026-${f['published'][i]}',
        );
        if (accuracy == Accuracy.mid && i == 11) {
          expect([z.month, z.day, z.hour, z.minute], [6, 21, 16, 24]);
          expect(z.second, allOf(greaterThanOrEqualTo(30), lessThan(31)));
        }
      }
      if (accuracy == Accuracy.mid) {
        expect(errors.reduce((a, b) => a + b) / errors.length, lessThan(.2));
      }
    });
    test('2026 $accuracy new moons vs DE441', () {
      final errors = <double>[];
      for (final r in f['newMoons']) {
        final error =
            (solveNewMoon((r as num).toDouble(), accuracy: accuracy).jdTT - r)
                .abs() *
            86400;
        expect(error, lessThan(accuracy == Accuracy.fast ? 1 : .7));
        errors.add(error);
      }
      if (accuracy != Accuracy.fast) {
        expect(errors.reduce((a, b) => a + b) / errors.length, lessThan(.2));
      }
    });
  }
}
