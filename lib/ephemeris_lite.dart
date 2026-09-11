/// Dart 与 Flutter 天文及历法计算库。
///
/// 提供天体位置、气朔、农历、太阳时、升落、日月食与外部恒星表接口。
/// 几何星历使用 TT 儒略日；民用日期和观测日界使用明确的固定时区。
/// 请先用 [ZonedTime] 或 [JulianTime] 表达瞬间，再取对应时间尺度。
///
/// 位置计算默认 [Accuracy.accurate]，气朔默认 [Accuracy.mid]，没有全局
/// 可变精度设置。气朔三档还改变模型与求解流程，不仅是系数项数。
/// 历史历法只改变归日，不覆盖气朔的实际天文时刻。
///
/// ```dart
/// final time = ZonedTime(
///   year: 2026, month: 6, day: 21, offsetMinutes: 480,
/// ).toJulianTime();
/// final moon = moonState(time.jdTT);
/// print(moon.position); // 地心几何位置，km。
/// ```
library;

export 'src/accuracy.dart';
export 'src/time.dart';
export 'src/ephemeris.dart'
    hide earthStateWithPrefixes, moonDirectionWithTerms, moonLongitudeWithTerms;

export 'src/coordinates.dart';
export 'src/event_fast.dart' show solarLongitudeTimeFast, lunarPhaseTimeFast;
export 'src/apparent.dart';
export 'src/event_accurate.dart'
    show solarLongitudeTimeAccurate, lunarPhaseTimeAccurate;
export 'src/event_mid.dart'
    show
        solarLongitudeState,
        moonLongitudeState,
        elongationState,
        lowSolarLongitudeState,
        lowElongationState;
export 'src/calendar_events.dart';
export 'src/solar_time.dart' hide solarCoreEquatorial;
export 'src/historical_calendar.dart';
export 'src/qi_shuo.dart';
export 'src/chinese_calendar.dart';
export 'src/ganzhi.dart';
export 'src/chinese_era.dart';
export 'src/event_search.dart';
export 'src/observer.dart' hide validateVisibilityObserver;
export 'src/solar_visibility.dart';
export 'src/body_visibility.dart';
export 'src/phenomena.dart';
export 'src/disc_radii.dart';
export 'src/orbital_events.dart';
export 'src/lunar_eclipses.dart';
export 'src/fixed_stars.dart';
export 'src/solar_eclipses.dart';
export 'src/api_metadata.dart';

export 'src/hijri_calendar.dart';
