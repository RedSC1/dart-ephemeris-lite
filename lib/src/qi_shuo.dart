// Port of js-ephemeris-lite/src/qi-shuo.js. MPL-2.0.
import 'dart:math' as math;
import 'calendar_events.dart';
import 'event_mid.dart';
import 'historical_calendar.dart';
import 'time.dart';

const solarTermNames = [
  '春分',
  '清明',
  '谷雨',
  '立夏',
  '小满',
  '芒种',
  '夏至',
  '小暑',
  '大暑',
  '立秋',
  '处暑',
  '白露',
  '秋分',
  '寒露',
  '霜降',
  '立冬',
  '小雪',
  '大雪',
  '冬至',
  '小寒',
  '大寒',
  '立春',
  '雨水',
  '惊蛰',
];
const lunarPhaseNames = <int, String>{0: '朔', 90: '上弦', 180: '望', 270: '下弦'};

enum QiShuoEventKind { solarTerm, pentad, lunarPhase }

enum CalendarAssignmentSource {
  historicalProfile,
  chinaAstronomical,
  localAstronomical,
}

/// Actual event time and its calendar assignment are deliberately separate.
class QiShuoEvent {
  final QiShuoEventKind kind;
  final String name;
  final int index;
  final int? termIndex, pentadIndex;

  /// Solar longitude or lunar elongation, in radians.
  final double targetAngle;
  final JulianTime time;
  final ZonedTime localTime;
  final int localCivilDayNumber, assignedCivilDayNumber;
  final CalendarAssignmentSource assignmentSource;
  QiShuoEvent._({
    required this.kind,
    required this.name,
    required this.index,
    this.termIndex,
    this.pentadIndex,
    required this.targetAngle,
    required this.time,
    required this.localTime,
    required this.localCivilDayNumber,
    required this.assignedCivilDayNumber,
    required this.assignmentSource,
  });
  double get targetAngleDeg => targetAngle * 180 / math.pi;
  CalendarDate get localDate =>
      calendarDateFromJulianDay(localCivilDayNumber - 0.5);
  CalendarDate get assignedDate =>
      calendarDateFromJulianDay(assignedCivilDayNumber - 0.5);
  bool get assignmentDiffersFromLocalDate =>
      localCivilDayNumber != assignedCivilDayNumber;
}

class QiShuoYear {
  final int civilYear;
  final CalendarOptions options;
  final double startJdUT1, endJdUT1;
  final List<QiShuoEvent> events;
  QiShuoYear._(
    this.civilYear,
    this.options,
    this.startJdUT1,
    this.endJdUT1,
    List<QiShuoEvent> events,
  ) : events = List.unmodifiable(events);
}

