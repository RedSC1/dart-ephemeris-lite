import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

ApparentOptions opts(Map o) => ApparentOptions(
  frame: switch (o['frame']) {
    'j2000' => SkyFrame.j2000,
    'mean-of-date' => SkyFrame.meanOfDate,
    _ => SkyFrame.trueOfDate,
  },
  accuracy: Accuracy.values.byName(o['accuracy'] ?? 'accurate'),
  lightTime: o['lightTime'] ?? true,
  aberration: o['aberration'] ?? true,
  solarDeflection: o['solarDeflection'] ?? true,
);
void main() {
  final f =
      jsonDecode(File('test/fixtures/phenomena_events.json').readAsStringSync())
          as Map;
  test('physical geometry, illuminated fraction and disc sizes match JS', () {
    for (final row in f['phenomena']) {
      final a = bodyPhenomena(
        SkyBody.values.byName(row['body']),
        (row['jd'] as num).toDouble(),
        options: opts(row['options']),
      ).toJson();
      for (final key in (row['result'] as Map).keys) {
        final e = row['result'][key];
        if (e is num) {
          expect(
            a[key],
            closeTo(e, key == 'illuminatedFraction' ? 1e-12 : 1e-7),
            reason: '${row['body']} $key',
          );
        } else {
          expect(a[key], e);
        }
      }
    }
  });
  test('moon phase cycle and waxing convention follow date axes', () {
    for (final row in f['moons']) {
      final a = moonIllumination(
        (row['jd'] as num).toDouble(),
        options: opts(row['options']),
      );
      expect(a.phaseCycle, closeTo(row['result']['phaseCycle'], 1e-12));
      expect(a.waxing, row['result']['waxing']);
      expect(
        a.illuminatedFraction,
        closeTo(row['result']['illuminatedFraction'], 1e-12),
      );
    }
  });
  test('shared geometry is immutable and matches apparent position', () {
    final g = apparentGeometry(SkyBody.venus, 2451545),
        p = apparentBodyPosition(SkyBody.venus, 2451545);
    expect(g.ecliptic, p.eclipticPositionAu);
    expect(g.equatorial, p.equatorialPositionAu);
    expect(() => g.target[0] = 0, throwsUnsupportedError);
    expect(() => bodyPhenomena(SkyBody.sun, double.nan), throwsArgumentError);
    final sun = bodyPhenomena(SkyBody.sun, 2451545);
    expect(sun.phaseAngleDeg, isNull);
    expect(sun.illuminatedFraction, isNull);
  });
}
