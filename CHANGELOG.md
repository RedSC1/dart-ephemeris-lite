## 0.1.0-dev.1 (unpublished)

- Start the pure Dart port from js-ephemeris-lite 1.0.0-rc.1.
- Port astronomical time, Delta-T, fixed-offset civil time, and geometric
  Mercury-through-Neptune/Moon states with three position-accuracy tiers.
- Add reproducible coefficient import, 1107 JS state oracles, boundary tests,
  development documentation and CI.
- Add precession/nutation matrices and rates, Pluto near/fallback models,
  apparent positions and finite-difference rates, three event-solving tiers,
  equation of time and solar-clock conversions.
- Add JS oracles and a dart2js numerical portability check.
- Chinese calendar, annual event tables and the remaining sky APIs are not yet ported.

- 移植历史气朔归日及民用年气朔表；全量历史日期对拍和年表回归加入测试。农历月序与干支仍待移植。

- 移植农历窗口、月序与特殊月名、农历正反转换和节气查询；记录并回归验证上游历史反查边界限制。

- 移植干支／四柱基础算法、子时和历史节气选项、精确整点规范化，以及中文纪年数据与来源边界查询。

- 移植折射、太阳快速升落、通用地平坐标与全天升落／中天，以及标量／角度变号根搜索；新增极区、擦边与跨运行时回归。
