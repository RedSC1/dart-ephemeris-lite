# ephemeris_lite

用于 Dart 与 Flutter 的天文与历法计算库。提供天体位置、节气与月相、
农历与算术回历转换、干支、太阳时、天体升落和日月食计算。
采用纯 Dart 实现，无运行时依赖，可运行于 Dart VM 和 Dart Web。

本项目移植自 [js-ephemeris-lite](https://github.com/RedSC1/js-ephemeris-lite)。
行星模型基于 VSOP2013/TOP2013，月球模型基于 ELP/MPP02，部分系数采用 DE441 校准；
历史历法、算术回历及纪年资料的来源见[第三方声明](https://github.com/RedSC1/ephemeris_lite/blob/main/THIRD_PARTY_NOTICES.zh-CN.md)。
API 使用 Dart 的命名参数、枚举和结果类型，不依赖 JavaScript 引擎或 FFI。

当前版本为 `1.0.0-beta.1`。算法与数值语义以对应 JS 实现为基准，
源码版本和数据哈希记录在 [上游记录](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/upstream.json) 中。

## 功能概览

| 模块 | 主要功能 |
| --- | --- |
| 时间 | 儒略日、固定时区、UT1/TT、ΔT、历史儒略历／格里高利历 |
| 天体位置 | 日月与行星几何位置、解析速度、地心视位置、参考系转换 |
| 气朔与历法 | 定气定朔、月相年表、历史归日、农历与算术回历正反转换 |
| 干支与纪年 | 四柱基础计算、子时规则、纳音、历史纪年候选查询 |
| 太阳时与可见性 | 平太阳时、真太阳时、均时差、恒星时、升落与中天 |
| 天象事件 | 合冲、留、黄经穿越、近远点、交点、大距与赤经事件 |
| 日月食 | 全球搜索、接触时刻、地方食况与地平线可见性 |
| 恒星 | 外部 TSC1 星表解析、别名查找、空间运动传播与视位置 |

本包提供天文与历法内核，不包含完整八字／紫微排盘、黄历宜忌或地图渲染。
恒星目录由调用者加载，支持完整表和 lite 表，不内置目录数据。

## 安装

在 `pubspec.yaml` 中添加依赖，执行 `dart pub get`；Flutter 项目使用 `flutter pub get`。
测试版本可先固定版本号，确认兼容后再调整约束：

```yaml
dependencies:
  ephemeris_lite: 1.0.0-beta.1
```

## 快速开始

```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final instant = ZonedTime(
    year: 2000, month: 1, day: 1, hour: 12,
    offsetMinutes: 480,
  ).toJulianTime();

  final earth = earthState(instant.jdTT, accuracy: Accuracy.accurate);
  final moon = moonState(instant.jdTT, accuracy: Accuracy.mid);
  print(earth.position); // 日心地球，AU
  print(earth.velocity); // AU/day
  print(moon.position); // 地心月球，km
}
```

## 文档导航

公共 API 的参数、单位和边界约定写在源码的 `///` 注释中，可在 IDE 中查看，
也可通过 Dartdoc 生成可搜索的 HTML 文档。以下指南补充跨接口的使用约定：

| 需求 | 文档 |
| --- | --- |
| 从 JavaScript API 迁移 | [API 对照表](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/api-map.md) |
| 历史月名、归日与反查限制 | [历史历法](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/calendar-history.md) |
| 算术回历 | [回历转换](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/hijri-calendar.md) |
| 升落、极区状态与折射 | [可见性](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/visibility.md) |
| 合冲、留、大距与近远点 | [天象事件](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/sky-events.md) |
| 全球搜索与地方食况 | [日食](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/solar-eclipses.md)、[月食](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/lunar-eclipses.md) |
| 外部星表与恒星计算 | [恒星](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/fixed-stars.md) |
| 日月独立入口与 Web 体积 | [模块加载](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/module-loading.md) |
| 生成 API 文档与运行验证 | [文档与开发](#文档生成与开发验证) |

## 时间、单位与精度约定

- 星历输入为 **TT 儒略日**，默认 `Accuracy.accurate`。
- 输出为**几何 J2000 平黄道/平春分点**状态，不包含光行时、光行差等视位置修正。
- 行星与日心状态使用 AU、AU/day；地心月球使用 km、km/day。
- **位置默认 accurate，气朔默认 mid**，不共享全局可变默认状态。
- 位置三档主要控制级数前缀；气朔三档还改变模型及求解流程。`fast` 为固定阶段求解，`mid` 为专用事件模型，`accurate` 为完整视位置迭代。
- 气朔求解结果始终为天文时刻；年表中的 `assignedCivilDayNumber` 单独记录历法归日，历史模式不会修改求解结果。
- 气朔 `toleranceSeconds` 是数值收敛阈值，不是绝对天文精度；fast 不接受此参数。
- 均衡档默认十项月球黄纬预算，可设 `moonLatitudeTerms: 0..277` 或 `'full'`；快速档固定十项，精确档固定全量。
- 年份使用天文学编号（0 年为公元前 1 年）；民用日期在 1582-10-15 切换历法。
- `DateTime` 按时间戳作为瞬间导入，不按其年月日重新解释成历史历法。
- 与 JS lite 相同，UTC 标签近似视为 UT1；这不是完整的 UTC/TAI 闰秒模型。
- ΔT 的未来部分包含实验性拟合，移植一致性不等于未来真实地球自转精度。

## 使用示例

以下片段均使用主入口导入；各片段中的变量独立。

### 气朔与太阳时

```dart
final near = julianDay(year: 2026, month: 6, day: 21, hour: 12);
final solstice = solveSolarLongitude(
  1.5707963267948966, // 90°，弧度
  ut1ToTt(near),
  accuracy: Accuracy.accurate,
);
final local = solstice.toZonedTime(480);
final clock = trueSolarTime(solstice, 116.4074);
```

`SolarClock` 是虚拟太阳钟，不是携带时区的物理时刻；原始瞬间保留在 `clock.instant` 中。
底层 `solarLongitudeTimeFast/Accurate` 与 `lunarPhaseTimeFast/Accurate` 接受的是**展开角**，每加 2π 选择下一个周期；普通应用优先使用带 `nearJdTT` 的 `solve*` 接口。

### 气朔年表

```dart
final table = getQiShuoYear(2026,
  options: CalendarOptions(mode: CalendarMode.historical),
  lunarPhaseAnglesDeg: [0, 90, 180, 270],
);
for (final event in table.events) {
  print('${event.name}: ${event.localTime.toJson()}');
  print(event.assignedDate.toJson());
}
```

年表按固定时区的民用年筛选实际事件；历史指定日期可能和本地日期不同。
历史资料只用于节气和朔的归日，不用于其他月相或节气之间的候。
`includePentads: true` 可加入候；同时显示节气时不重复输出初候。
年表不等于农历月序；农历日期转换使用 `solarToLunar` / `lunarToSolar`。

### 农历转换

```dart
final lunar = solarToLunar(const CalendarDate(year: 2033, month: 12, day: 22));
print(lunar.toJson()); // 2033 年闰十一月初一
final solar = lunarToSolar(lunar);
print(solar.toJson());
```

**历史边界限制**：秦汉和 762 年改历的重复年份/月标，沿用上游首个匹配反查时存在歧义。
移植一致性不等于所有历史日期都能正确往返，详见 [历史历法说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/calendar-history.md)。

### 干支与纪年

```dart
final clock = ZonedTime(
  year: 2003, month: 3, day: 13, hour: 11, offsetMinutes: 480,
);
final pillars = fourPillarsForZonedTime(clock,
  options: CalendarOptions(mode: CalendarMode.chinaAstronomical),
  ratHourMode: RatHourMode.nextDay,
);
print(describeFourPillars(pillars));
final eras = getChineseEraNames(clock.toJulianTime().jdUT1);
```

四柱基础接口以立春换年、节换月，不提供春节换年开关；完整八字／紫微排盘由独立上层包提供。
`calculateFourPillars(jdUT1, virtualTime)` 的日时柱可使用另行求得的平太阳钟或真太阳钟，年、月边界仍比较实际 UT1 时刻。
子时默认 `nextDay`；`currentDay` 保持当天日柱与时干，`currentDayTomorrowStem` 保持当天日柱但取次日日干计算时干。
历史节气开关由 `PillarHistoricalMode` 控制，默认跟随历法模式；历史归日的柱界使用 UTC+8 当日零点。

`getChineseEraNames` 独立使用中国历史历法，不跟随 UI 时区。并存政权可返回多个候选，只有年份的资料保留 `EraPrecision.year`，不暗示精确改元日。
纪年查询依赖农历反查，继承前述历史边界限制；它不是史料真伪或争议裁决接口。

### 升落与中天

```dart
const observer = Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042);
final date = ZonedTime(year: 2026, month: 6, day: 21, offsetMinutes: 480);
final sun = solarRiseSetForDate(date, observer);
final moon = bodyRiseSetForDay(SkyBody.moon, date.toJulianTime().jdUT1, observer);
print(sun.rise?.toZonedTime(480).toJson());
print(moon.upperTransits);
```

通用接口的起点是 UT1 儒略日，返回该起点后一天内的全部事件；极昼／极夜不会填入虚构的升落时刻。
模型差异、时间窗口和地形等限制见 [可见性说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/visibility.md)。

### 月球照明与行星留

```dart
final start = JulianTime.fromUT1(julianDay(year: 2026, month: 1, day: 1));
final end = JulianTime.fromUT1(julianDay(year: 2027, month: 1, day: 1));
print(moonIllumination(start.jdTT).toJson());
final stations = searchStations(SkyBody.mercury, start.jdTT, end.jdTT);
```

事件区间使用 TT，合冲按黄经差定义；数值容差与实际模型精度不同。
参考系、逆行及圆面模型限制见 [天象事件说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/sky-events.md)。

### 近远点、大距与赤经事件

```dart
final startTT = JulianTime.fromUT1(julianDay(year: 2026, month: 1, day: 1)).jdTT;
final endTT = JulianTime.fromUT1(julianDay(year: 2027, month: 1, day: 1)).jdTT;
final apsides = searchLunarApsides(startTT, endTT);
final elongations = searchGreatestElongations(
  SkyBody.mercury, startTT, endTT,
  apparent: const ApparentOptions(accuracy: Accuracy.mid),
);
final conjunctions = searchRelativeRightAscension(
  SkyBody.moon, SkyBody.sun, 0, startTT, endTT,
);
```

近远点使用全量几何状态；视赤经与大距接口使用视位置选项。月球交点可选择参考黄道，详见 [天象事件说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/sky-events.md)。

### 月食

```dart
final start = ZonedTime(year: 2025, month: 1, day: 1, offsetMinutes: 480).toJulianTime();
final end = ZonedTime(year: 2026, month: 1, day: 1, offsetMinutes: 480).toJulianTime();
final eclipses = searchLunarEclipses(start, end);
final local = getLocalLunarEclipse(eclipses.first.maximum,
  const Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042));
print(local?.toJson());
```

日月食入口使用 `JulianTime`，避免裸数字的 TT/UT1 歧义；没有额外精度档位。范围、标准大气与圆面限制见 [月食说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/lunar-eclipses.md)。

### 日食与恒星

```dart
final day = ZonedTime(year: 2024, month: 4, day: 8, offsetMinutes: 0).toJulianTime();
final eclipse = getSolarEclipseDetails(day);
final local = getLocalSolarEclipse(day,
  const Observer(longitudeDeg: -96.8, latitudeDeg: 32.8));
print(eclipse?.toJson());
print(local?.toJson());

// catalogBytes 为读取 TSC1 文件得到的 Uint8List，支持完整表和 lite 表。
final catalog = parseTsc1Catalog(catalogBytes);
final star = fixedStarState(catalog, '角宿一', day.jdTT);
print(star.toJson());
```

恒星目录外置，底层无网络或文件系统依赖，不把测试用星表加入发布产物。Gaia ID 使用 BigInt，JSON 中转十进制字符串；缺测数值转 null。
详见 [日食说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/solar-eclipses.md) 与 [恒星说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/fixed-stars.md)。

算术回历正反转换、月长与闰年接口见 [算术回历说明](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/hijri-calendar.md)。示例：`dart run example/hijri_calendar.dart`。

## 日月独立入口

只用日月几何位置时，可导入 `package:ephemeris_lite/sun_moon.dart`。
原主入口保持兼容；气朔、太阳时已脱离其他行星目录，便于编译器按需裁剪。
拆分不减少系数、不改变精度，也不减少 pub 源码包总量。
详见[模块拆分与 Dart Web 实测](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/module-loading.md)。

## 文档生成与开发验证

Dart SDK 自带 `dart doc`，可直接从公共 API 注释生成 HTML 文档：

```sh
dart pub get
dart doc --validate-links
```

输出位于 `doc/api/index.html`。生成目录已加入 `.gitignore`，不提交生成的 HTML。
文档注释随包源码发布，pub.dev 也会据此生成 API 文档；仓库中的 `doc/*.md`
则用于说明模型、使用方式和适用范围。

```sh
dart analyze
dart test
dart run example/main.dart
```

测试覆盖 JS/Dart 数值对拍、时间尺度、历法边界、气朔、天象事件及非法输入。
跨运行时验证还包含 Dart 编译到 JavaScript 后的结果对照。
移植一致性测试不等于独立的 DE441 精度评估，也不构成未来 ΔT 精度保证。
系数和对拍数据的重建方式见[开发文档](https://github.com/RedSC1/ephemeris_lite/blob/main/doc/development.md)。

## 许可证与来源

本项目采用 [MPL-2.0](https://github.com/RedSC1/ephemeris_lite/blob/main/LICENSE)。数值模型与数据的来源、版权及许可证说明见
[中文第三方声明](https://github.com/RedSC1/ephemeris_lite/blob/main/THIRD_PARTY_NOTICES.zh-CN.md)和[英文第三方声明](https://github.com/RedSC1/ephemeris_lite/blob/main/THIRD_PARTY_NOTICES.md)。
