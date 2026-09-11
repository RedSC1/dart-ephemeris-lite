// Port of js-ephemeris-lite/src/chinese-era.js. MPL-2.0.
import 'dart:math' as math;
import 'chinese_calendar.dart';
import 'generated/chinese_era_data.dart';
import 'historical_calendar.dart';
import 'time.dart';

const modernChinaEraStartJd = 2432917.1666666665;
const modernChinaEstablishmentJd = 2433190.7916666665;
const republicOfChinaEraStartJd = 2419402.1666666665;
const hongxianEraStartJd = 2420863.1666666665;
const hongxianEraEndJdExclusive = 2420946.1666666665;
const _hongxian = EraRecord(1916, 1, 0, '中华帝国', '', '', '洪宪', null, null);
const _chinaOffset = 480 / 1440;

/// 纪年有效边界的资料精度，区分精确到日与仅到年。
enum EraPrecision { day, year }

/// 纪年候选及其来源、有效范围与资料精度。
class ChineseEraName {
  final String dynasty, title, ruler, era, boundarySource, text;
  final int yearNumber;
  final double startJd, endJdExclusive;
  final EraPrecision precision;
  ChineseEraName._(
    EraRecord record,
    this.yearNumber,
    this.startJd,
    this.endJdExclusive,
    this.precision,
    this.boundarySource,
  ) : dynasty = record.dynasty,
      title = record.title,
      ruler = record.ruler,
      era = record.era,
      text = _format(record, yearNumber);
  Map<String, Object> toJson() => {
    'dynasty': dynasty,
    'title': title,
    'ruler': ruler,
    'era': era,
    'yearNumber': yearNumber,
    'startJd': startJd,
    'endJdExclusive': endJdExclusive,
    'precision': precision.name,
    'boundarySource': boundarySource,
    'text': text,
  };
}

String _format(EraRecord r, int year) {
  final ruler = [r.title, r.ruler].where((s) => s.isNotEmpty).join(' ');
  return '[${r.dynasty}]${ruler.isEmpty ? '' : '$ruler '}${r.era}$year年';
}

typedef _Boundary = ({double? start, double? end});
_Boundary _source(EraRecord r) {
  final starts = <double>[], ends = <double>[];
  final m = r.manakai, d = r.ddbc;
  if (m != null) {
    if (m[0]?.isFinite ?? false) {
      starts.add(m[0]!);
    }
    if (m[1]?.isFinite ?? false) {
      ends.add(m[1]!);
    }
  }
  if (d != null && d.isNotEmpty) {
    starts.add(d.first[0]);
    ends.add(d.last[1]);
  }
  return (
    start: starts.isEmpty ? null : starts.reduce(math.max),
    end: ends.isEmpty ? null : ends.reduce(math.min),
  );
}

final _adjacent = _buildAdjacent();
Map<EraRecord, _Boundary> _buildAdjacent() {
  final groups = <String, List<EraRecord>>{};
  for (final r in chineseEraRecords) {
    groups
        .putIfAbsent('${r.dynasty}\u0000${r.title}\u0000${r.ruler}', () => [])
        .add(r);
  }
  final result = <EraRecord, _Boundary>{};
  for (final group in groups.values) {
    for (var i = 0; i < group.length; i++) {
      result[group[i]] = (
        start: i == 0 ? null : _source(group[i - 1]).end,
        end: i + 1 == group.length ? null : _source(group[i + 1]).start,
      );
    }
  }
  return Map.unmodifiable(result);
}

int _usedYears(EraRecord r) =>
    r.dynasty == '秦' && r.title == '始皇帝' && r.ruler == '嬴政' && r.era == '始皇'
    ? 25
    : r.usedYears;

