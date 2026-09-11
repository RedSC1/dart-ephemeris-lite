/// 日月几何星历独立入口，不引入其他行星的系数表。
///
/// 输入为 TT 儒略日，输出为 J2000 平黄道／平春分点几何状态。
/// 地心月球使用 km、km/day，日心及地心太阳状态使用 AU、AU/day。
/// 与主入口采用同一模型和精度选项；模块拆分只减少依赖，不减少系数。
/// 需要时间、历法、天象事件等完整 API 时使用 ephemeris_lite.dart。
library;

export 'src/accuracy.dart';
export 'src/sun_moon_ephemeris.dart'
    hide earthStateWithPrefixes, moonDirectionWithTerms, moonLongitudeWithTerms;
