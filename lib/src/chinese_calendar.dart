// Port of js-ephemeris-lite/src/chinese-calendar.js. MPL-2.0.
import 'dart:math' as math;
import 'calendar_events.dart';
import 'event_mid.dart';
import 'historical_calendar.dart';
import 'time.dart';

/// Distinguishes historical names that share a numeric month.
/// Values preserve the JS MONTH_NAME codes; do not infer leap status from names.
enum MonthName { normal, thirteen, laterNine, altTwelve, altOne, laterSameName }

enum SolarTermDirection { previous, next }

enum SolarTermFilter { any, jie, qi }

class CalendarNewMoon {
  final JulianTime time;
  final int civilDayNumber;
  const CalendarNewMoon(this.time, this.civilDayNumber);
}

class CalendarSolarTerm extends CalendarNewMoon {
  final int indexFromWinterSolstice;
  final double targetLongitude;
  const CalendarSolarTerm(
    super.time,
    super.civilDayNumber,
    this.indexFromWinterSolstice,
    this.targetLongitude,
  );
}

class LunarMonth {
  final int lunarYear,
      historicalYear,
      month,
      dayCount,
      monthBuildingBranch,
      firstCivilDayNumber;
  final bool isLeap;
  final MonthName monthName;
  final JulianTime newMoon;
  const LunarMonth({
    required this.lunarYear,
    required this.historicalYear,
    required this.month,
    required this.dayCount,
    required this.monthBuildingBranch,
    required this.firstCivilDayNumber,
    required this.isLeap,
    required this.monthName,
    required this.newMoon,
  });
}

class ChineseCalendarYear {
  final List<CalendarSolarTerm> solarTerms;
  final List<CalendarNewMoon> newMoons;
  final List<LunarMonth> months;
  final int leapMonthIndex;
  final CalendarOptions options;
  ChineseCalendarYear._(
    List<CalendarSolarTerm> terms,
    List<CalendarNewMoon> moons,
    List<LunarMonth> months,
    this.leapMonthIndex,
    this.options,
  ) : solarTerms = List.unmodifiable(terms),
      newMoons = List.unmodifiable(moons),
      months = List.unmodifiable(months);
  int get firstWinterSolsticeDayNumber => solarTerms.first.civilDayNumber;
  int get secondWinterSolsticeDayNumber => solarTerms[24].civilDayNumber;
}

/// Input for lunar-to-solar conversion. [year] is the source lunar-year label;
/// historicalYear may differ during reforms and is returned separately.
class LunarDate {
  final int year, month, day;
  final bool isLeap;
  final MonthName monthName;
  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeap = false,
    this.monthName = MonthName.normal,
  });
  Map<String, Object> toJson() => {
    'year': year,
    'month': month,
    'day': day,
    'isLeap': isLeap,
    'monthName': monthName.index,
  };
}

class LunarCalendarDate extends LunarDate {
  final int historicalYear, monthDays;
  const LunarCalendarDate({
    required super.year,
    required super.month,
    required super.day,
    required super.isLeap,
    required super.monthName,
    required this.historicalYear,
    required this.monthDays,
  });
  @override
  Map<String, Object> toJson() => {
    ...super.toJson(),
    'historicalYear': historicalYear,
    'monthDays': monthDays,
  };
}

const _yearDays = 365.2422,
    _monthDays = 29.5306,
    _termDays = 15.2184,
    _twoPi = 2 * math.pi;
CalendarDate _date(int day) => calendarDateFromJulianDay(day - 0.5);
int _assigned(
  HistoricalEventKind kind,
  double estimate,
  double precise,
  CalendarOptions o,
) =>
    (o.mode == CalendarMode.historical
        ? historicalEventCivilDay(kind, estimate)
        : null) ??
    civilDayNumber(precise, o.structureOffset);
