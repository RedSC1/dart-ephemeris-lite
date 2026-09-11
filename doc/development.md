# 开发与数据同步

[中文](development.md) | [English](development.en.md) · [文档首页](README.md)

## API 文档

公共接口使用 `///` Dartdoc 注释。修改接口时同步维护参数的时间尺度、角度／距离单位、
默认值、可空结果及边界限制；位置截断与气朔求解档位需分别说明。

在仓库根目录运行：

```sh
dart pub get
dart doc --validate-links
```

文档首页为 `doc/api/index.html`。该目录同时由 `.gitignore` 和 `.pubignore` 排除，
不提交或发布生成的 HTML；手写指南保留在 `doc/*.md`。
README 的仓库文件链接使用绝对 URL，以兼容 GitHub、pub.dev 与生成的 HTML。
链接校验检查生成文档的内部引用，不验证外部仓库访问权限。

中英文专题页使用相同的 `example/` 源码。中文页保留原名，英文页使用 `.en.md`；
修改示例时同步两页的代码块。API 生成器只更新两种语言的标记表格，不覆盖手写说明。

## 数据同步

本库正常使用及测试不需要 JS 仓库。只有重新生成系数和 JS 对拍数据时需要 Node.js 与上游 checkout。
在仓库根目录运行：

```sh
node tool/import_js_data.mjs ../taiyin-lite
node tool/generate_oracles.mjs ../taiyin-lite
node tool/generate_coordinate_oracles.mjs ../taiyin-lite
node tool/generate_fast_event_oracles.mjs ../taiyin-lite
node tool/generate_apparent_oracles.mjs ../taiyin-lite
node tool/generate_calendar_event_oracles.mjs ../taiyin-lite
node tool/generate_solar_time_oracles.mjs ../taiyin-lite
node tool/generate_historical_oracles.mjs ../taiyin-lite
node tool/generate_qi_shuo_oracles.mjs ../taiyin-lite
node tool/generate_lunar_oracles.mjs ../taiyin-lite
node tool/generate_ganzhi_oracles.mjs ../taiyin-lite
node tool/generate_era_oracles.mjs ../taiyin-lite
node tool/generate_visibility_oracles.mjs ../taiyin-lite
node tool/generate_visibility_portability.mjs
node tool/generate_phenomena_event_oracles.mjs ../taiyin-lite
node tool/generate_sky_event_portability.mjs
dart format tool/sky_event_portability_check.dart
dart format tool/visibility_portability_check.dart
node tool/generate_calendar_portability.mjs
dart format tool/calendar_portability_check.dart
dart format tool/lunar_check.dart
node tool/generate_portability_check.mjs
dart format tool/portability_check.dart
dart pub get
dart test
dart analyze
```

生成器必须针对同一个已提交的上游版本运行。`tool/upstream.json` 记录数据来源；提交生成数据、fixture 与该清单。
生成 Dart 常量使用原始 double 的可往返十进制形式，不调整频率、不重新拟合、不更改系数排序。
前缀计数也直接从上游导入，尤其保留地球独有的档位配额。

JS fixture 生成使用固定种子，测试不联网；没有使用 Dart 自己算出的值作为 JS 期望值。
目前容差：行星各坐标与速度 `1e-11 AU` / `1e-11 AU/day`；月球 `1e-6 km` / `1e-6 km/day`。
这是跨语言移植容差，不是模型相对观测或 DE441 的误差声明。

手写 Dart 文件使用 `dart format`。生成的系数文件不参与格式检查，避免格式化后制造无意义的大量 diff。
CI 运行静态分析、回归测试，并编译/执行纯 Dart 示例的 JavaScript 输出。

## 非目标

- 不通过 Dart FFI 调用 C++。
- 不嵌入 JS 引擎或依赖旧 Dart 底层。
- 不在移植时偷偷更换天文模型或历法策略。
- 不在本包中发布上层排盘规则。

## 新增模块的验证

