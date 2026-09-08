# 光照相位与黄经事件

## 光照与视圆面

`bodyPhenomena(body, jdTT)` 返回地心距离、相位角、被照亮比例、太阳角距、视直径和地平视差。太阳自身的相位角和照明比例为 null。
相位角在目标天体处由日心目标向量与观测向量确定，不使用“180°减去地心日距”的简化式。
这些接口没有经验星等、地形或卫星光心模型。圆面半径只是常用近似值；冥王星位置对应系统质心，不能把视直径理解为分辨后的图像边缘。

`moonIllumination` 另外返回 `phaseCycle`（月日黄经差／360）和 `waxing`。周期值不是被照亮比例；盈亏方向始终采用日期黄道定义，独立于用户要求的输出参考系。
`apparentGeometry` 暴露只读的日心地球、目标、地心天体测量向量和视坐标；astrometric 向量位于光行时处理之后、光行差和引力偏折之前。

## 事件查询

- `searchLongitudeCrossings`：单一天体的指定黄经穿越。
- `searchRelativeLongitude`：两个天体黄经之差穿越给定角度，可查询黄经合／冲；不是球面最小角距。
- `searchStations`：视黄经速度过零。方向表示留点之后的顺行／逆行，不取零速附近的舍入符号。
- `searchIngresses`：每 30°分界，包括逆行返回。`fromSign` 和 `toSign` 为 0～11，属于坐标角区，不是 IAU 星座边界。

输入起止时间均为 **JD(TT)**，区间为 `[startTT,endTT)`，返回事件的 `time` 为 JulianTime。不要直接将 UT1 数字当作 TT。
`apparent` 参数可选择参考系、位置 accuracy 和光行时等开关；J2000 与日期参考系的留／黄经穿越时刻可能不同。
默认步长 0.5 天，数值根容差 1e-8 天。容差是数值阈值，不是绝对观测精度。

搜索继承标量变号根扫描的限制：过粗步长可能漏掉同一格内的多次穿越或相切根。全链视位置速度为中心差分，不能将留点精度解释为任意高阶解析速度精度。
## 轨道与赤经事件

- `searchLunarApsides` / `searchEarthApsides`：几何地心月距和日心地距的极值。使用全量几何状态，不接受视位置精度或光行时开关。
- `searchLunarNodes`：月球实际穿越指定黄道平面的时刻；默认日期平黄道，可选 J2000 或日期真黄道。不是平均轨道交点。日期矩阵的导数参与升降交点判断；章动黄经旋转不改变交点时刻。
- `searchGreatestElongations`：水星、金星与太阳三维视角距的局部最大值。东西方向始终按日期真黄道判断，不随输出参考系改变；支持 `ApparentOptions` 的精度和修正设置。
- `searchRelativeRightAscension`：指定赤经差（0 为赤经合，180 为赤经冲），不同于黄经合冲或最小角距。
- `searchRightAscensionStations`：视赤经速度为零，方向取事件后的运动方向；也支持视位置选项。

这些接口均接受 `[startTT, endTT)` 半开 TT 区间，返回不可变事件序列，包含 `JulianTime` 与 `toJson()`。搜索步长必须足以分辨事件；标量求根器不保证发现步长内的所有多重根或相切根。月食见 [月食说明](lunar-eclipses.md)，日食见 [日食说明](solar-eclipses.md)。