CalendarSolarTerm _term(int index, double near, CalendarOptions o) {
  final target = ((270 + 15 * index) * math.pi / 180) % _twoPi;
  final time = solveSolarLongitude(target, near, accuracy: o.eventAccuracy);
  return CalendarSolarTerm(
    time,
    _assigned(HistoricalEventKind.solarTerm, time.jdUT1, time.jdUT1, o),
    index,
    target,
  );
}

CalendarNewMoon _moon(double near, CalendarOptions o) {
  final time = solveNewMoon(near, accuracy: o.eventAccuracy);
  return CalendarNewMoon(
    time,
    _assigned(HistoricalEventKind.newMoon, time.jdUT1, time.jdUT1, o),
  );
}

CalendarSolarTerm _winter(double jd, CalendarOptions o) {
  final target = civilDayNumber(jd, o.structureOffset);
  var event = _term(0, ut1ToTt(jd), o);
  while (event.civilDayNumber > target) {
    event = _term(0, event.time.jdTT - _yearDays, o);
  }
  for (;;) {
    final next = _term(0, event.time.jdTT + _yearDays, o);
    if (next.civilDayNumber > target) {
      break;
    }
    event = next;
  }
  return event;
}

int _monthNumber(int sequence) =>
    const [11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10][sequence % 12];

class _Month {
  int lunarYear = 0, historicalYear = 0, month = 0, monthBuildingBranch = 0;
  bool isLeap = false;
  MonthName monthName = MonthName.normal;
  final int dayCount, firstCivilDayNumber;
  final JulianTime newMoon;
  _Month(this.dayCount, this.firstCivilDayNumber, this.newMoon);
  LunarMonth freeze() => LunarMonth(
    lunarYear: lunarYear,
    historicalYear: historicalYear,
    month: month,
    dayCount: dayCount,
    monthBuildingBranch: monthBuildingBranch,
    firstCivilDayNumber: firstCivilDayNumber,
    isLeap: isLeap,
    monthName: monthName,
    newMoon: newMoon,
  );
}

void _assignYears(List<_Month> months) {
  final starts = <int>[];
  for (var i = 0; i < months.length; i++) {
    final m = months[i];
    if (m.month == 1 && !m.isLeap && m.monthName != MonthName.altOne) {
      starts.add(i);
    }
  }
  if (starts.isNotEmpty) {
    var firstYear = 0;
    for (var boundary = 0; boundary < starts.length; boundary++) {
      final first = starts[boundary],
          next = boundary + 1 < starts.length
              ? starts[boundary + 1]
              : months.length;
      final start = months[first].firstCivilDayNumber;
      final end = boundary + 1 < starts.length
          ? months[next].firstCivilDayNumber
          : start + 180;
      final year = _date(((start + end) / 2).floor()).year;
      if (boundary == 0) {
        firstYear = year;
      }
      for (var i = first; i < next; i++) {
        months[i].lunarYear = year;
        months[i].historicalYear = year;
      }
    }
    for (var i = 0; i < starts[0]; i++) {
      months[i].lunarYear = firstYear - 1;
      months[i].historicalYear = firstYear - 1;
    }
  } else {
    for (final m in months) {
      final year = _date(m.firstCivilDayNumber).year;
      m.lunarYear = m.month >= 11 ? year - 1 : year;
      m.historicalYear = m.lunarYear;
    }
  }
}

