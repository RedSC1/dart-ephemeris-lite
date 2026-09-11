# ephemeris_lite

[简体中文](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/README.md) | [English](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/README.en.md)

用于 Dart 与 Flutter 的天文与历法计算库。提供天体位置、节气与月相、农历与算术回历、太阳时、升落、日月食和外部恒星表计算。纯 Dart 实现，无运行时依赖，支持 Dart VM 和 Dart Web。

移植自 [js-ephemeris-lite](https://github.com/RedSC1/js-ephemeris-lite)。行星模型基于 VSOP2013/TOP2013，月球基于 ELP/MPP02，部分系数经 DE441 校准；历史历法及相关数据来源见第三方声明。API 使用 Dart 命名参数、枚举和结果类型，不依赖 JavaScript 引擎或 FFI。

当前版本：`1.0.0-beta.2`。本包是天文与历法内核；十神及完整八字、紫微排盘属于独立上层包，不包含在本包中。恒星表由应用加载，不内置目录数据。

## 安装

```yaml
dependencies:
  ephemeris_lite: 1.0.0-beta.2
```

运行 `dart pub get`，Flutter 项目使用 `flutter pub get`。测试版可先固定版本，确认兼容后再调整约束。

## 可运行示例

[main.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/main.dart)

```sh
dart run example/main.dart
```

<!-- example: example/main.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final time = ZonedTime(
    year: 2000,
    month: 1,
    day: 1,
    hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();
  final earth = earthState(time.jdTT, accuracy: Accuracy.accurate);
  final moon = moonState(time.jdTT, accuracy: Accuracy.mid);
  print('TT: ${time.jdTT}; Delta-T: ${time.deltaTSeconds} s');
  print('Earth heliocentric J2000 [AU]: ${earth.position}');
  print('Moon geocentric J2000 [km]: ${moon.position}');
}
```

## 按任务查示例

| 任务 | 指南 |
| --- | --- |
| 时间尺度、位置与参考系 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/time-and-positions.md) |
| 气朔、年表与太阳时 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/qi-shuo-solar-time.md) |
| 农历与历史月名 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/calendar-history.md) |
| 算术回历 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/hijri-calendar.md) |
| 干支、四柱与纪年 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/ganzhi.md) |
| 升落、地平坐标与极区 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/visibility.md) |
| 照明、合冲、留与轨道事件 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/sky-events.md) |
| 全球与地方月食 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/lunar-eclipses.md) |
| 全球与地方日食 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/solar-eclipses.md) |
| 恒星与外部星表 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/fixed-stars.md) |
| 日月独立入口与体积 | [查看指南](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/module-loading.md) |

[完整使用文档](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/doc/README.md) · [API 参考](https://pub.dev/documentation/ephemeris_lite/latest/)

## 关键约定

- **时间尺度**：位置和通用天象搜索使用 TT；日界与地平观测使用 UT1。先构造 `JulianTime`，再取正确字段。UTC 近似 UT1，不是完整闰秒模型。
- **单位**：几何行星／日心状态为 AU、AU/day；地心月球为 km、km/day；视位置角度为度。气朔 `solve*` 的目标角为弧度，年表的月相角选项为度。
- **精度**：位置默认 accurate，气朔默认 mid。位置档位控制系数前缀；气朔档位还改变模型与求解流程。没有全局可变默认值。
- **历史历法**：实际天文时刻与历法归日分开保存。改历窗口有已知反查歧义，不能承诺所有历史日期都唯一往返。
- **范围与限制**：天体和年代不同，误差也不同。冥王星推荐 1600～2200；未来 ΔT 含实验性拟合。数值容差不等于天文精度保证。

## 许可证与来源

[MPL-2.0](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/LICENSE) · [中文第三方声明](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/THIRD_PARTY_NOTICES.zh-CN.md) · [Third-party notices](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/THIRD_PARTY_NOTICES.md)
