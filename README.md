# ephemeris_lite

`js-ephemeris-lite` 的纯 Dart 移植，运行时不依赖 `sxwnl_spa_dart`、JavaScript 引擎或 FFI。
算法、系数和数值语义以 [JS 原库](https://github.com/RedSC1/js-ephemeris-lite) 为基准；API 使用 Dart 的命名参数、枚举和不可变结果。

**JS 1.0.0-rc.1 主包的公共功能已完成 Dart 移植。仍为私有开发版，未发布到 pub.dev；旧排盘包接入需另做迁移验证。**
当前版本 `0.1.0-dev.1`，上游基准 `1.0.0-rc.1`；具体源码提交和数据哈希见 [doc/upstream.json](doc/upstream.json)。

## 已实现

- 儒略日、历史儒略历/格里高利历转换、天文学纪年、固定时区。
- 与 JS 一致的 ΔT、UT1/TT 转换、`JulianTime` 和 `ZonedTime`。
- 水星至海王星的几何位置和解析速度，`fast` / `mid` / `accurate` 三档系数截断。
- 月球 ELP 系数求值、解析速度、三档截断和 J2000 坐标转换。
- 地心行星、地心太阳、日心月球及地月质心的几何状态。
- 冥王星近区模型、粗略远区模型及平滑过渡；推荐精度区间仍为 1600～2200。
- IAU2000B 章动、Vondrák2011 岁差、J2000/日期坐标矩阵及解析导数。
- 三种参考系的视位置、光行时、相对论光行差与太阳引力偏折，以及完整链路差分速度。
- `solveSolarLongitude` / `solveLunarPhase` / `solveNewMoon` 的 fast、mid、accurate 三档；快速与精确档的展开角入口。
- 平太阳时、真太阳时、均时差、恒星时及太阳钟反算。
- 历史气朔归日表；固定时区或经线归日选项。
- 农历月序、特殊历史月名、正反转换、前后节气与指定节气查询。
- 干支编码、纳音五行、四柱基础计算、三种子时规则和历史节气边界开关。
- 中文纪年候选查询，保留来源、有效区间及日／年级精度。
- 太阳快速升落、通用天体地平坐标与全天升落／上下中天，支持极区状态及折射选项。
- 天体相位角、月球照明与盈亏、视圆面；黄经穿越、相对黄经、留和顺逆行入宫查询。
- 按民用年列出的节气、候与月相，分别保留天文时刻、本地日期和历法指定日期。

- 月地近远点、月球交点、水金大距、相对赤经与赤经留。

- 全球月食搜索、接触时刻和地方可见性（含月出／月落截断）。

- 全球与地方日食、中心线接触地点、最大食地点、带宽与中心食持续时间（不含地图渲染）。
- TSC1 恒星表解析与别名查找、自行／视差／径向速度、三种参考系视位置和完整链路速度。

完整清单见 [移植状态](doc/port-status.md)，200 个 JS 公共导出的对应关系见 [API 对照表](doc/api-map.md)。

## 开发阶段使用

在同级工程中用路径依赖；不要将下面写成 pub.dev 安装指令：

```yaml
dependencies:
  ephemeris_lite:
    path: ../ephemeris_lite
```

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

### 计算约定

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

## 气朔与太阳时

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

## 验证

```sh
dart pub get
dart analyze
dart test
dart run example/main.dart
dart compile js example/main.dart -o /tmp/ephemeris-demo.js
node /tmp/ephemeris-demo.js
```

回归数据包含 1107 组 JS 位置/速度结果：41 个历元 × 3 档 × 9 个天体，含固定端点和固定种子的宽年代样本。
另测 ΔT 分段接缝、历法切换、时间尺度、非法日期、时区和输出不可变性。
新增 65 个历元的坐标矩阵/导数、39 组冥王星边界状态、564 组视位置、392 个快速根、112 个精确根、224 组最近气朔查询及 120 组太阳时样本。
另有 45 组气朔根在 Dart 编译到 JS 后实际计算验证。
这些测试证明**移植与 JS 的一致性**，不是新的独立 DE441 精度评估。

系数和对拍数据的重建说明见 [开发文档](doc/development.md)。

## 后续排盘包

计划继续保留 `bazi_core` 和 `ziwei_core` 的名字与独立发包方式，让它们平级依赖本包。
当前未修改或切换旧包依赖，也不承诺旧 `sxwnl_spa_dart` 类型兼容。

## 许可证与来源

本项目采用 MPL-2.0，移植自 RedSC1 的 `js-ephemeris-lite`。
上游数值模型和数据来源说明保留在 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) 与 [中文版](THIRD_PARTY_NOTICES.zh-CN.md)。
这两份文件保留 JS 上游来源说明，并注明 Dart 移植范围。黄历兄弟包不在此包中；恒星表测试夹具单独保留数据来源声明。

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
移植一致性不等于所有历史日期都能正确往返，详见 [历史历法说明](doc/calendar-history.md)。
旧排盘包暂不切换底层。

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

四柱基础接口以立春换年、节换月，不提供春节换年开关；完整八字／紫微排盘属于后续独立包。
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
模型差异、时间窗口和地形等限制见 [可见性说明](doc/visibility.md)。

### 月球照明与行星留

```dart
final start = JulianTime.fromUT1(julianDay(year: 2026, month: 1, day: 1));
final end = JulianTime.fromUT1(julianDay(year: 2027, month: 1, day: 1));
print(moonIllumination(start.jdTT).toJson());
final stations = searchStations(SkyBody.mercury, start.jdTT, end.jdTT);
```

事件区间使用 TT，合冲按黄经差定义；数值容差与实际模型精度不同。
参考系、逆行及圆面模型限制见 [天象事件说明](doc/sky-events.md)。

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

近远点使用全量几何状态；视赤经与大距接口使用视位置选项。月球交点可选择参考黄道，详见 [天象事件说明](doc/sky-events.md)。

### 月食

```dart
final start = ZonedTime(year: 2025, month: 1, day: 1, offsetMinutes: 480).toJulianTime();
final end = ZonedTime(year: 2026, month: 1, day: 1, offsetMinutes: 480).toJulianTime();
final eclipses = searchLunarEclipses(start, end);
final local = getLocalLunarEclipse(eclipses.first.maximum,
  const Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042));
print(local?.toJson());
```

日月食入口使用 `JulianTime`，避免裸数字的 TT/UT1 歧义；没有额外精度档位。范围、标准大气与圆面限制见 [月食说明](doc/lunar-eclipses.md)。

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
详见 [日食说明](doc/solar-eclipses.md) 与 [恒星说明](doc/fixed-stars.md)。

算术回历正反转换、月长与闰年接口见 [算术回历说明](doc/hijri-calendar.md)。示例：`dart run example/hijri_calendar.dart`。
