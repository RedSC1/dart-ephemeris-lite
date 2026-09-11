# 文档与示例

[中文](README.md) | [English](README.en.md)

从下面的任务入口开始。每篇使用指南都含完整 Dart 示例、运行命令及模型限制；示例源码保留在 `example/`，中英文页使用同一份代码。

| 任务 | 可运行文件 |
| --- | --- |
| [时间尺度、位置与参考系](time-and-positions.md) | [positions.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/positions.dart) |
| [气朔、年表与太阳时](qi-shuo-solar-time.md) | [solar_time.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/solar_time.dart) |
| [农历与历史月名](calendar-history.md) | [calendar.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/calendar.dart) |
| [算术回历](hijri-calendar.md) | [hijri_calendar.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/hijri_calendar.dart) |
| [干支、四柱与纪年](ganzhi.md) | [four_pillars.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/four_pillars.dart) |
| [升落、地平坐标与极区](visibility.md) | [visibility.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/visibility.dart) |
| [照明、合冲、留与轨道事件](sky-events.md) | [sky_events.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/sky_events.dart) |
| [全球与地方月食](lunar-eclipses.md) | [local_lunar_eclipse.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/local_lunar_eclipse.dart) |
| [全球与地方日食](solar-eclipses.md) | [local_solar_eclipse.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/local_solar_eclipse.dart) |
| [恒星与外部星表](fixed-stars.md) | [fixed_stars.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/fixed_stars.dart) |
| [日月独立入口与体积](module-loading.md) | [sun_moon.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/sun_moon.dart) |

## 开发与迁移参考

- [JS → Dart API 对照](api-map.md)
- [功能范围与兼容性](port-status.md)
- [测试来源与已知差异](test-migration.md)
- [文档生成、验证与数据同步](development.md)

这些页面属于开发参考，不是首次使用的前置知识。生成的 Dartdoc 用于逐项查询参数和返回值，不替代专题示例。