/// 按 UT1 瞬间查询中国纪年候选，可同时返回并存政权。
///
/// 独立采用中国历史历法，不跟随显示时区。年级资料不暗示精确改元日；
/// 结果是数据查询，不是对史料争议的裁决。
///
/// 纪年查询依赖历史农历反查，继承改历时期重复标签的限制。
List<ChineseEraName> getChineseEraNames(double jdUT1) {
  if (!jdUT1.isFinite) {
    throw ArgumentError.value(jdUT1, 'jdUT1');
  }
  final o = CalendarOptions();
  final lunar = instantToLunar(jdUT1, options: o),
      civilYear = calendarDateFromJulianDay(jdUT1 + _chinaOffset).year;
  // Per-query memoization avoids unbounded global year caches.
  final starts = <int, double>{};
  double yearStart(int y) => starts.putIfAbsent(y, () {
    final solar = lunarToSolar(
      LunarDate(year: y, month: 1, day: 1),
      options: o,
    );
    return julianDay(year: solar.year, month: solar.month, day: solar.day) -
        _chinaOffset;
  });
  final results = <ChineseEraName>[];
  void add(
    EraRecord r,
    int y,
    double start,
    double end,
    EraPrecision p,
    String source,
  ) => results.add(ChineseEraName._(r, y, start, end, p, source));
  for (final r in chineseEraRecords) {
    final used = _usedYears(r);
    if (r.dynasty == '当代' && r.startYear == 1949) {
      if (jdUT1 >= modernChinaEraStartJd) {
        add(
          r,
          civilYear,
          modernChinaEraStartJd,
          double.infinity,
          EraPrecision.day,
          'historical-decision',
        );
      }
      continue;
    }
    if (r.dynasty == '近、现代' && r.startYear == 1912) {
      if (jdUT1 >= republicOfChinaEraStartJd &&
          jdUT1 < modernChinaEstablishmentJd) {
        add(
          r,
          civilYear - r.startYear + 1 + used,
          republicOfChinaEraStartJd,
          modernChinaEstablishmentJd,
          EraPrecision.day,
          'historical-event',
        );
      }
      continue;
    }
    final raw = r.manakai, adjacent = _adjacent[r]!;
    final exactStart = raw != null && (raw[0]?.isFinite ?? false),
        exactEnd = raw != null && (raw[1]?.isFinite ?? false);
    final adjacentStart = !exactStart && adjacent.start != null,
        adjacentEnd = !exactEnd && adjacent.end != null;
    final yearOnly =
        raw != null &&
        !exactStart &&
        !exactEnd &&
        !adjacentStart &&
        !adjacentEnd;
    if (yearOnly &&
        (lunar.year < r.startYear || lunar.year >= r.startYear + r.duration)) {
      continue;
    }
    final hasTransition = raw != null || adjacentStart || adjacentEnd;
    final transition = hasTransition
        ? (
            start: exactStart
                ? raw[0]!
                : adjacentStart
                ? adjacent.start!
                : yearStart(r.startYear),
            end: exactEnd
                ? raw[1]!
                : adjacentEnd
                ? adjacent.end!
                : yearStart(r.startYear + r.duration),
          )
        : null;
    if (transition != null &&
        (jdUT1 < transition.start || jdUT1 >= transition.end)) {
      continue;
    }
    final segments = r.ddbc;
    if (segments != null) {
      for (final segment in segments) {
        if (jdUT1 < segment[0] || jdUT1 >= segment[1]) {
          continue;
        }
        final start = transition == null
                ? segment[0]
                : math.max(segment[0], transition.start),
            end = transition == null
                ? segment[1]
                : math.min(segment[1], transition.end);
        if (jdUT1 >= start && jdUT1 < end) {
          add(
            r,
            segment[2].toInt(),
            start,
            end,
            EraPrecision.day,
            transition == null ? 'ddbc' : 'ddbc+manakai',
          );
        }
        break;
      }
      continue;
    }
    if (transition != null) {
      final y = lunar.year - r.startYear + 1 + used,
          start = math.max(transition.start, yearStart(lunar.year)),
          end = math.min(transition.end, yearStart(lunar.year + 1));
      if (y > 0 && jdUT1 >= start && jdUT1 < end) {
        add(
          r,
          y,
          start,
          end,
          (exactStart || adjacentStart) && (exactEnd || adjacentEnd)
              ? EraPrecision.day
              : EraPrecision.year,
          raw != null ? 'manakai' : 'transition-handoff',
        );
      }
      continue;
    }
    if (lunar.year < r.startYear || lunar.year >= r.startYear + r.duration) {
      continue;
    }
    final start = yearStart(r.startYear),
        end = yearStart(r.startYear + r.duration);
    if (jdUT1 >= start && jdUT1 < end) {
      add(
        r,
        lunar.year - r.startYear + 1 + used,
        start,
        end,
        EraPrecision.year,
        'sxwnl-year',
      );
    }
  }
  if (jdUT1 >= hongxianEraStartJd && jdUT1 < hongxianEraEndJdExclusive) {
    add(
      _hongxian,
      1,
      hongxianEraStartJd,
      hongxianEraEndJdExclusive,
      EraPrecision.day,
      'historical-event',
    );
  }
  final seen = <String>{};
  return List.unmodifiable(results.where((r) => seen.add(r.text)));
}