/// Events inside a fixed-offset civil year (astronomical year numbering).
/// Historical assignment applies only to solar terms and new moons, not to
/// intermediate pentads or other lunar phases. This does not build lunar months.
QiShuoYear getQiShuoYear(
  int civilYear, {
  CalendarOptions? options,
  bool includeSolarTerms = true,
  bool includePentads = false,
  List<double> lunarPhaseAnglesDeg = const [0],
}) {
  if (civilYear < -6000 || civilYear > 10000) {
    throw RangeError('civilYear must be within -6000..10000');
  }
  final opts = options ?? CalendarOptions();
  if (opts.utcOffsetMinutes != opts.utcOffsetMinutes.truncateToDouble()) {
    throw RangeError('Annual event tables require integer utcOffsetMinutes');
  }
  final phases = <double>[];
  for (final angle in lunarPhaseAnglesDeg) {
    if (!angle.isFinite) {
      throw ArgumentError('Lunar phase angles must be finite');
    }
    final normalized = angle % 360;
    if (!phases.any((p) => (p - normalized).abs() < 1e-10)) {
      phases.add(normalized);
    }
  }
  phases.sort();
  double boundary(int y) => ZonedTime(
    year: y,
    month: 1,
    day: 1,
    offsetMinutes: opts.utcOffsetMinutes.toInt(),
  ).toJulianTime().jdUT1;
  final start = boundary(civilYear),
      end = boundary(civilYear + 1),
      startTT = ut1ToTt(start);
  final events = <QiShuoEvent>[];
  void add(
    QiShuoEventKind kind,
    String name,
    int index,
    double target,
    JulianTime time, {
    int? termIndex,
    int? pentadIndex,
    HistoricalEventKind? historicalKind,
  }) {
    var assigned = civilDayNumber(time.jdUT1, opts.structureOffset);
    var source = opts.mode == CalendarMode.localAstronomical
        ? CalendarAssignmentSource.localAstronomical
        : CalendarAssignmentSource.chinaAstronomical;
    if (opts.mode == CalendarMode.historical && historicalKind != null) {
      final historical = historicalEventCivilDay(historicalKind, time.jdUT1);
      if (historical != null) {
        assigned = historical;
        source = CalendarAssignmentSource.historicalProfile;
      }
    }
    events.add(
      QiShuoEvent._(
        kind: kind,
        name: name,
        index: index,
        termIndex: termIndex,
        pentadIndex: pentadIndex,
        targetAngle: target,
        time: time,
        localTime: time.toZonedTime(opts.utcOffsetMinutes.toInt()),
        localCivilDayNumber: civilDayNumber(
          time.jdUT1,
          opts.utcOffsetMinutes / 1440,
        ),
        assignedCivilDayNumber: assigned,
        assignmentSource: source,
      ),
    );
  }

  const twoPi = 2 * math.pi,
      yearDays = 365.2422,
      monthDays = 29.53058886,
      epsilon = 1e-8;
  void solar(int count) {
    final startAngle = solarLongitudeState(startTT).value;
    for (var step = 0; step < count; step++) {
      final target = step / count * twoPi;
      JulianTime solve(double near) =>
          solveSolarLongitude(target, near, accuracy: opts.eventAccuracy);
      var solved = solve(
        startTT + (target - startAngle) % twoPi / twoPi * yearDays,
      );
      if (solved.jdUT1 < start - epsilon) {
        solved = solve(solved.jdTT + yearDays);
      }
      final term = count == 24 ? step : step ~/ 3,
          pentad = count == 72 ? step % 3 : null;
      final kind = count == 24
          ? QiShuoEventKind.solarTerm
          : QiShuoEventKind.pentad;
      final name = count == 24
          ? solarTermNames[term]
          : '${solarTermNames[term]}·${const ['初候', '二候', '三候'][pentad!]}';
      while (solved.jdUT1 < end - epsilon) {
        if (count == 24 || !includeSolarTerms || pentad != 0) {
          add(
            kind,
            name,
            step,
            target,
            solved,
            termIndex: term,
            pentadIndex: pentad,
            historicalKind: count == 24 || pentad == 0
                ? HistoricalEventKind.solarTerm
                : null,
          );
        }
        solved = solve(solved.jdTT + yearDays);
      }
    }
  }

  if (includeSolarTerms) {
    solar(24);
  }
  if (includePentads) {
    solar(72);
  }
  if (phases.isNotEmpty) {
    final startAngle = elongationState(startTT).value;
    for (final degree in phases) {
      final target = degree / 360 * twoPi;
      JulianTime solve(double near) =>
          solveLunarPhase(target, near, accuracy: opts.eventAccuracy);
      var solved = solve(
        startTT + (target - startAngle) % twoPi / twoPi * monthDays,
      );
      if (solved.jdUT1 < start - epsilon) {
        solved = solve(solved.jdTT + monthDays);
      }
      final named = lunarPhaseNames.entries.where(
        (entry) => (entry.key - degree).abs() < 1e-10,
      );
      final rounded = double.parse(degree.toStringAsFixed(6));
      final label = rounded == rounded.truncateToDouble()
          ? rounded.toInt().toString()
          : rounded.toString();
      final name = named.isNotEmpty ? named.first.value : '$label°月相';
      var serial = 0;
      while (solved.jdUT1 < end - epsilon) {
        add(
          QiShuoEventKind.lunarPhase,
          name,
          serial++,
          target,
          solved,
          historicalKind: degree.abs() < 1e-10
              ? HistoricalEventKind.newMoon
              : null,
        );
        solved = solve(solved.jdTT + monthDays);
      }
    }
  }
  // Match JS's kind-name ordering for coincident events.
  const order = {
    QiShuoEventKind.lunarPhase: 0,
    QiShuoEventKind.pentad: 1,
    QiShuoEventKind.solarTerm: 2,
  };
  events.sort((a, b) {
    final time = a.time.jdUT1.compareTo(b.time.jdUT1);
    if (time != 0) {
      return time;
    }
    final kind = order[a.kind]!.compareTo(order[b.kind]!);
    return kind != 0 ? kind : a.index.compareTo(b.index);
  });
  return QiShuoYear._(civilYear, opts, start, end, events);
}
