import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';
import 'package:ephemeris_lite/sun_moon.dart' as dedicated;

void main() {
  test(
    'Sun/Moon entry shares types and keeps other planets out of calendar dependencies',
    () {
      expect(
        dedicated.earthState(2451545).position,
        earthState(2451545).position,
      );
      expect(
        dedicated.moonState(2451545).velocity,
        moonState(2451545).velocity,
      );
      final seen = <Uri>{};
      void visit(Uri uri) {
        uri = uri.normalizePath();
        if (!seen.add(uri)) return;
        final source = File.fromUri(uri).readAsStringSync();
        for (final match in RegExp(
          r"(?:import|export)\s+'([^']+)'",
        ).allMatches(source)) {
          final path = match[1]!;
          if (!path.contains(':')) visit(uri.resolve(path));
        }
      }

      for (final path in [
        'lib/sun_moon.dart',
        'lib/src/qi_shuo.dart',
        'lib/src/solar_time.dart',
      ]) {
        visit(File(path).absolute.uri);
      }
      for (final uri in seen) {
        expect(
          RegExp(
            r'/(planet_models|planet_series|series|(?:mercury|venus|mars|jupiter|saturn|uranus|neptune|pluto)_series)\.dart$',
          ).hasMatch(uri.path),
          isFalse,
          reason: '$uri',
        );
      }
    },
  );
  test(
    'custom lunar latitude budgets match JS for all position tiers and mid solvers',
    () {
      for (final row
          in jsonDecode(File('test/fixtures/budgets.json').readAsStringSync())
              as List) {
        final jd = (row['jd'] as num).toDouble(),
            budget = row['budget'] as Object,
            r = row['result'];
        if (row['kind'] == 'phase') {
          final t = solveLunarPhase(
            3.141592653589793,
            jd,
            moonLatitudeTerms: budget,
            solver: EventSolver.values.byName(row['solver']),
          );
          expect(
            t.jdTT,
            closeTo((r['jdTT'] as num).toDouble(), .02 / 86400),
            reason: '$row',
          );
        } else {
          final s = moonDirectionState(
            jd,
            accuracy: Accuracy.values.byName(row['accuracy']),
            latitudeTerms: budget,
          );
          for (var i = 0; i < 3; i++) {
            expect(
              s.position[i],
              closeTo((r['position'][i] as num).toDouble(), 1e-12),
            );
            expect(
              s.velocity[i],
              closeTo((r['velocity'][i] as num).toDouble(), 1e-12),
            );
          }
        }
      }
    },
  );
  test(
    'incompatible budgets fail instead of changing fast or accurate models',
    () {
      expect(
        () => solveNewMoon(
          2451545,
          accuracy: Accuracy.fast,
          moonLatitudeTerms: 30,
        ),
        throwsRangeError,
      );
      expect(
        () => solveNewMoon(
          2451545,
          accuracy: Accuracy.accurate,
          moonLatitudeTerms: 10,
        ),
        throwsRangeError,
      );
      expect(
        () => solveNewMoon(2451545, moonLatitudeTerms: 278),
        throwsRangeError,
      );
      expect(
        () => moonDirectionState(2451545, latitudeTerms: -1),
        throwsRangeError,
      );
      expect(checkedAccuracy('mid'), Accuracy.mid);
      expect(checkedAccuracy(null), Accuracy.accurate);
      expect(() => checkedAccuracy('typo'), throwsRangeError);
      expect(asUt1JulianDay(JulianTime.fromUT1(2451545)), 2451545);
    },
  );
  test('explicit geometric aliases retain units and all accuracy settings', () {
    for (final accuracy in Accuracy.values) {
      final s = earthHeliocentricState(2451545, accuracy: accuracy);
      expect(s.position, earthPosition(2451545, accuracy: accuracy));
      expect(
        moonGeocentricPosition(2451545, accuracy: accuracy),
        moonState(2451545, accuracy: accuracy).position,
      );
      expect(
        embHeliocentricPosition(2451545, accuracy: accuracy),
        embState(2451545, accuracy: accuracy).position,
      );
      expect(
        plutoHeliocentricPosition(2451545, accuracy: accuracy),
        planetHeliocentricPosition(Planet.pluto, 2451545, accuracy: accuracy),
      );
    }
  });
}
