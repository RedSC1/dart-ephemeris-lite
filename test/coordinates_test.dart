import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void checkMatrix(Matrix3 actual, List<dynamic> expected, double tolerance) {
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      expect(actual[i][j], closeTo(expected[i][j], tolerance));
    }
  }
}

void main() {
  final rows =
      jsonDecode(File('test/fixtures/js_coordinates.json').readAsStringSync())
          as List;
  test('65 epochs of IAU2000B, Vondrak2011 and date frames match JS', () {
    for (final row in rows) {
      final jd = (row['jd'] as num).toDouble();
      for (final count in [null, 10]) {
        final n = iau2000bNutationState(jd, termCount: count).toJson();
        final expected = row[count == null ? 'nutation' : 'nutation10'];
        for (final key in n.keys) {
          expect(n[key], closeTo(expected[key], 1e-13), reason: '$jd $key');
        }
        expect(
          iau2000bNutationLongitude(jd, termCount: count),
          closeTo(n['dpsi']!, 1e-15),
        );
      }
      final p = vondrak2011PrecessionMatrixState(jd),
          f = meanEclipticOfDateMatrixState(jd);
      checkMatrix(p.matrix, row['precession']['matrix'], 2e-14);
      checkMatrix(p.rate, row['precession']['rate'], 1e-17);
      checkMatrix(f.matrix, row['frame']['matrix'], 2e-14);
      checkMatrix(f.rate, row['frame']['rate'], 1e-17);
      checkMatrix(meanEclipticOfDateMatrix(jd), row['valueFrame'], 2e-14);
      final v = icrfEquatorialToJ2000Ecliptic([0.2, -0.5, 0.8]);
      for (var i = 0; i < 3; i++) {
        expect(v[i], closeTo(row['icrf'][i], 2e-14));
      }
    }
  });
  test(
    'matrix rates match central differences and rows remain orthonormal',
    () {
      for (final jd in [j2000 - 2000000, j2000, j2000 + 2000000]) {
        for (final evaluate in [
          vondrak2011PrecessionMatrixState,
          meanEclipticOfDateMatrixState,
        ]) {
          final state = evaluate(jd),
              before = evaluate(jd - 0.1),
              after = evaluate(jd + 0.1);
          for (var i = 0; i < 3; i++) {
            for (var j = 0; j < 3; j++) {
              expect(
                (after.matrix[i][j] - before.matrix[i][j]) / 0.2,
                closeTo(state.rate[i][j], 2e-14),
              );
              var dot = 0.0;
              for (var k = 0; k < 3; k++) {
                dot += state.matrix[i][k] * state.matrix[j][k];
              }
              expect(dot, closeTo(i == j ? 1 : 0, 2e-14));
            }
          }
        }
      }
    },
  );
  test('invalid coordinates fail and result matrices cannot be mutated', () {
    expect(() => meanEclipticOfDateMatrix(double.nan), throwsArgumentError);
    expect(() => iau2000bNutation(double.infinity), throwsArgumentError);
    expect(() => icrfEquatorialToJ2000Ecliptic([1, 2]), throwsArgumentError);
    expect(
      () => meanEclipticOfDateMatrix(j2000)[0][0] = 0,
      throwsUnsupportedError,
    );
  });
}
