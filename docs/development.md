# 开发与数据同步

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
- 不在新底层尚不可用时修改旧排盘包。

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
