# 气朔、年表与太阳时

[中文](qi-shuo-solar-time.md) | [English](qi-shuo-solar-time.en.md) · [文档首页](README.md)

## 可运行示例

[solar_time.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/solar_time.dart)

```sh
dart run example/solar_time.dart
```

<!-- example: example/solar_time.dart -->
```dart
import 'dart:math' as math;
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final near = ZonedTime(
    year: 2026,
    month: 6,
    day: 21,
    hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();
  final solstice = solveSolarLongitude(
    math.pi / 2,
    near.jdTT,
    accuracy: Accuracy.accurate,
  );
  print('Solstice UTC+8: ${solstice.toZonedTime(480).toJson()}');
  print('Delta-T [s]: ${solstice.deltaTSeconds}');
  print('EOT [s]: ${equationOfTime(solstice).equationSeconds}');
  final clock = trueSolarTime(solstice, 116.4074);
  print('Apparent solar clock: ${clock.toJson()}');
  print('Original instant TT: ${clock.instant.jdTT}');
}
```

## 最近一次事件与展开角入口

`solveSolarLongitude(targetLongitude, nearJdTT)` 求附近最近的太阳视黄经事件；`solveLunarPhase(targetElongation, nearJdTT)` 求日月视黄经差事件。目标角为弧度，参考时刻为 TT 儒略日，返回 `JulianTime`。0、π/2、π、3π/2 分别表示朔、上弦、望、下弦；`solveNewMoon` 是目标为 0 的入口。

底层 `solarLongitudeTimeFast/Accurate` 和 `lunarPhaseTimeFast/Accurate` 接受展开角，每加 2π 选择下一个周期，直接返回 JD(TT)。普通应用优先用带参考时刻的 `solve*`。

| 档位 | 气朔求解 | 月球黄纬 |
| --- | --- | --- |
| `fast` | 固定阶段快速模型；不接受自定义容差或 safeguarded | 固定 10 项 |
| `mid`（默认） | 专用事件模型，迭代求根 | 默认 10 项，可设 0～277 或 `'full'` |
| `accurate` | 完整视位置链迭代求根 | 全量 |

`toleranceSeconds` 是数值收敛阈值，不是绝对天文误差保证。历史模式只控制归日，不修改这些接口返回的天文时刻。

## 民用年气朔表

`getQiShuoYear(year, options: ..., lunarPhaseAnglesDeg: [0, 90, 180, 270])` 返回固定时区民用年内的事件，按实际时刻排序。此处月相角使用**度**；默认仅列朔，节气默认开启。`includePentads: true` 可加入候；与节气同时输出时不重复初候。

`time` 和 `localTime` 是实际天文事件，`assignedDate` 是历法指定日。历史资料只用于节气和朔归日，不用于中间候或其他月相。年表不是农历月序。完整示例见 `example/qi_shuo.dart`。

## 太阳钟与均时差

`meanSolarTime` 与 `trueSolarTime` 接受 `ZonedTime`、`JulianTime` 或 UT1 儒略日；经度为东正西负的度数。`equationOfTime` 定义为视太阳时减平太阳时，提供秒与日两种单位。

返回的 `SolarClock` 是虚拟钟面，不是新物理时刻；原瞬间保留在 `instant`。可供日时柱计算使用，但不要据此重复施加时区偏移。固定时区不自动处理夏令时。

## 年表示例

```sh
dart run example/qi_shuo.dart
```

<!-- example: example/qi_shuo.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final table = getQiShuoYear(
    2026,
    options: CalendarOptions(mode: CalendarMode.historical),
    lunarPhaseAnglesDeg: [0, 90, 180, 270],
  );
  for (final event in table.events) {
    print('${event.name}: ${event.localTime.toJson()}');
    print(event.assignedDate.toJson());
  }
}
```
