# 干支、四柱与纪年

[中文](ganzhi.md) | [English](ganzhi.en.md) · [文档首页](README.md)

## 可运行示例

[four_pillars.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/four_pillars.dart)

```sh
dart run example/four_pillars.dart
```

<!-- example: example/four_pillars.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final clock = ZonedTime(
    year: 2003,
    month: 3,
    day: 13,
    hour: 11,
    offsetMinutes: 480,
  );
  final pillars = fourPillarsForZonedTime(
    clock,
    options: CalendarOptions(mode: CalendarMode.chinaAstronomical),
    ratHourMode: RatHourMode.nextDay,
  );
  print(describeFourPillars(pillars));
  for (final era in getChineseEraNames(clock.toJulianTime().jdUT1)) {
    print('${era.text} (${era.precision.name}, ${era.boundarySource})');
  }
}
```

## 基础接口与包边界

本包提供干支编码、纳音和四柱的天文／历法基础。`makeGanzhi`、`ganzhiStem`、`ganzhiBranch`、`ganzhiIndex`、`ganzhiName` 用于编码与读取；不要直接假定干支编码就是六十甲子索引。天干索引从甲 0 开始，地支从子 0 开始。

十神、藏干、神煞、起运与完整八字命盘属于独立的 `bazi_core`；十神函数名为 `getTenGod(dayStem, targetStem)`，不是本包导出。完整紫微排盘属于 `ziwei_core`。

## 时刻与子时规则

`fourPillarsForZonedTime` 接受固定时区民用时间。`calculateFourPillars(jdUT1, virtualTime)` 将实际瞬间和钟面分开：年、月柱比较 UT1 的节气边界，日、时柱读取钟面字段，可用平／真太阳钟。

基础规则为立春换年、节换月，不提供春节换年开关。

| `RatHourMode` | 晚子时（23:00～24:00） |
| --- | --- |
| `nextDay`（默认） | 以次日计算日柱及时干 |
| `currentDay` | 保留当日日柱及其时干推导 |
| `currentDayTomorrowStem` | 日柱仍为当日，仅取次日日干推导时干 |

`PillarHistoricalMode` 默认跟随历法选项。采用历史归日时，柱界为 UTC+8 指定日零点；这不意味着天文交节时刻被改写。

## 纪年候选

`getChineseEraNames(jdUT1)` 独立采用中国历史历法，不跟随界面时区；并存政权可返回多个候选。`EraPrecision.year` 说明资料仅精确到年，不暗示精确改元日。

纪年查询继承[历史农历反查限制](calendar-history.md)。结果不是史料真伪或争议裁决；错误也不能一律解释为“没有年号”。
