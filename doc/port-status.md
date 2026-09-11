# 功能范围与兼容性

[中文](port-status.md) | [English](port-status.en.md) · [文档首页](README.md)

已完成 JS 1.0.0-rc.1 主包公共功能移植，并同步增加了算术回历接口与后续日月依赖拆分。根入口 202 个导出均有 Dart 对应，编译清单为 `tool/api_surface_check.dart`；Dart 调用形式见 [API 对照表](api-map.md)。

## 已有可运行实现

| JS 模块 | Dart 状态 |
| --- | --- |
| accuracy.js | `Accuracy` 枚举，默认 accurate，无全局可变默认值 |
| hijri-calendar.js | 算术回历正反转换、显式时区归日、月长与闰年规则 |
| time.js | 时间/历法转换、ΔT、JulianTime、ZonedTime；Dart 命名参数和 DateTime 接口 |
| direct-planet-model.js / planet-models.js / planet-frame.js | 八颗行星的 monomial 求值、三档前缀与固定旋转；未暴露内部任意项数接口 |
| moon-model.js | 全量与两档前缀、地心状态/方向、原生黄经；未暴露内部任意项数接口 |
| ephemeris.js / pluto-model.js | 通用几何状态、冥王星近/远模型及过渡，包含逐天体便捷别名 |
| coordinates.js / nutation-series.js | 岁差、章动、日期矩阵、ICRF→J2000及解析导数 |
| apparent.js | 三种参考系及修正开关、完整链路差分速度及只读 apparentGeometry 中间几何 |
| calendar-events.js / event-*.js | 三档最近气朔求解、快速/精确展开角入口、均衡状态与估计器；包含 mid 自定义黄纬预算及档位约束 |
| chinese-calendar.js | 历史归日、月序、特殊月名、正反转换、前后节气与指定节气；历史反查限制见 calendar-history.md |
| ganzhi.js | 干支编码、纳音、四柱、整点规范化、三种子时规则及历史节气开关 |
| chinese-era.js / generated/chinese-era-data.js | 752 条源记录、纪年候选与边界来源／精度；继承农历反查的已知限制 |
| qi-shuo.js | 年度节气、候和任意月相；实际时刻与历史指定日期分开保存，结果序列不可变 |
| solar-visibility.js / body-visibility.js | 太阳快速升落、地平坐标、全天升落／中天、折射与极区状态；详细限制见 visibility.md |
| event-search.js | 标量／角度根搜索、黄经穿越、相对黄经、留与顺逆行入宫 |
| eclipse-lunar.js / eclipse-search.js | 月食全球搜索、食甚与接触时刻、地方可见性 |
| eclipse-solar.js / eclipse-cone.js / eclipse-geometry.js | 全球与地方日食、WGS84 影锥、接触地点、带宽和持续时间；无地图渲染 |
| fixed-stars.js | TSC1 v1 解析、64 位标识、别名、自行／视差／径向速度与视位置速度 |
| orbital-events.js | 月地近远点、月球交点、水金大距、相对赤经与赤经留 |
| phenomena.js | 相位角、照明比例、月球盈亏、视直径及地平视差 |
| solar-core.js / solar-time.js | 太阳钟、均时差、恒星时及正反转换 |

生成数据与手写求值器分离。初期优先确认算法一致性，尚未进行 Dart 专项速度或内存优化。
月球相位缓存采用每次求值局部存储，避免引入全局可变配置；后续需测量分配成本。

## 移植完成后的独立工作

- 上游历史改革窗口的反查歧义仍保留，见 [历史历法说明](calendar-history.md)。修正这些上游行为不属于逐行为移植。
- 新版 bazi_core、ziwei_core 已完成底层接入回归；它们保持独立发布，天文内核已发布测试版，上层分别固定依赖。旧版应用与旧数据迁移仍需单独验证。
- Dart 专项性能与内存优化、正式发布审查另行安排；均衡气朔部分 value-only 步骤复用解析状态求值器，数值对齐，但计算工作量并非与 JS 完全相同。
- 不移植 JS 的内部废弃算法、地图渲染器、构建实验脚本，也不将外置星表绑定进底层运行库。

## 对外发布门槛

- 不用占位算法代替未移植模块；未实现接口不导出。
- 生成器记录上游提交与源数据哈希，不提交绝对本地路径。
- JS/Dart 对拍与独立天文精度验证分开表述。
- 精度容差有单位；不得靠无解释放宽容差消除回归。
- 当前基线为 `1.0.0-beta.1`；后续发布须通过发布内容审查、静态检查、测试与 `dart pub publish --dry-run`；发布不代表所有已知精度限制已消除。

## 测试审计

测试来源、共同场景与未适用的旧接口见 [测试迁移说明](test-migration.md)。
包括独立 DE441/C++/SOFA 控制与旧 Dart PMO 数据，不再仅依赖 JS 输出对拍。
2026 日食带宽存在一项 JS/Dart 共有、尚待核实的独立资料差异，不能计作已通过。
