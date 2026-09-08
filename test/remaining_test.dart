import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'remaining_support.dart';

void main() {
  final bytes = File('test/fixtures/stars.tsc1').readAsBytesSync(),
      catalog = parseTsc1Catalog(bytes);
  test('fixed-star propagation, corrections and rates match JS', () {
    for (final r
        in jsonDecode(File('test/fixtures/fixed_stars.json').readAsStringSync())
            as List) {
      compareRemaining(
        runStar(catalog, r),
        r['result'],
        path: '${r['key']} ${r['jd']} ${r['options']}',
        star: true,
      );
    }
  });
  test('global and local solar eclipses match JS', () {
    for (final r
        in jsonDecode(
              File('test/fixtures/solar_eclipses.json').readAsStringSync(),
            )
            as List) {
      compareRemaining(
        runSolar(r),
        r['result'],
        path: '${r['kind']} ${r['args']}',
      );
    }
  });
  test('catalog preserves IDs, aliases, offsets and immutable ownership', () {
    final wrapped = Uint8List(bytes.length + 17)
      ..setRange(11, 11 + bytes.length, bytes);
    final c = parseTsc1Catalog(
      Uint8List.sublistView(wrapped, 11, 11 + bytes.length),
    );
    expect(c.starCount, 2057);
    expect(c.aliasCount, 12242);
    expect(c.find('HIP-32349')?.canonicalId, 'sirius');
    expect(c.find('参宿一')?.canonicalId, 'hr_1948');
    expect(c.find('does-not-exist'), isNull);
    expect(normalizeTsc1Alias('  HIP-91262  '), 'hip_91262');
    expect(normalizeTsc1Alias('角宿一'), '角宿一');
    expect(tsc1AliasHash('hello'), BigInt.parse('a430d84680aabd0b', radix: 16));
    wrapped.fillRange(0, wrapped.length, 0);
    expect(c.find('Sirius')?.canonicalId, 'sirius');
    expect(() => c.bytes[0] = 0, throwsUnsupportedError);
    expect(c.toList(), hasLength(c.starCount));
  });
  test('catalog rejects corrupt bounds, version and alias indexes', () {
    expect(() => parseTsc1Catalog(Uint8List(10)), throwsFormatException);
    var b = Uint8List.fromList(bytes);
    ByteData.sublistView(b).setUint32(4, 99, Endian.little);
    expect(() => parseTsc1Catalog(b), throwsFormatException);
    b = Uint8List.fromList(bytes);
    ByteData.sublistView(b).setUint32(24, 0x7fffffff, Endian.little);
    expect(() => parseTsc1Catalog(b), throwsRangeError);
    b = Uint8List.fromList(bytes);
    final v = ByteData.sublistView(b), o = v.getUint32(28, Endian.little);
    v.setUint32(o + 4, 0xffffffff, Endian.little);
    expect(() => parseTsc1Catalog(b), throwsRangeError);
    expect(() => catalog.getStar(-1), throwsRangeError);
    expect(
      () => fixedStarIcrfState(catalog, 'not-a-star', 2451545),
      throwsRangeError,
    );
    expect(
      () => fixedStarIcrfState(catalog, 0, double.nan),
      throwsArgumentError,
    );
  });
  test('solar classifications, contact order and half-open maximum', () {
    JulianTime date(int y, int m, int d) =>
        JulianTime.fromUT1(julianDay(year: y, month: m, day: d));
    final events = searchSolarEclipses(date(2023, 1, 1), date(2026, 1, 1));
    expect(
      events.map((e) => e.kind).toSet(),
      containsAll(SolarEclipseKind.values),
    );
    for (final e in events) {
      expect(e.contacts.partialBegin!.time.jdTT, lessThan(e.maximum.jdTT));
      expect(e.contacts.partialEnd!.time.jdTT, greaterThan(e.maximum.jdTT));
      expect(e.magnitude, greaterThan(0));
    }
    final t = getSolarEclipseDetails(date(2024, 4, 8))!.maximum;
    expect(searchSolarEclipses(t, JulianTime.fromTT(t.jdTT + 1)), hasLength(1));
    expect(searchSolarEclipses(JulianTime.fromTT(t.jdTT - 1), t), isEmpty);
    expect(() => events.clear(), throwsUnsupportedError);
    expect(() => searchSolarEclipses(t, t), throwsRangeError);
  });
}
