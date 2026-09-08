// Port of js-ephemeris-lite historical civil-day profiles. MPL-2.0.
import 'generated/historical_calendar_data.dart';
import 'accuracy.dart';

/// Historical assignment affects calendar dates, not astronomical event roots.
enum CalendarMode { historical, chinaAstronomical, localAstronomical }

enum CalendarDayBoundaryMode { fixedUtcOffset, meanSolarMeridian }

enum HistoricalEventKind { solarTerm, newMoon }

/// Calendar structure and astronomical solver choices are independent.
class CalendarOptions {
  final CalendarMode mode;
  final CalendarDayBoundaryMode dayBoundaryMode;
  final double utcOffsetMinutes;
  final double? meridianDeg;
  final Accuracy eventAccuracy;
  CalendarOptions({
    this.mode = CalendarMode.historical,
    this.dayBoundaryMode = CalendarDayBoundaryMode.fixedUtcOffset,
    this.utcOffsetMinutes = 480,
    this.meridianDeg,
    this.eventAccuracy = Accuracy.mid,
  }) {
    if (!utcOffsetMinutes.isFinite || utcOffsetMinutes.abs() > 840) {
      throw RangeError('utcOffsetMinutes must be within ±14 hours');
    }
    if (meridianDeg != null &&
        (!meridianDeg!.isFinite || meridianDeg!.abs() > 180)) {
      throw RangeError('meridianDeg must be within ±180 degrees');
    }
    if ((dayBoundaryMode == CalendarDayBoundaryMode.meanSolarMeridian) !=
        (meridianDeg != null)) {
      throw ArgumentError('meridianDeg is required only for meanSolarMeridian');
    }
  }
  double get localOffset =>
      dayBoundaryMode == CalendarDayBoundaryMode.fixedUtcOffset
      ? utcOffsetMinutes / 1440
      : meridianDeg! / 360;
  double get structureOffset =>
      mode == CalendarMode.localAstronomical ? localOffset : 480 / 1440;
}

/// Integer civil-day label; [dayOffset] is measured in days east of UT1.
int civilDayNumber(double jdUT1, [double dayOffset = 480 / 1440]) {
  if (!jdUT1.isFinite || !dayOffset.isFinite) {
    throw ArgumentError('Civil-day arguments must be finite');
  }
  return (jdUT1 + dayOffset + 0.5).floor();
}

bool _bit(List<int> words, int index) =>
    ((words[index >> 5] >> (index & 31)) & 1) != 0;
int _popcount(int word) {
  // Avoid JS signed 32-bit multiplication differences in Dart-to-JS builds.
  var value = word, count = 0;
  while (value != 0) {
    value = (value & (value - 1)).toUnsigned(32);
    count++;
  }
  return count;
}

int _rank(List<int> words, List<int> prefixes, int index) {
  final block = index ~/ historicalRankBlockEvents;
  final wordIndex = index >> 5;
  var rank = prefixes[block];
  for (var i = block * (historicalRankBlockEvents ~/ 32); i < wordIndex; i++) {
    rank += _popcount(words[i]);
  }
  final remainder = index & 31;
  if (remainder != 0) {
    rank += _popcount(words[wordIndex] & ((1 << remainder) - 1));
  }
  return rank;
}

int _linear(List<int> segment, int index, [int phase = 0]) {
  final ticks = segment[2] + segment[3] * (index - segment[0]) + phase;
  return ((ticks + historicalCivilDayScale / 2) / historicalCivilDayScale)
      .floor();
}

/// Historical civil-day assignment, or null outside the profile's coverage.
/// [estimateJdUT1] identifies an event cycle; it is not altered or returned as
/// a corrected astronomical instant. Non-finite estimates return null, as in JS.
int? historicalEventCivilDay(HistoricalEventKind kind, double estimateJdUT1) {
  if (!estimateJdUT1.isFinite || estimateJdUT1 >= historicalProfileEndJd) {
    return null;
  }
  final profile = kind == HistoricalEventKind.solarTerm
      ? historicalSolarTerm
      : historicalNewMoon;
  final phaseIndex = kind == HistoricalEventKind.solarTerm
      ? ((estimateJdUT1 + 7 - 2451259) / 365.2422 * 24).floor()
      : ((estimateJdUT1 + 14 - 2451551) / 29.5306).floor();
  final index = phaseIndex - profile.firstPhaseIndex;
  if (index < 0 || index >= profile.eventCount) return null;
  for (final segment in profile.exactSegments) {
    if (index >= segment[0] && index < segment[0] + segment[1]) {
      return _linear(segment, index);
    }
  }
  final local = index - profile.tail[0];
  final phase = profile.phaseTicks.isEmpty
      ? 0
      : profile.phaseTicks[local % profile.phaseTicks.length];
  var day = _linear(profile.tail, index, phase);
  if (_bit(profile.residualMask, local)) {
    final rank = _rank(profile.residualMask, profile.residualRank, local);
    day += _bit(profile.residualSigns, rank) ? 1 : -1;
  }
  return day;
}
