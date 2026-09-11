# 测试迁移与覆盖审计

[中文](test-migration.md) | [English](test-migration.en.md) · [文档首页](README.md)

本页记录 JS 主包、旧纯 Dart 库和旧 Dart FFI 封装的测试。测试场景按新 API 合并，
不保留旧 API 名称、全局状态或 FFI 初始化代码。**公共 API 已移植，不等于旧测试逐条原样通过。**

源版本、文件 SHA-256 和原测试标题清单见 [`tool/test-sources.json`](../tool/test-sources.json)。
该清单是源测试清单，不是“每一条断言均已迁移”的证明。生成数据与独立参考值分开保存。

## 历史审计基线（2026-09-08）

- Dart VM：115 项通过，1 项明确跳过（下述 PMO 食带宽差异）；原有 68 项基础上补入回归场景。
- 静态分析无问题；10 组编译后 JavaScript 回归实际执行通过。
- 手写运行代码行覆盖率：3578 / 3739，约 95.7%，不含生成系数文件。
- JS 源库基线：160 项通过；不同语言测试按场景合并，不能直接比较用例数量。

## 验证层次

1. 原有 JS/Dart 对拍：检查移植一致性，不能独立证明天文精度。
2. `test/fixtures/upstream/` 的 Python、C++、DE441、SOFA 参考：保留上游来源说明和原测试容差。
   Python 对同一系数表的独立求值与 DE441 星历控制值也分别断言。
3. 旧 Dart 的 PMO 年历、日月食资料以及历法、时间边界：适配新接口，保留独立预期。
4. 结构与物理性质：系数前缀、项数、完整频率包络、解析导数、参考系、区间边界及不可变结果。
5. 编译到 JavaScript 后实际执行的跨平台回归：不能用“编译成功”替代运行验证。

覆盖率只统计已执行的 Dart 源码行，不能代表测试场景完整性或科学精度。

## JS 主包对应关系

| 源测试 | Dart 覆盖位置与重点 |
| --- | --- |
| `ephemeris.test.js` | `port_test.dart`、`api_completion_test.dart`、`upstream_reference_test.dart`、`upstream_model_contract_test.dart`：全量/三档状态、独立模型控制、原分段接点导数、VSOP87 控制点、项数及前缀 |
| `apparent.test.js` | `apparent_test.dart`、`upstream_physics_test.dart`、`upstream_reference_test.dart`：三参考系、物理开关、光行时、完整速度、81 个 C++ 控制 |
| `calendar-events.test.js` | `calendar_events_test.dart`、`fast_events_test.dart`、`accurate_events_test.dart`、`api_completion_test.dart`、`upstream_calendar_test.dart`、`upstream_physics_test.dart`：三档根、周期选择、黄纬预算、导数、2026 DE441/PMO、夏至秒数 |
| `chinese-calendar.test.js` | `chinese_calendar_test.dart`、`historical_calendar_test.dart`、`legacy_dart_test.dart`：历史归日、特殊月名、2033、反查、时区、子午线、精确交节边界 |
| `chinese-era.test.js` | `chinese_era_test.dart`：纪年并存、朝代/皇帝标签、精确切换时刻及来源精度 |
| `eclipses.test.js` | `upstream_eclipse_test.dart`、`remaining_test.dart`：擦边、非中心、三种中心食、地方可见性、直接几何接触时刻 |
| `eclipse-search.test.js` | `lunar_eclipses_test.dart`、`remaining_test.dart`、`upstream_eclipse_test.dart`：全球枚举、半开边界、地方可见性、空结果、非法请求 |
| `event-search.test.js` | `event_search_test.dart`、`upstream_reference_test.dart`：标量/角度根、反向入宫、留、完整独立事件枚举 |
| `fixed-stars.test.js` | `remaining_test.dart`、`upstream_coordinates_stars_test.dart`：TSC1、别名、偏移视图、损坏文件、独立 C++ 自行与速度 |
| `ganzhi.test.js` | `ganzhi_test.dart`、`legacy_dart_test.dart`：六十甲子、纳音、四柱、交节、整点及三种子时规则 |
| `orbital-events.test.js` | `orbital_events_test.dart`、`upstream_reference_test.dart`：297 个独立 C++ 事件、径向速度根、交点、大距和赤经留 |
| `qi-shuo.test.js` | `qi_shuo_test.dart`、`legacy_dart_test.dart`：全年表、任意月相、候、时区与历史归日，2026 四相/八相计数 |
| `sky-observation.test.js` | `phenomena_test.dart`、`visibility_test.dart`、`upstream_reference_test.dart`：45 个独立物理三角形、地平坐标、升落和中天 |
| `solar-time.test.js` | `solar_time_test.dart`、`ganzhi_test.dart`、`upstream_physics_test.dart`：C++/Swiss 均时差、太阳钟、跨日和四柱 |
| `solar-visibility.test.js` | `visibility_test.dart`、`upstream_physics_test.dart`：独立 Denver 升落控制、视圆边缘、折射、极区和长年代 |
| `time.test.js` | `port_test.dart`、`upstream_model_contract_test.dart`、`legacy_dart_test.dart`：ΔT、接点一阶连续、TT/UT1、日期及显式时区 |

JS 内部实现断言不能全部机械复制：Dart 均衡路径的部分只求值实现复用状态求值器；
因此相应检查使用公共状态、解析导数和最终事件根，而不要求相同缓存、数组布局或函数身份。
日月食私有插值器的逐步方程残差未直接暴露给测试；接触时刻以 JS **直接三维几何解**冻结数据复核，
太阳原容差 0.1 秒、月球原容差 0.03 秒。这组数据不是独立 DE441 星历。

