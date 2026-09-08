import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'lunar_eclipse_support.dart';

void main() {
  JulianTime date(int y, int m, int d) =>
      JulianTime.fromUT1(julianDay(year: y, month: m, day: d));
  test(
    'global and local lunar eclipses match JS including old and remote epochs',
    () {
      final rows =
          jsonDecode(
                File('test/fixtures/lunar_eclipses.json').readAsStringSync(),
              )
              as List;
      for (final row in rows) {
        compareEclipse(
          runEclipse(row as Map<String, dynamic>),
          row['result'],
          '${row['kind']} ${row['args']} ${row['observer']}',
        );
      }
    },
  );
  test('contact ordering and optional phases follow eclipse kind', () {
    final events = searchLunarEclipses(date(2024, 1, 1), date(2027, 1, 1));
    expect(
      events.map((e) => e.kind).toSet(),
      containsAll(LunarEclipseKind.values),
    );
    for (final e in events) {
      final c = e.contacts;
      final ordered = [
        c[LunarEclipseContact.penumbralBegin],
        c[LunarEclipseContact.partialBegin],
        c[LunarEclipseContact.totalBegin],
        e.maximum,
        c[LunarEclipseContact.totalEnd],
        c[LunarEclipseContact.partialEnd],
        c[LunarEclipseContact.penumbralEnd],
      ].whereType<JulianTime>().toList();
      for (var i = 1; i < ordered.length; i++) {
        expect(ordered[i].jdTT, greaterThan(ordered[i - 1].jdTT));
      }
      expect(
        c[LunarEclipseContact.totalBegin] != null,
        e.kind == LunarEclipseKind.total,
      );
      expect(
        c[LunarEclipseContact.partialBegin] != null,
        e.kind != LunarEclipseKind.penumbral,
      );
      expect(() => c.clear(), throwsUnsupportedError);
    }
    expect(() => events.clear(), throwsUnsupportedError);
  });
  test('search is half open at the computed maximum', () {
    final e = getLunarEclipseDetails(date(2025, 3, 14))!;
    expect(
      searchLunarEclipses(e.maximum, JulianTime.fromTT(e.maximum.jdTT + 1)),
      hasLength(1),
    );
    expect(
      searchLunarEclipses(JulianTime.fromTT(e.maximum.jdTT - 1), e.maximum),
      isEmpty,
    );
    expect(getLunarEclipseDetails(date(2026, 1, 1)), isNull);
  });
  test('invalid ranges and observers fail', () {
    expect(
      () => searchLunarEclipses(date(2026, 1, 1), date(2026, 1, 1)),
      throwsRangeError,
    );
    expect(
      () => searchLunarEclipses(date(1000, 1, 1), date(2000, 1, 1)),
      throwsRangeError,
    );
    expect(
      () => getLocalLunarEclipse(
        date(2025, 3, 14),
        const Observer(longitudeDeg: 181, latitudeDeg: 0),
      ),
      throwsRangeError,
    );
  });
  test(
    'local contacts and horizon lists are immutable; standard atmosphere preserved',
    () {
      final t = date(2025, 9, 7);
      final a = getLocalLunarEclipse(
        t,
        const Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042),
      )!;
      final b = getLocalLunarEclipse(
        t,
        const Observer(
          longitudeDeg: 116.4074,
          latitudeDeg: 39.9042,
          pressureMbar: 0,
        ),
      )!;
      expect(a.toJson(), b.toJson());
      expect(() => a.contacts.clear(), throwsUnsupportedError);
      expect(() => a.moonrises.clear(), throwsUnsupportedError);
    },
  );
}
