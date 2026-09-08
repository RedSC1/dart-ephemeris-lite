import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  final f = jsonDecode(
    File('test/fixtures/upstream/coordinates-stars.json').readAsStringSync(),
  );
  test('IAU 2000B independent C++ SOFA oracles', () {
    for (final r in f['nutation']) {
      final n = iau2000bNutation((r[0] as num).toDouble());
      expect(n.dpsi, closeTo(r[1], 1e-16));
      expect(n.deps, closeTo(r[2], 1e-16));
      expect(n.meanObliquity, closeTo(r[3], 1e-16));
    }
  });
  test('Vondrak 2011 independent C++ SOFA precession oracles', () {
    for (final r in f['precession']) {
      final p = vondrak2011PrecessionMatrix((r[0] as num).toDouble());
      for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
          expect(p[i][j], closeTo(r[1][i][j], 2e-14));
        }
      }
    }
  });
  test('all catalog source types match independent C++ space motion', () {
    final c = parseTsc1Catalog(
      File('test/fixtures/stars.tsc1').readAsBytesSync(),
    );
    for (final r in f['stars']) {
      final p = fixedStarIcrfState(c, r[0], (r[1] as num).toDouble());
      for (var i = 0; i < 3; i++) {
        expect((p.positionAu[i] - r[2][i]).abs(), lessThan(1e-9));
        expect((p.velocityAuPerDay[i] - r[3][i]).abs(), lessThan(1e-17));
      }
    }
  });
}