/// 25 solar terms, 15 new moons and 14 months around the preceding winter
/// solstice. Uses assigned civil days for month structure, not rounded TT.
ChineseCalendarYear calculateChineseCalendarYear(
  double jdUT1, {
  CalendarOptions? options,
}) {
  if (!jdUT1.isFinite) {
    throw ArgumentError.value(jdUT1, 'jdUT1');
  }
  final o = options ?? CalendarOptions();
  final winter = _winter(jdUT1, o), terms = <CalendarSolarTerm>[];
  terms.add(winter);
  for (var i = 1; i < 25; i++) {
    terms.add(_term(i, terms.last.time.jdTT + _termDays, o));
  }
  var moon = _moon(winter.time.jdTT, o);
  while (moon.civilDayNumber > winter.civilDayNumber) {
    moon = _moon(moon.time.jdTT - _monthDays, o);
  }
  for (;;) {
    final next = _moon(moon.time.jdTT + _monthDays, o);
    if (next.civilDayNumber > winter.civilDayNumber) {
      break;
    }
    moon = next;
  }
  final moons = <CalendarNewMoon>[moon];
  while (moons.length < 15) {
    moons.add(_moon(moons.last.time.jdTT + _monthDays, o));
  }
  final sequence = List.generate(14, (i) => i);
  var leap = -1;
  if (moons[13].civilDayNumber <= terms[24].civilDayNumber) {
    leap = 1;
    while (leap < 13 &&
        moons[leap + 1].civilDayNumber > terms[2 * leap].civilDayNumber) {
      leap++;
    }
    for (var i = leap; i < sequence.length; i++) {
      sequence[i]--;
    }
  }
  final historical = o.mode == CalendarMode.historical;
  final months = <_Month>[];
  for (var i = 0; i < 14; i++) {
    final first = moons[i].civilDayNumber,
        count = moons[i + 1].civilDayNumber - first;
    final jingchu = historical && count == 28 && first == 1807696;
    if (!jingchu && (count < 29 || count > 30)) {
      throw RangeError('invalid lunar month length $count at civil day $first');
    }
    months.add(_Month(count, first, moons[i].time));
  }
  final yearHint =
      ((terms.first.civilDayNumber - 2451545 + 190) / _yearDays).floor() + 2000;
  if (historical && yearHint >= -721 && yearHint <= -104) {
    final starts = <int>[], bases = <int>[], names = <MonthName>[];
    for (var i = 0; i < 3; i++) {
      final year = yearHint + i - 1;
      double? estimate;
      var base = 2, name = MonthName.thirteen;
      if (year >= -721) {
        estimate =
            1457698 + (0.342 + (year + 721) * 12.368422).floor() * _monthDays;
      }
      if (year >= -479) {
        estimate =
            1546083 + (0.5 + (year + 479) * 12.368422).floor() * _monthDays;
      }
      if (year >= -220) {
        estimate =
            1640641 + (0.866 + (year + 220) * 12.369).floor() * _monthDays;
        base = 11;
        name = MonthName.laterNine;
      }
      if (estimate == null) {
        throw RangeError('historical month table does not cover this year');
      }
      starts.add(_assigned(HistoricalEventKind.newMoon, estimate, estimate, o));
      bases.add(base);
      names.add(name);
    }
    for (var i = 0; i < months.length; i++) {
      var era = 2;
      while (era > 0 && moons[i].civilDayNumber < starts[era]) {
        era--;
      }
      final offset = ((moons[i].civilDayNumber - starts[era] + 15) / _monthDays)
              .floor(),
          m = months[i];
      m.historicalYear = yearHint + era - 1;
      m.lunarYear = yearHint + era - 1 - (bases[era] == 11 ? 1 : 0);
      m.monthBuildingBranch = sequence[i] % 12;
      if (offset < 12) {
        m.month = _monthNumber(offset + bases[era]);
      } else {
        m.monthName = names[era];
        m.month = names[era] == MonthName.thirteen ? 13 : 9;
        m.isLeap = true;
      }
    }
    leap = -1;
  } else {
    for (var i = 0; i < months.length; i++) {
      final m = months[i], s = sequence[i];
      m.monthBuildingBranch = s % 12;
      m.month = _monthNumber(s);
      m.isLeap = i == leap;
      if (!historical) {
        continue;
      }
      final day = m.firstCivilDayNumber;
      if ((day >= 1724360 && day <= 1729794) ||
          (day >= 1807724 && day <= 1808699)) {
        m.month = _monthNumber(s + 1);
      } else if (day >= 1999349 && day <= 1999467) {
        m.month = _monthNumber(s + 2);
      } else if (day >= 1973067 && day <= 1977052) {
        if (s % 12 == 0) {
          m.month = 1;
        }
        if (s == 2) {
          m.month = 1;
          m.monthName = MonthName.altOne;
        }
      }
      if (day == 1729794 || day == 1808699) {
        m.month = 12;
        m.monthName = MonthName.altTwelve;
      }
      if (day == 1977112 || day == 1999526) {
        m.monthName = MonthName.laterSameName;
      }
    }
    _assignYears(months);
    if (historical) {
      for (final m in months) {
        if (m.firstCivilDayNumber >= 1640641 &&
            m.firstCivilDayNumber < 1683490) {
          m.historicalYear = m.lunarYear + 1;
        }
      }
    }
  }
  return ChineseCalendarYear._(
    terms,
    moons,
    months.map((m) => m.freeze()).toList(),
    leap,
    o,
  );
}

