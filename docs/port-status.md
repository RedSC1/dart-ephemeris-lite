# 移植进度

## 已有可运行实现

| JS 模块 | Dart 状态 |
| --- | --- |
| accuracy.js | `Accuracy` 枚举，默认 accurate，无全局可变默认值 |
| time.js | 时间/历法转换、ΔT、JulianTime、ZonedTime；Dart 命名参数和 DateTime 接口 |
| direct-planet-model.js / planet-models.js / planet-frame.js | 八颗行星的 monomial 求值、三档前缀与固定旋转；未暴露内部任意项数接口 |
| moon-model.js | 全量与两档前缀、地心状态/方向、原生黄经；未暴露内部任意项数接口 |
| ephemeris.js / pluto-model.js | 通用几何状态、冥王星近/远模型及过渡；部分逐天体便捷别名尚未移植 |
| coordinates.js / nutation-series.js | 岁差、章动、日期矩阵、ICRF→J2000及解析导数 |
| apparent.js | 三种参考系及修正开关、完整链路差分速度及只读 apparentGeometry 中间几何 |
| calendar-events.js / event-*.js | 三档最近气朔求解、快速/精确展开角入口、均衡状态与估计器；自定义求解黄纬预算尚未开放 |
| chinese-calendar.js | 历史归日、月序、特殊月名、正反转换、前后节气与指定节气；历史反查限制见 calendar-history.md |
| ganzhi.js | 干支编码、纳音、四柱、整点规范化、三种子时规则及历史节气开关 |
| chinese-era.js / generated/chinese-era-data.js | 752 条源记录、纪年候选与边界来源／精度；继承农历反查的已知限制 |
| qi-shuo.js | 年度节气、候和任意月相；实际时刻与历史指定日期分开保存，结果序列不可变 |
| solar-visibility.js / body-visibility.js | 太阳快速升落、地平坐标、全天升落／中天、折射与极区状态；详细限制见 visibility.md |
| event-search.js | 标量／角度根搜索、黄经穿越、相对黄经、留与顺逆行入宫 |
| phenomena.js | 相位角、照明比例、月球盈亏、视直径及地平视差 |
| solar-core.js / solar-time.js | 太阳钟、均时差、恒星时及正反转换 |

生成数据与手写求值器分离。初期优先确认算法一致性，尚未进行 Dart 专项速度或内存优化。
月球相位缓存采用每次求值局部存储，避免引入全局可变配置；后续需测量分配成本。

## 接下来按依赖顺序移植

1. 明确历史改历的重复年份/月标消歧方案；现有正反转换已移植，上游的边界限制见 [历史历法说明](calendar-history.md)。
2. 审计排盘接入所需的历法选项与序列化（干支和纪年基础接口已移植）。
3. orbital-events（大距、近远点、交点及赤经事件）、日月食和恒星接口。
4. 对齐公共 API 清单，补剩余选项/别名/序列化。
5. Dart 专项性能与内存基准、打包审计；目前均衡气朔的部分仅需数值的步骤复用了解析状态求值器，结果对齐但尚未达到 JS 的 value-only 工作量。
6. 再迁移独立的 bazi_core、ziwei_core，补旧数据迁移说明。

## 对外发布门槛

- 不用占位算法代替未移植模块；未实现接口不导出。
- 生成器记录上游提交与源数据哈希，不提交绝对本地路径。
- JS/Dart 对拍与独立天文精度验证分开表述。
- 精度容差有单位；不得靠无解释放宽容差消除回归。
- `publish_to: none` 在完整审计前保留，不自动发 pub.dev。
