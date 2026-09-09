// Port of js-ephemeris-lite/src/ganzhi.js. MPL-2.0.
import 'chinese_calendar.dart';
import 'historical_calendar.dart';
import 'time.dart';

const heavenlyStems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
const earthlyBranches = [
  '子',
  '丑',
  '寅',
  '卯',
  '辰',
  '巳',
  '午',
  '未',
  '申',
  '酉',
  '戌',
  '亥',
];

enum Wuxing { water, wood, metal, earth, fire }

/// Choice of day pillar and hour stem during 23:00–00:00.
enum RatHourMode { nextDay, currentDay, currentDayTomorrowStem }

enum PillarHistoricalMode { followCalendar, off, on }

const _nayin = [
  2,
  2,
  4,
  4,
  1,
  1,
  3,
  3,
  2,
  2,
  4,
  4,
  0,
  0,
  3,
  3,
  2,
  2,
  1,
  1,
  0,
  0,
  3,
  3,
  4,
  4,
  1,
  1,
  0,
  0,
  2,
  2,
  4,
  4,
  1,
  1,
  3,
  3,
  2,
  2,
  4,
  4,
  0,
  0,
  3,
  3,
  2,
  2,
  1,
  1,
  0,
  0,
  3,
  3,
  4,
  4,
  1,
  1,
  0,
  0,
];
void _stem(int v) {
  if (v < 0 || v >= 10) {
    throw RangeError('stem must be 0..9');
  }
}

void _branch(int v) {
  if (v < 0 || v >= 12) {
    throw RangeError('branch must be 0..11');
  }
}

/// Packed integer: high nibble=stem, low nibble=branch, matching JS/C++.
int makeGanzhi(int stem, int branch) {
  _stem(stem);
  _branch(branch);
  if ((stem & 1) != (branch & 1)) {
    throw RangeError('stem and branch parity is incompatible');
  }
  return (stem << 4) | branch;
}

int ganzhiStem(int value) {
  if (value < 0 || value > 255) {
    throw RangeError('invalid Ganzhi value');
  }
  final stem = value >> 4, branch = value & 15;
  makeGanzhi(stem, branch);
  return stem;
}

int ganzhiBranch(int value) {
  ganzhiStem(value);
  return value & 15;
}

int ganzhiIndex(int value) =>
    (6 * ganzhiStem(value) - 5 * ganzhiBranch(value)) % 60;
String ganzhiName(int value) =>
    '${heavenlyStems[ganzhiStem(value)]}${earthlyBranches[ganzhiBranch(value)]}';
int advanceGanzhi(int value, int delta) {
  final index = (ganzhiIndex(value) + delta % 60) % 60;
  return makeGanzhi(index % 10, index % 12);
}

/// 0=Yin, ..., 10=Zi, 11=Chou.
int getMonthGanzhi(int yearStem, int monthIndex) {
  _stem(yearStem);
  _branch(monthIndex);
  return makeGanzhi(
    ((yearStem % 5) * 2 + 2 + monthIndex) % 10,
    (monthIndex + 2) % 12,
  );
}

int getHourGanzhi(int dayStem, int hourIndex) {
  _stem(dayStem);
  _branch(hourIndex);
  return makeGanzhi(((dayStem % 5) * 2 + hourIndex) % 10, hourIndex);
}

int getNayinId(int value) => ganzhiIndex(value) ~/ 2;
Wuxing getNayinElement(int value) => Wuxing.values[_nayin[ganzhiIndex(value)]];
double _jd(CalendarDate v) => julianDay(
  year: v.year,
  month: v.month,
  day: v.day,
  hour: v.hour,
  minute: v.minute,
  second: v.second,
);
CalendarDate _clock(
  CalendarDate v, {
  int hour = 0,
  int minute = 0,
  double second = 0,
}) => CalendarDate(
  year: v.year,
  month: v.month,
  day: v.day,
  hour: hour,
  minute: minute,
  second: second,
);
void _validate(CalendarDate v) {
  if (!v.second.isFinite ||
      v.second < 0 ||
      v.second >= 60 ||
      v.month < 1 ||
      v.month > 12 ||
      v.day < 1 ||
      v.day > 31 ||
      v.hour < 0 ||
      v.hour > 23 ||
      v.minute < 0 ||
      v.minute > 59) {
    throw RangeError('virtualTime field is outside its valid range');
  }
  final roundtrip = calendarDateFromJulianDay(_jd(_clock(v, hour: 12)));
  if (roundtrip.year != v.year ||
      roundtrip.month != v.month ||
      roundtrip.day != v.day) {
    throw RangeError('invalid virtualTime');
  }
}

/// Canonicalizes exact JD spellings of civil-hour boundaries, without a broad
/// time epsilon. Returns civil fields only; it does not redefine the instant.
CalendarDate normalizeChartVirtualTime(CalendarDate v) {
  _validate(v);
  if (v.minute != 0 && v.minute != 59) {
    return v;
  }
  final source = _jd(v), midnight = _jd(_clock(v));
  for (var hour = 0; hour <= 24; hour++) {
    final boundary = midnight + hour / 24;
    final spelling = calendarDateFromJulianDay(boundary);
    if (source != boundary && source != _jd(spelling)) {
      continue;
    }
    if (hour < 24) {
      return _clock(v, hour: hour);
    }
    return _clock(calendarDateFromJulianDay(midnight + 1.5));
  }
  return v;
}