LunarCalendarDate solarToLunar(CalendarDate date, {CalendarOptions? options}) {
  final o = options ?? CalendarOptions();
  final target =
      (julianDay(year: date.year, month: date.month, day: date.day) + 0.5)
          .floor();
  final roundtrip = _date(target);
  if (roundtrip.year != date.year ||
      roundtrip.month != date.month ||
      roundtrip.day != date.day) {
    throw RangeError('invalid solar date');
  }
  final year = calculateChineseCalendarYear(
    target - o.structureOffset,
    options: o,
  );
  for (final m in year.months) {
    if (m.firstCivilDayNumber >= year.secondWinterSolsticeDayNumber) {
      break;
    }
    if (target < m.firstCivilDayNumber ||
        target >= m.firstCivilDayNumber + m.dayCount) {
      continue;
    }
    return LunarCalendarDate(
      year: m.lunarYear,
      historicalYear: m.historicalYear,
      month: m.month,
      day: target - m.firstCivilDayNumber + 1,
      isLeap: m.isLeap,
      monthDays: m.dayCount,
      monthName: m.monthName,
    );
  }
  throw RangeError('solar date is outside the calculated lunar window');
}

LunarCalendarDate instantToLunar(double jdUT1, {CalendarOptions? options}) {
  final o = options ?? CalendarOptions();
  return solarToLunar(_date(civilDayNumber(jdUT1, o.localOffset)), options: o);
}

Iterable<LunarMonth> _lunarYearMonths(int year, CalendarOptions o) sync* {
  for (var offset = 0; offset <= 1; offset++) {
    final anchor =
        julianDay(year: year + offset, month: 6, day: 1, hour: 12) -
        o.structureOffset;
    final window = calculateChineseCalendarYear(anchor, options: o);
    for (final m in window.months) {
      if (m.firstCivilDayNumber >= window.secondWinterSolsticeDayNumber) {
        break;
      }
      yield m;
    }
  }
}

/// Mirrors the upstream first-match lookup. Reform-era repeated year/month
/// labels can be ambiguous; see docs/calendar-history.md before historical use.
CalendarDate lunarToSolar(LunarDate date, {CalendarOptions? options}) {
  if (date.month < 1 || date.month > 13 || date.day < 1 || date.day > 30) {
    throw RangeError('invalid lunar date');
  }
  for (final m in _lunarYearMonths(date.year, options ?? CalendarOptions())) {
    if (m.lunarYear != date.year ||
        m.month != date.month ||
        m.isLeap != date.isLeap ||
        m.monthName != date.monthName) {
      continue;
    }
    if (date.day > m.dayCount) {
      throw RangeError('lunar day is outside the month');
    }
    return _date(m.firstCivilDayNumber + date.day - 1);
  }
  throw RangeError('lunar date not found');
}

int getLunarMonthDays(
  int lunarYear,
  int monthNumber, {
  bool isLeap = false,
  CalendarOptions? options,
}) {
  if (monthNumber < 1 || monthNumber > 13) {
    throw RangeError('invalid lunar month');
  }
  int? exceptional;
  for (final m in _lunarYearMonths(lunarYear, options ?? CalendarOptions())) {
    if (m.lunarYear != lunarYear ||
        m.month != monthNumber ||
        m.isLeap != isLeap) {
      continue;
    }
    if (m.monthName == MonthName.normal) {
      return m.dayCount;
    }
    exceptional ??= m.dayCount;
  }
  if (exceptional != null) {
    return exceptional;
  }
  throw RangeError('lunar month not found');
}

