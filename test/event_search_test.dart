import 'dart:convert';
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';
import 'package:test/test.dart';

void main() {
  test(
    'longitude, relative longitude, stations and retrograde ingress match JS',
    () {
      final f =
          jsonDecode(
                File('test/fixtures/phenomena_events.json').readAsStringSync(),
              )
              as Map;
      var retrogradeIngresses = 0;
      for (final row in f['events']) {
        final body = SkyBody.values.byName(row['body']),
            start = (row['start'] as num).toDouble(),
            end = (row['end'] as num).toDouble();
        final o = row['options']['apparent'] ?? {};
        final options = ApparentOptions(
          accuracy: Accuracy.values.byName(o['accuracy'] ?? 'accurate'),
          frame: o['frame'] == 'j2000' ? SkyFrame.j2000 : SkyFrame.trueOfDate,
        );
        final extra = row['extra'];
        final List<SkyEvent> actual = switch (row['kind']) {
          'longitude' => searchLongitudeCrossings(
            body,
            (extra['target'] as num).toDouble(),
            start,
            end,
            apparent: options,
          ),
          'relative' => searchRelativeLongitude(
            body,
            SkyBody.values.byName(extra['other']),
            (extra['target'] as num).toDouble(),
            start,
            end,
            apparent: options,
          ),
          'stations' => searchStations(body, start, end, apparent: options),
          _ => searchIngresses(body, start, end, apparent: options),
        };
        final expected = row['result'] as List;
        expect(
          actual.length,
          expected.length,
          reason: '${row['body']} ${row['kind']}',
        );
        for (var i = 0; i < actual.length; i++) {
          final a = actual[i], e = expected[i];
          expect(
            (a.time.jdTT - e['time']['jdTT']).abs() * 86400,
            lessThan(0.1),
            reason: '${row['body']} ${row['kind']} event $i',
          );
          expect(a.time.jdTT, greaterThanOrEqualTo(start));
          expect(a.time.jdTT, lessThan(end));
          expect(a.direction.name, e['direction']);
          expect(a.longitudeDeg, closeTo(e['longitudeDeg'], 1e-5));
          expect(
            a.longitudeSpeedDegPerDay,
            closeTo(e['longitudeSpeedDegPerDay'], 1e-6),
          );
          if (a is LongitudeCrossing) {
            expect(a.targetDeg, e['targetDeg']);
          }
          if (a is RelativeLongitudeEvent) {
            expect(a.other.name, e['other']);
            expect(a.angleDeg, e['angleDeg']);
          }
          if (a is IngressEvent) {
            expect(a.fromSign, e['fromSign']);
            expect(a.toSign, e['toSign']);
            expect(a.boundaryDeg, e['boundaryDeg']);
            if (a.direction == MotionDirection.retrograde) {
              retrogradeIngresses++;
            }
          }
          if (row['kind'] == 'stations') {
            final after = apparentBodyState(
              body,
              a.time.jdTT + 0.01,
              options: options,
            ).longitudeSpeedDegPerDay;
            expect(
              a.direction,
              after < 0 ? MotionDirection.retrograde : MotionDirection.direct,
            );
            expect(a.longitudeSpeedDegPerDay.abs(), lessThan(1e-6));
          }
        }
        expect(() => actual.clear(), throwsUnsupportedError);
      }
      expect(retrogradeIngresses, greaterThan(0));
      expect(
        () => searchRelativeLongitude(
          SkyBody.sun,
          SkyBody.sun,
          0,
          2451545,
          2451550,
        ),
        throwsRangeError,
      );
    },
  );

  test(
    'crossing roots include start, exclude end, deduplicate and validate samples',
    () {
      expect(
        searchCrossings(
          (t) => t * (t - 1) * (t - 2),
          0,
          2,
          stepDays: 0.25,
        ).map((r) => r.time),
        [0, 1],
      );
      expect(
        searchCrossings((t) => t - 0.1234, 0, 1).single.time,
        closeTo(0.1234, 1e-8),
      );
      expect(searchCrossings((t) => 1, 1, 1), isEmpty);
      expect(() => searchCrossings((t) => 0, 0, 1), throwsRangeError);
      expect(
        () => searchCrossings((t) => double.nan, 0, 1),
        throwsArgumentError,
      );
      expect(() => searchCrossings((t) => t, 1, 0), throwsRangeError);
      expect(
        () => searchCrossings((t) => t, 0, 1, stepDays: 1e-10),
        throwsRangeError,
      );
      expect(
        () => searchCrossings((t) => t, 0, 200001, stepDays: 1),
        throwsRangeError,
      );
    },
  );
  test('angle search rejects antipodes across 360 degrees', () {
    final roots = searchAngleCrossings(
      (t) => 350 + 360 * t,
      0,
      0,
      2,
      stepDays: 0.1,
    );
    expect(roots.length, 2);
    expect(roots[0].time, closeTo(10 / 360, 1e-8));
    expect(roots[1].time, closeTo(1 + 10 / 360, 1e-8));
  });
}
