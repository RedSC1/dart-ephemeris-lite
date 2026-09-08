import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  test('era candidates, exact transitions and source precision match JS', () {
    final rows =
        jsonDecode(File('test/fixtures/eras.json').readAsStringSync()) as List;
    for (final row in rows) {
      final jd = (row['jd'] as num).toDouble();
      if (row['error'] != null) {
        expect(() => getChineseEraNames(jd), throwsRangeError);
        continue;
      }
      final actual = getChineseEraNames(jd), expected = row['result'] as List;
      expect(actual.length, expected.length, reason: 'JD $jd');
      for (var i = 0; i < actual.length; i++) {
        final a = actual[i].toJson(),
            e = Map<String, dynamic>.from(expected[i]);
        if (e['endJdExclusive'] == 'Infinity') {
          e['endJdExclusive'] = double.infinity;
        }
        expect(a, e, reason: 'JD $jd era $i');
      }
      expect(actual.map((r) => r.text).toSet().length, actual.length);
      expect(() => actual.clear(), throwsUnsupportedError);
    }
  });
  test('modern era boundaries and finite instant validation', () {
    expect(
      getChineseEraNames(modernChinaEstablishmentJd).any((r) => r.era == '民国'),
      isFalse,
    );
    expect(
      getChineseEraNames(
        modernChinaEstablishmentJd - 1 / 86400,
      ).any((r) => r.era == '民国'),
      isTrue,
    );
    expect(() => getChineseEraNames(double.infinity), throwsArgumentError);
  });
}