/// Civil date only; time-of-day fields are deliberately ignored.
int calculateDayPillar(CalendarDate date) {
  _validate(_clock(date));
  final index = ((_jd(_clock(date, hour: 12)) - 2451545).floor() - 6) % 60;
  return makeGanzhi(index % 10, index % 12);
}

class FourPillars {
  final int year, month, day, hour;
  const FourPillars({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
  });
  Map<String, int> toJson() => {
    'year': year,
    'month': month,
    'day': day,
    'hour': hour,
  };
}

Map<String, String> describeFourPillars(FourPillars pillars) =>
    Map.unmodifiable({
      'year': ganzhiName(pillars.year),
      'month': ganzhiName(pillars.month),
      'day': ganzhiName(pillars.day),
      'hour': ganzhiName(pillars.hour),
    });
({double jdUT1, int? assignedDay}) _boundary(
  CalendarSolarTerm term,
  bool historical,
) {
  final day = historical
      ? historicalEventCivilDay(HistoricalEventKind.solarTerm, term.time.jdUT1)
      : null;
  return (
    jdUT1: day == null ? term.time.jdUT1 : day - 0.5 - 480 / 1440,
    assignedDay: day,
  );
}

/// Physical boundary shared by pillar and downstream calendar consumers.
double getPillarTermBoundary(
  CalendarSolarTerm term, {
  CalendarOptions? options,
  PillarHistoricalMode pillarHistoricalMode =
      PillarHistoricalMode.followCalendar,
}) {
  final historical =
      pillarHistoricalMode == PillarHistoricalMode.on ||
      (pillarHistoricalMode == PillarHistoricalMode.followCalendar &&
          (options ?? CalendarOptions()).mode == CalendarMode.historical);
  return _boundary(term, historical).jdUT1;
}

/// Select by assigned boundary, including term days preceding the astronomical event.
CalendarSolarTerm getPreviousPillarJie(
  double jd, {
  CalendarOptions? options,
  PillarHistoricalMode pillarHistoricalMode =
      PillarHistoricalMode.followCalendar,
}) {
  if (!jd.isFinite) throw ArgumentError.value(jd, 'jd');
  final o = options ?? CalendarOptions();
  final historical =
      pillarHistoricalMode == PillarHistoricalMode.on ||
      (pillarHistoricalMode == PillarHistoricalMode.followCalendar &&
          o.mode == CalendarMode.historical);
  // Include the following Jie, then walk back by effective boundary.
  var term = getPreviousJie(jd + (historical ? 40 : 0), options: o);
  for (var i = 0; i < 8; i++) {
    if (_boundary(term, historical).jdUT1 <= jd + 1e-10) return term;
    term = getPreviousJie(term.time.jdUT1 - 10, options: o);
  }
  throw StateError('previous pillar Jie boundary not found');
}

/// Year/month use the physical UT1 instant; day/hour use [virtualTime], which
/// may be a wall clock or an independently resolved mean/apparent solar clock.
/// This low-level four-pillar API uses Li Chun, not Lunar New Year, as year start.
FourPillars calculateFourPillars(
  double jdUT1,
  CalendarDate virtualTime, {
  CalendarOptions? options,
  RatHourMode ratHourMode = RatHourMode.nextDay,
  PillarHistoricalMode pillarHistoricalMode =
      PillarHistoricalMode.followCalendar,
}) {
  if (!jdUT1.isFinite) {
    throw ArgumentError.value(jdUT1, 'jdUT1');
  }
  final v = normalizeChartVirtualTime(virtualTime),
      o = options ?? CalendarOptions();
  final historical = switch (pillarHistoricalMode) {
    PillarHistoricalMode.on => true,
    PillarHistoricalMode.off => false,
    PillarHistoricalMode.followCalendar => o.mode == CalendarMode.historical,
  };
  final lichun = getSpecificSolarTerm(v.year, 21, options: o);
  final pillarYear =
      v.year + (jdUT1 - _boundary(lichun, historical).jdUT1 < -1e-10 ? -1 : 0);
  final yi = (pillarYear - 1984) % 60, year = makeGanzhi(yi % 10, yi % 12);
  final jie = getPreviousPillarJie(
    jdUT1,
    options: o,
    pillarHistoricalMode: pillarHistoricalMode,
  );
  final index = jie.indexFromWinterSolstice;
  if ((index & 1) == 0) {
    throw StateError('previous Jie has an invalid index');
  }
  final month = getMonthGanzhi(ganzhiStem(year), ((index + 21) ~/ 2) % 12);
  final late = v.hour >= 23;
  final anchor = late && ratHourMode == RatHourMode.nextDay
      ? calendarDateFromJulianDay(_jd(_clock(v)) + 1)
      : v;
  final day = calculateDayPillar(anchor);
  final hourStem = late && ratHourMode == RatHourMode.currentDayTomorrowStem
      ? ganzhiStem(advanceGanzhi(day, 1))
      : ganzhiStem(day);
  return FourPillars(
    year: year,
    month: month,
    day: day,
    hour: getHourGanzhi(hourStem, ((v.hour + 1) ~/ 2) % 12),
  );
}

FourPillars fourPillarsForZonedTime(
  ZonedTime time, {
  CalendarOptions? options,
  RatHourMode ratHourMode = RatHourMode.nextDay,
  PillarHistoricalMode pillarHistoricalMode =
      PillarHistoricalMode.followCalendar,
}) => calculateFourPillars(
  time.toJulianTime().jdUT1,
  time,
  options: options,
  ratHourMode: ratHourMode,
  pillarHistoricalMode: pillarHistoricalMode,
);
