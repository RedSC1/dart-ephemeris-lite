# 算术回历

[中文](hijri-calendar.md) | [English](hijri-calendar.en.md) · [文档首页](README.md)

## 可运行示例

[hijri_calendar.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/hijri_calendar.dart)

```sh
dart run example/hijri_calendar.dart
```

<!-- example: example/hijri_calendar.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final date = solarToHijri(const CalendarDate(year: 2000, month: 1, day: 1));
  print('Arithmetic Hijri: $date');
  print('Civil date: ${hijriToSolar(date).toJson()}');
  print(instantToHijri(JulianTime.fromUT1(2451545), offsetMinutes: 480));
}
```

`solarToHijri`、`hijriToSolar`、`instantToHijri` 与 JS 同步提供。
保留原 `oba.getHuiLi()` 的算术规则，用整数周期运算实现并补充反向转换；
与旧近似公式逐日比较五个完整周期（53155 天），JS/Dart 共用冻结样本。


## 规则与限制

- 每 30 年共 10631 天，闰年序号为 2、5、7、10、13、16、18、21、24、26、29。
  奇数月 30 天、偶数月 29 天；闰年第十二月增加一天。
- 民用历沿用本库混合儒略历/格里历，1 AH 对应 622-07-16，正反转换支持民用年 −6000..10000。
  1582 年改历缺日和不可能的月日会报错，不自动归一化非法输入。
- 年 0 与负数只是同一周期的序推标签，不是历史伊斯兰历纪年。
- `solarToHijri(CalendarDate)` 只使用年月日，忽略钟表字段；`hijriToSolar(HijriDate)` 返回零时字段的民用日期，
  它不带时区，也不是一个物理时刻。
- `instantToHijri` 必须传入 `JulianTime` 与 `offsetMinutes`，整数分钟 ±14 小时。
  沿用 `UTC ≈ UT1`，按固定偏移下的午夜换日；没有隐含北京时间、日落换日或夏令时。
- 这是**算术回历**，不根据当地见月、宗教公告或 Umm al-Qura 数据表决定月份。
- `HijriDate` 校验真实月长，字段不可变；闰年/月长辅助函数接受回历年 −10000..10000，
  但正反日期转换另受上述民用日期范围限制。

来源署名见根目录第三方声明。无星历调用、无运行时数据表、无新增依赖。