/// Previous includes an exact astronomical boundary; next excludes it.
CalendarSolarTerm findSolarTerm(
  double jdUT1, {
  SolarTermDirection direction = SolarTermDirection.previous,
  SolarTermFilter filter = SolarTermFilter.any,
  CalendarOptions? options,
}) {
  if (!jdUT1.isFinite) {
    throw ArgumentError.value(jdUT1, 'jdUT1');
  }
  final o = options ?? CalendarOptions(), tt = ut1ToTt(jdUT1);
  const stepAngle = math.pi / 12;
  final step = ((solarLongitudeState(tt).value % _twoPi) / stepAngle).floor();
  CalendarSolarTerm? best;
  for (var offset = -3; offset <= 3; offset++) {
    final longitudeStep = step + offset, id = (longitudeStep + 5) % 24;
    if (filter != SolarTermFilter.any &&
        (filter == SolarTermFilter.jie ? (id & 1) != 0 : (id & 1) == 0)) {
      continue;
    }
    final target = (longitudeStep % 24) * stepAngle;
    final time = solveSolarLongitude(
      target,
      tt + offset * _termDays,
      accuracy: o.eventAccuracy,
    );
    final candidate = CalendarSolarTerm(
      time,
      _assigned(HistoricalEventKind.solarTerm, time.jdUT1, time.jdUT1, o),
      (id + 1) % 24,
      target,
    );
    final difference = time.jdUT1 - jdUT1,
        next = direction == SolarTermDirection.next;
    if (!(next ? difference > 1e-10 : difference <= 1e-10)) {
      continue;
    }
    if (best != null &&
        (next
            ? time.jdUT1 >= best.time.jdUT1
            : time.jdUT1 <= best.time.jdUT1)) {
      continue;
    }
    best = candidate;
  }
  if (best == null) {
    throw RangeError('solar term not found');
  }
  return best;
}

/// 0=vernal equinox, 18=winter solstice; 19..23 refer to Jan–Mar of civilYear.
CalendarSolarTerm getSpecificSolarTerm(
  int civilYear,
  int termIndexFromVernalEquinox, {
  CalendarOptions? options,
}) {
  final index = termIndexFromVernalEquinox;
  if (index < 0 || index >= 24) {
    throw RangeError('term index must be 0..23');
  }
  final o = options ?? CalendarOptions();
  final winter = _winter(julianDay(year: civilYear, month: 6, day: 1), o);
  final fromWinter = index >= 19 ? index - 18 : index + 6;
  return _term(fromWinter, winter.time.jdTT + fromWinter * _termDays, o);
}

CalendarSolarTerm getPreviousSolarTerm(
  double jdUT1, {
  CalendarOptions? options,
}) => findSolarTerm(jdUT1, options: options);
CalendarSolarTerm getNextSolarTerm(double jdUT1, {CalendarOptions? options}) =>
    findSolarTerm(jdUT1, direction: SolarTermDirection.next, options: options);
CalendarSolarTerm getPreviousJie(double jdUT1, {CalendarOptions? options}) =>
    findSolarTerm(jdUT1, filter: SolarTermFilter.jie, options: options);
CalendarSolarTerm getNextJie(double jdUT1, {CalendarOptions? options}) =>
    findSolarTerm(
      jdUT1,
      direction: SolarTermDirection.next,
      filter: SolarTermFilter.jie,
      options: options,
    );
CalendarSolarTerm getPreviousQi(double jdUT1, {CalendarOptions? options}) =>
    findSolarTerm(jdUT1, filter: SolarTermFilter.qi, options: options);
CalendarSolarTerm getNextQi(double jdUT1, {CalendarOptions? options}) =>
    findSolarTerm(
      jdUT1,
      direction: SolarTermDirection.next,
      filter: SolarTermFilter.qi,
      options: options,
    );
