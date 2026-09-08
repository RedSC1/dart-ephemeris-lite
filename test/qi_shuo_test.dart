import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  test(
    'annual events, historical assignment and all three accuracies match JS',
    () {
      final rows =
          jsonDecode(File('test/fixtures/qi_shuo.json').readAsStringSync())
              as List;
      const modes = {
        'historical': CalendarMode.historical,
        'china-astronomical': CalendarMode.chinaAstronomical,
        'local-astronomical': CalendarMode.localAstronomical,
      };
      const kinds = {
        'solar-term': QiShuoEventKind.solarTerm,
        'pentad': QiShuoEventKind.pentad,
        'lunar-phase': QiShuoEventKind.lunarPhase,
      };
      const sources = {
        'historical-profile': CalendarAssignmentSource.historicalProfile,
        'china-astronomical': CalendarAssignmentSource.chinaAstronomical,
        'local-astronomical': CalendarAssignmentSource.localAstronomical,
      };
      for (final row in rows) {
        final o = row['options'] as Map;
        final opts = CalendarOptions(
          mode: modes[o['mode']] ?? CalendarMode.historical,
          eventAccuracy: Accuracy.values.byName(o['eventAccuracy'] ?? 'mid'),
          utcOffsetMinutes: (o['utcOffsetMinutes'] as num?)?.toDouble() ?? 480,
          dayBoundaryMode: o['dayBoundaryMode'] == 'mean-solar-meridian'
              ? CalendarDayBoundaryMode.meanSolarMeridian
              : CalendarDayBoundaryMode.fixedUtcOffset,
          meridianDeg: (o['meridianDeg'] as num?)?.toDouble(),
        );
        final actual = getQiShuoYear(
          row['year'],
          options: opts,
          includePentads: o['includePentads'] ?? false,
          includeSolarTerms: o['includeSolarTerms'] ?? true,
          lunarPhaseAnglesDeg: ((o['lunarPhaseAnglesDeg'] ?? [0]) as List)
              .map((e) => (e as num).toDouble())
              .toList(),
        );
        final expected = row['result'];
        expect(actual.startJdUT1, expected['startJdUT1']);
        expect(actual.endJdUT1, expected['endJdUT1']);
        expect(
          actual.events.length,
          expected['events'].length,
          reason: '${row['year']} $o',
        );
        for (var i = 0; i < actual.events.length; i++) {
          final a = actual.events[i], e = expected['events'][i];
          final reason = '${row['year']} $o event $i ${a.name}';
          // 2 ms permits root stopping-path differences; no date-assignment tolerance.
          expect(
            (a.time.jdTT - e['time']['jdTT']).abs() * 86400,
            lessThan(0.002),
            reason: reason,
          );
          expect(a.kind, kinds[e['kind']], reason: reason);
          expect(a.name, e['name']);
          expect(a.index, e['index']);
          expect(a.termIndex, e['termIndex']);
          expect(a.pentadIndex, e['pentadIndex']);
          expect(
            a.assignedCivilDayNumber,
            e['assignedCivilDayNumber'],
            reason: reason,
          );
          expect(
            a.localCivilDayNumber,
            e['localCivilDayNumber'],
            reason: reason,
          );
          expect(
            a.assignmentSource,
            sources[e['assignmentSource']],
            reason: reason,
          );
          expect(
            a.assignmentDiffersFromLocalDate,
            e['assignmentDiffersFromLocalDate'],
          );
          expect(a.assignedDate.year, e['assignedDate']['year']);
          expect(a.assignedDate.month, e['assignedDate']['month']);
          expect(a.assignedDate.day, e['assignedDate']['day']);
        }
        expect(() => actual.events.clear(), throwsUnsupportedError);
      }
    },
  );
  test('annual options reject invalid data and permit empty tables', () {
    expect(() => getQiShuoYear(10001), throwsRangeError);
    expect(
      () => getQiShuoYear(
        2026,
        options: CalendarOptions(utcOffsetMinutes: 480.5),
      ),
      throwsRangeError,
    );
    expect(
      () => getQiShuoYear(2026, lunarPhaseAnglesDeg: [double.nan]),
      throwsArgumentError,
    );
    expect(
      getQiShuoYear(
        2026,
        includeSolarTerms: false,
        lunarPhaseAnglesDeg: [],
      ).events,
      isEmpty,
    );
  });
}
