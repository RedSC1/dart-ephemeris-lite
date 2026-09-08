# ephemeris_lite

`js-ephemeris-lite` 的纯 Dart 移植，运行时不依赖 `sxwnl_spa_dart`、JavaScript 引擎或 FFI。
算法、系数和数值语义以 [JS 原库](https://github.com/RedSC1/js-ephemeris-lite) 为基准；API 使用 Dart 的命名参数、枚举和不可变结果。

**开发中，尚未完整移植，也未发布到 pub.dev。不能直接替换旧排盘底层。**
当前版本 `0.1.0-dev.1`，上游基准 `1.0.0-rc.1`；具体源码提交和数据哈希见 [tool/upstream.json](tool/upstream.json)。

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

**尚未实现**：按年组织的气朔表、节气/朔的历史归日、农历、纪年、干支、可见性、其他天象事件、日月食和恒星接口。完整清单见 [移植进度](docs/port-status.md)。

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
- 气朔结果为天文时刻；尚未移植的历史历法归日不能用这个结果直接冒充。
- 气朔 `toleranceSeconds` 是数值收敛阈值，不是绝对天文精度；fast 不接受此参数。
- 均衡档目前保留 JS 默认十项月球黄纬预算；通用求解器尚未开放自定义黄纬预算。
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

系数和对拍数据的重建说明见 [开发文档](docs/development.md)。

## 后续排盘包

计划继续保留 `bazi_core` 和 `ziwei_core` 的名字与独立发包方式，让它们平级依赖本包。
当前未修改或切换旧包依赖，也不承诺旧 `sxwnl_spa_dart` 类型兼容。

## 许可证与来源

本项目采用 MPL-2.0，移植自 RedSC1 的 `js-ephemeris-lite`。
上游数值模型和数据来源说明保留在 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) 与 [中文版](THIRD_PARTY_NOTICES.zh-CN.md)。
这两份文件保留 JS 上游完整声明，部分对应模块尚待移植；不表示本仓库已经实现其中全部功能。
