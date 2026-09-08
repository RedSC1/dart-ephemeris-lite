# 月食

## 接口与时间

- `getLunarEclipseDetails(JulianTime date)` 返回日期附近对应望的月食，若该望没有月食则返回 null；不是搜索最近一次月食。
- `searchLunarEclipses(JulianTime start, JulianTime end)` 按食甚筛选半开区间 `[start,end)`，结束必须晚于开始。一次最多 5000 个朔望月（包含内部余量），更长范围需拆分。
- `getLocalLunarEclipse(JulianTime date, Observer location)` 返回全球月食、各接触时刻的方位／高度／可见性，以及食期间的月出月落。

Dart 入口显式接受 `JulianTime`；UT1 数字用 `JulianTime.fromUT1()`，TT 数字用 `JulianTime.fromTT()`，`ZonedTime` 用 `.toJulianTime()`。这与 JS 接受多种日期对象的入口形式不同，求解语义一致。
结果对象、接触映射与事件列表不可变，提供 `toJson()`；不存在的偏食／全食阶段为 null，不是虚构的零时刻。

## 算法

使用完整视位置链（日期真赤道、关闭太阳引力偏折），三维 Chauvenet 地影模型和圆形月面。现代节点过滤仅在朔望月序号绝对值不超过 2500 时使用；范围外不做该过滤，并以精确月相求解定位望。
食甚迭代后，在前后 0.25 天窗口采样，三次拟合影心相对坐标及影半径，求各接触时刻；拟合函数不能夹住根时回退到直接几何求根。没有运行时全局配置，也不额外添加 fast/mid/accurate 参数。

## 地方可见性

与 JS 一致，地方食只采用经度、纬度和海拔，使用标准大气 1013.25 mbar / 15°C；传入 Observer 的自定义气象字段不参与本接口。接触点以月心视高度大于 0 判可见，月出月落使用上边缘。`visible` 表示存在可见部分，不代表全过程可见；除接触点外，按十分钟步长检查食期间的可见性。
`horizonClipped` 可为 moonrise、moonset、both 或 null；各接触的几何时刻仍保留，并标记其可见性，不因在地平线下而删掉全球接触数据。

模型不包含当地地形、月缘山谷或实际气象。历史与远期 UT1/地方可见性还受 ΔT 不确定性影响。当前验证是对 JS 的移植对拍，并非新增 C++、DE441 或观测精度验证。日食接口见 [日食说明](solar-eclipses.md)。