- 65 个坐标历元覆盖 −6000～10000 年；矩阵与解析导数对拍，并测正交性及中心差分。
- 冥王星包含 1590/1600/2200/2210 年附近和过渡中点；保留近区推荐范围限制。
- 视位置对拍覆盖所有天体、三个参考系、三档位置精度及各修正开关。
- 气朔既测展开角入口，也测三档最近根和 safeguarded 路径；快速根没有容差参数。
- 太阳钟覆盖东西经端点、历史日期、UTC+8 和正反转换。
- `tool/portability_check.dart` 不依赖 dart:io，可在 VM 和编译 JS 后运行 45 组根对拍。

在第一轮 Dart 优化之前不作运行速度对齐承诺。尤其 mid 的部分 value-only 阶段暂时计算了额外导数；它没有替换成另一档模型。

## 历史归日与年表

- `tool/historical_check.dart` 对拍两个历史表全部 85,485 个事件序号的日期查询，Dart VM 和编译后的 JS 均要求整数日期完全相同。它是生成的测试数据，不进入库运行时。
- 位图排名采用显式 32 位操作，避免 Dart VM 和 JavaScript 整数乘法/截断差异；历史日期表由导入器生成，不手写修正。
- 年表对拍 10 组年份/选项、598 个事件，覆盖三档精度、历史改革年份、候、任意月相、负时区和经线归日。日期和分类必须精确一致，天文时刻的跨语言容差为 2 毫秒。
- 上述验证证明与 JS 上游一致，不代表对历史历法史料或天文观测的独立验证。

## 农历与节气查询

- 38 个窗口覆盖 −6000～9999 年、历史改革、三档精度及经线归日，逐项核对节气、朔、月序、闰标、月长、名称和两种年标。
- 846 组日期对拍包括月初和月末；33 组瞬时转换检查本地日界；72 个指定节气、24 个前后节气查询检查档位与精确边界语义。
- `tool/lunar_check.dart` 抽取 102 组普通月和特殊历史月，编译成 JS 后仍执行正反转换对拍。
- 已知历史反查歧义单独计数并保留预期行为，详见 calendar-history.md；没有放宽整数日期、月名或闰标断言。

## 干支和纪年

- 426 个四柱结果对拍覆盖历史年份、三档气朔、三种子时规则，以及实际节气时刻／历史归日边界前后。
- 76 个钟面规范化结果包含全天整点的 JD 往返、前后 1 毫秒及真实小数秒；另有 6 个平太阳钟／真太阳钟边界四柱对拍。
- 173 个纪年查询核对候选、文本、年次、区间、精度和来源，其中一个上游历史反查错误作为已知限制保留；不是 173 个全部可返回纪年结果的样本。
- `tool/calendar_portability_check.dart` 在编译 JS 后核对 33 个四柱、76 个钟面和 14 个纪年查询。
- 纪年源数据包含 529 条主记录与 223 条补充记录，由导入器生成强类型 Dart 表；数值和文字来源、许可证沿用第三方说明，数据哈希记录于 upstream.json。
- 纪年年初日期只做单次查询内的缓存，不引入全局精度状态或无界年份缓存。当前优先验证语义，未承诺与 JS 一样的查询速度。

## 地平坐标和升落

- JS 对拍包括 540 组地平坐标（10 个天体、三档位置精度、6 个站点及3个季节）、75 组快速太阳样本／升落、61 组全天升落中天，以及 33 个折射值。
- 日出日落的跨语言时间差阈值为 0.02 秒；状态与事件数必须完全一致。地平角度容差为 1e-8 度，太阳专用高度角容差为 1e-10 弧度；不代表地形／气象条件下的实际观测误差。
- 另测半开区间、连续零采样拒绝、周期反向点过滤、折射截断伪根，以及同一十分钟步长内的擦边双根。
- 编译成 JS 后对拍 10 个通用全天窗口与 9 个太阳窗口，其中包含极区、擦边和长年代样本。
- 太阳内部公共求值被复用但不从包入口导出，太阳钟回归仍随全套测试运行。两条太阳链按上游保持差异，不宣称与 C++ 独立精度相同。