JS 的非法字符串枚举、缺失必填属性等测试，在 Dart 中有一部分被静态类型系统替代。
`tool/api_surface_check.dart` 与跨平台运行脚本检查公开入口，不新增已删除的旧接口。

## 旧 Dart 场景

### `sxwnl_spa_dart`

- `astro_date_time_precision_test.dart`：保留亚毫秒时间、UTC 往返和显式时区场景。
  发现并修复 `DateTime` 仅按毫秒转换造成的截断；现代双精度 JD 约 40 微秒一格，
  测试以 25 微秒往返误差界限检查，**不承诺纳秒/任意年代微秒无损**。
- `moon_phase_search_test.dart`：2026 年四主相 50 次、八相 99 次、逐相计数与时间顺序。
  新库没有旧 `getDayRange`/每日查相包装器，以年度查询及半开搜索接口覆盖底层行为。
- `test_astronomical_yearing.dart`：公元前 −456 年、跨年十一/十二月、−100 年月序、
  新莽/景初/武周改历期往返；旧日期字符串格式与拼音解析不是新库接口。
- `test_v15_edge_cases.dart`：交节瞬间前包含/后排除、J2000、负年份槽位、前后闭环、节/气过滤。
- `test_historical_solar_terms.dart`：1645–1700 年历史指定日期可不同，但实际天文时刻不随模式改变。
- `pmo_2026_year_oracle_test.dart`：24 节气分钟表、2026 农历月大小，并用 JS 原始 DE441 秒级控制补强。
- `test_calendar.dart`/`test_models.dart`：干支编码、循环、四柱整点与子时、历法转换的共同场景。
  旧 `DayInfo`、列表便利包装器、字符串/拼音枚举、旧类运算符和默认地点不移植。
- `eclipse_test.dart`：保留独立 PMO 日月食控制；现代 API 的分类、地方接触与可见性由上述新测试覆盖。
  `ysPL/ecFast/msc/rsGS/rsPL/jieX`、原始数组布局、NASA 半径开关、边界画线已按产品范围删除，
  不恢复这些 API，也不要求新模型复现旧求值器每个末位。
- `stars_test.dart`：不移植旧 `ephB/hxCalc/xingX` 文本表/格式器；新 TSC1 星表用独立 C++ 传播控制测试。
- `compare_*`、`test_jie_qi_2025.dart`、`test_jie_qi_direct.dart`、`debug_1645_jq.dart`、
  `test_historical_toggle.dart` 等大量文件是打印式诊断，不计为现成自动断言；
  对应时区、历史切换、气朔、升落场景改由上述自动测试验证，不搬硬编码本地路径。
- 后续已补入 `test_hui_li_date.dart` 的回历场景，详见 `hijri_calendar_test.dart`；
  `testB2000.dart` 的旧岁差实现仍不属于本库；
  新章动/岁差采用独立 C++/SOFA 控制，不为了过旧算法测试退回旧模型。

### `taiyin-dart/packages/ephemeris`

- 时间、儒略日、干支、农历、太阳钟、位置、物理量、升落、轨道事件、日月食、恒星的共同数值行为，
  由上述 Dart 测试及 C++ 冻结控制覆盖；`ported/time_angle_interpolation_test.dart` 的三个儒略日控制已直接迁入。
- `runtime_api/context_api/context_lifecycle/module_concurrency/native_compatibility/optional_module_lookup/call_result`：
  测试对象是动态库加载、句柄、错误码、上下文、生命周期和原生线程，不适用于无 FFI 的本库。
- `time_api/time_test/date_time_extension` 中的分裂 JD 纳秒、TAI/UTC 闰秒、TDB、EOP 表并非 lite 功能；
  不用单个 `double` JD 伪装原生分裂时间精度。
- `heliacal_api/occultation_api/astrology_api`、Kaguya 月缘、任意 SPK/OPM2 数据源路由及原生选项不属于本库。
- 旧 `ziwei_core/bazi_core` 和 JS 独立黄历/紫微/八字包的规则测试属于各自包；此轮不把它们塞进星历底层。

## 尚未解决的独立资料差异

`upstream_eclipse_test.dart` 保留 **2026-08-12 日食带宽**的旧 PMO 断言：
参考 `300.3 km`，原容差 `5 km`；当前 JS 与 Dart 都得到 `285.2210251089675 km`。
接触时刻（2 秒）、中心经纬度、食分和持续时间通过原控制。

JS 实现注释将其定义为垂直地面轨迹的瞬时截面宽度；是否与该资料采用的食带宽定义一致，
仍须核实。不能在未核实时称其为“资料错误”或“已证实仅是定义差异”。
该**单项**以明确原因标记跳过，不修改参考值/容差，不计为已通过。可单独复现失败：

```sh
EPHEMERIS_CHECK_PMO_WIDTH=1 dart test test/upstream_eclipse_test.dart --name 'known discrepancy'
```

既有历史农历反查歧义仍见 [calendar-history.md](calendar-history.md)，本轮未把继承的限制改成新标准。

## 运行

```sh
dart analyze
dart test
dart test --coverage=/tmp/ephemeris-coverage
dart compile js tool/test_regression_portability_check.dart -o /tmp/regressions.js
node /tmp/regressions.js
```

测试、冻结星表与生成工具通过 `.pubignore` 排除，不增加发布包的运行时数据或依赖。

后续算术回历测试单独增加了共享冻结样本、五个完整周期的逐日兼容/反向转换检查和 Web 编译运行；上面的运行统计是迁移审计当时的基线。

覆盖率命令输出原始数据；转为 LCOV 需另行安装可选的 `coverage` 开发工具，它不属于运行时依赖。
