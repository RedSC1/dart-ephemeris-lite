import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final data = jsonDecode(
    File('test/fixtures/js_apparent.json').readAsStringSync(),
  );
  test('Pluto near/fallback/blends and all three tiers agree with JS', () {
    for (final row in data['pluto']) {
      final s = planetHeliocentricState(
        Planet.pluto,
        (row['jd'] as num).toDouble(),
        accuracy: Accuracy.values.byName(row['accuracy']),
      );
      for (var k = 0; k < 3; k++) {
        expect(
          s.position[k],
          closeTo(row['position'][k], 2e-11),
          reason: '${row['jd']} position',
        );
        expect(s.velocity[k], closeTo(row['velocity'][k], 2e-11));
      }
    }
  });
  test(
    'apparent frames, corrections, distances and complete-chain rates agree with JS',
    () {
      for (final row in data['apparent']) {
        final o = row['options'];
        final frame = switch (o['frame']) {
          'j2000' => SkyFrame.j2000,
          'mean-of-date' => SkyFrame.meanOfDate,
          _ => SkyFrame.trueOfDate,
        };
        final s = apparentBodyState(
          SkyBody.values.byName(row['body']),
          (row['jdTT'] as num).toDouble(),
          options: ApparentOptions(
            frame: frame,
            accuracy: Accuracy.values.byName(o['accuracy']),
            lightTime: o['lightTime'] ?? true,
            aberration: o['aberration'] ?? true,
            solarDeflection: o['solarDeflection'] ?? true,
          ),
        );
        final fields = {
          'longitudeDeg': s.longitudeDeg,
          'latitudeDeg': s.latitudeDeg,
          'distanceAu': s.distanceAu,
          'rightAscensionDeg': s.rightAscensionDeg,
          'declinationDeg': s.declinationDeg,
          'lightTimeDays': s.lightTimeDays,
        };
        for (final entry in fields.entries) {
          expect(
            entry.value,
            closeTo(row[entry.key], 2e-8),
            reason: '${row['body']} ${row['jdTT']} ${entry.key}',
          );
        }
        final rates = {
          'longitudeSpeedDegPerDay': s.longitudeSpeedDegPerDay,
          'latitudeSpeedDegPerDay': s.latitudeSpeedDegPerDay,
          'rightAscensionSpeedDegPerDay': s.rightAscensionSpeedDegPerDay,
          'declinationSpeedDegPerDay': s.declinationSpeedDegPerDay,
          'distanceSpeedAuPerDay': s.distanceSpeedAuPerDay,
        };
        for (final entry in rates.entries) {
          expect(
            entry.value,
            closeTo(row[entry.key], 3e-7),
            reason: '${row['body']} ${row['jdTT']} ${entry.key}',
          );
        }
        for (var k = 0; k < 3; k++) {
          expect(
            s.eclipticPositionAu[k],
            closeTo(row['eclipticPositionAu'][k], 3e-11),
          );
          expect(
            s.equatorialPositionAu[k],
            closeTo(row['equatorialPositionAu'][k], 3e-11),
          );
          expect(
            s.eclipticVelocityAuPerDay[k],
            closeTo(row['eclipticVelocityAuPerDay'][k], 1e-8),
          );
        }
      }
    },
  );
}