## 光照相位与行星黄经事件

- 474 个天体物理量与 45 个月球盈亏结果对拍，覆盖全部天体、三种参考系、三档精度，以及光行时／光行差／偏折组合。
- 20 个事件搜索区间，共 106 个结果；包含水星三档留与入宫、2025 年真实逆行跨宫、金星／火星／木星留、月日相对黄经和空区间。
- 事件时间跨语言阈值为 0.1 秒，方向、分界和事件数要求一致；留后方向另由后一时刻的速度核验。照明比例容差 1e-12，圆面／相位角量容差 1e-7（输出单位）。
- 编译 JS 后再测 7 个搜索区间和 9 个月相样本。所有视位置、气朔、可见性旧回归继续运行，避免共享几何重构改变其他接口。
- 此处仍是对 JS 的移植验证，不是新增的 DE441 精度评价或观测对照。

## 轨道与赤经事件

重新生成：`node tool/generate_orbital_oracles.mjs /path/to/js-source`，随后格式化生成的 `tool/orbital_portability_check.dart`。

- 52 个搜索区间，226 个事件，包含 −1000、2000、2026、5000 年的几何事件，以及三种参考系、三档精度的视事件。
- JS 对拍核对事件数、类别、方向、距离、角度和 TT/UT1；时间容差 0.1 秒，角度 1e-5 度，距离 0.001 km / 1e-10 AU，速度 1e-6 度/日。这些是跨运行时容差，不是天文精度承诺。
- 另测几何距离极值、三维大距极值、交点平面、留后方向、非法参数和不可变序列。
- Dart 编译成 JS 后对拍 11 个搜索区间；仍不是独立 DE441 验证。

## 月食

- `node tool/generate_lunar_eclipse_oracles.mjs /path/to/js-source` 生成 30 个查询：9 个年份（−1000～5000）的 20 次全球月食、5 次单望查询及 16 次地方查询。
- 覆盖全食、偏食、半影食、无食、不可见、月出／月落截断。接触顺序、半开区间、不可变结果和参数检查另有测试。
- JS 对拍时间阈值 0.05 秒，地方角度 1e-4 度，食分等量 1e-7；这些是跨语言容差，不是模型观测精度。编译成 JS 后另测 9 个查询。
- 生成后对 `tool/lunar_eclipse_portability_check.dart` 运行 `dart format`。

## 完整公共功能与最后一轮验证

- `generate_remaining_oracles.mjs`：312 组恒星 ICRF/视状态（三种坐标系与修正开关）、21 个日食查询（9 个年份共 20 次全球食及地方案例），复制完整 TSC1 测试表和数据声明。
- 日食事件时刻跨语言容差 0.1 秒、接触点／最大食地点 0.002 度、带宽 0.02 km；类目与可见性必须一致。局部极值优化的地点对浮点路径敏感，角度阈值不是地理预测精度承诺。
- 恒星位置采用绝对加相对舍入容差；远距离坐标的差分速度容差 1e-3 AU/day，角速度 1e-7 度/day。它们不是恒星模型误差界。
- `generate_budget_oracles.mjs`：100 个自定义预算案例，覆盖 0/10/30/277/full、两个均衡求根器和三档位置精度。
- `generate_api_metadata.mjs`：生成公共元数据、公共导出编译清单与 API 对照文档。每次生成后运行 Dart format。
- `tool/remaining_portability_check.dart` 编译到 JS 后重新核对恒星及日食。64 位哈希和 Gaia ID 不经过 double。
- `.pubignore` 排除测试、星表、工具与本地计划，运行库不含外置星表。发布前运行 `dart pub publish --dry-run`；底层发布与上层包的迁移、发布分别处理。

Pub 打包遵循 `doc/` 单数目录约定。源哈希同步保存在 `doc/upstream.json`，运行包保留来源追踪，开发工具不随包分发。
