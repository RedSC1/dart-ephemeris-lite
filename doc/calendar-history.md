# 历史历法与农历转换

[中文](calendar-history.md) | [English](calendar-history.en.md) · [文档首页](README.md)

## 可运行示例

[calendar.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/calendar.dart)

```sh
dart run example/calendar.dart
```

<!-- example: example/calendar.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final options = CalendarOptions(mode: CalendarMode.chinaAstronomical);
  final lunar = solarToLunar(
    const CalendarDate(year: 2033, month: 12, day: 22),
    options: options,
  );
  print(lunar.toJson());
  print(lunarToSolar(lunar, options: options).toJson());

  final table = getQiShuoYear(
    2026,
    options: CalendarOptions(mode: CalendarMode.historical),
    lunarPhaseAnglesDeg: [0, 90, 180, 270],
  );
  final event = table.events.first;
  print('Actual local time: ${event.localTime.toJson()}');
  print('Calendar date: ${event.assignedDate.toJson()}');
}
```

`calculateChineseCalendarYear(jdUT1)` 返回前一冬至起的计算窗口：25 个节气、15 个朔、14 个农历月。
事件的 `time` 保存实际求解的天文时刻，`civilDayNumber` 保存所选历法采用的日期。
历史模式可用历史气朔表确定日期；China astronomical 固定以 UTC+8 组织月序；Local astronomical 使用指定时区或经线组织月序。

`solarToLunar(CalendarDate)` 按给定年月日转换，不使用其中的时分秒。
`instantToLunar(jdUT1)` 先使用选定的本地日界取得日期，再按指定的历法月序转换。
`lunarToSolar(LunarDate)` 和 `getLunarMonthDays` 使用相同的月份匹配规则。

## 历史月名与年份

`MonthName` 的 enum index 对齐 JS `MONTH_NAME`：normal、thirteen、laterNine、altTwelve、altOne、laterSameName。
特殊月名与闰月标志是不同字段，不应仅根据名称推断 `isLeap`。
月份以数值加名称标记表示；Dart 底层暂不提供中文月名格式化器。

- `lunarYear` / `LunarDate.year` 是农历年份标签。
- `historicalYear` 记录历史历法与干支使用的年份；秦汉改历附近可能与前者不同。
- 景初改历资料中的指定 28 天月会原样保留，不一律强制为 29 或 30 天。

## 已知边界限制

部分改历时期会出现重复的年份和月份标签，而当前反查接口没有 `historicalYear` 消歧参数：

1. 秦汉切换附近，同一个源年份/月标可能对应不同的 `historicalYear`。反查只按源年份、月份、闰标和名称取首个匹配，没有历史年份消歧。
   例如公历天文纪年 −221-10-31 正查得到 year=−221、historicalYear=−220、十月初一，但反查会得到 −221-09-01。
2. 762 年改历也存在重复月标。例如 762-04-29 正查后再反查得到 762-03-01。
3. 历史表开始附近的 −721-12-07，计算窗口可能越过资料覆盖起点并抛出范围错误。

这些示例不是全部受影响日期的穷举。在加入历史年份消歧接口前，不建议依靠这些改革窗口的反查结果进行排盘或资料校订。

纪年查询同样依赖历史农历反查。天文纪年 −456-06-01（UT1 零点）会抛出 `lunar date not found`；不要将这一错误解释为“没有在位年号”并替换为空列表。
