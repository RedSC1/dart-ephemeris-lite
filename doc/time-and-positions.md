# 时间与天体位置

[中文](time-and-positions.md) | [English](time-and-positions.en.md) · [文档首页](README.md)

## 可运行示例

[positions.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/positions.dart)

```sh
dart run example/positions.dart
```

<!-- example: example/positions.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final time = JulianTime.fromTT(2451545.0);
  final geometric = planetHeliocentricState(
    Planet.mars,
    time.jdTT,
    accuracy: Accuracy.mid,
  );
  print('Heliocentric J2000 [AU]: ${geometric.position}');
  print('Analytic velocity [AU/day]: ${geometric.velocity}');
  final apparent = apparentBodyState(
    SkyBody.mars,
    time.jdTT,
    options: const ApparentOptions(
      frame: SkyFrame.trueOfDate,
      accuracy: Accuracy.accurate,
    ),
  );
  print('Apparent longitude [deg]: ${apparent.longitudeDeg}');
  print('Longitude rate [deg/day]: ${apparent.longitudeSpeedDegPerDay}');
}
```

## 先确定时间尺度

使用 `ZonedTime` 表达固定时区民用时间，再转换为 `JulianTime`。几何位置、视位置和通用天象搜索使用 `jdTT`；农历瞬时转换、地平坐标与日界使用 `jdUT1`。不要把两个裸数字混用。

`JulianTime.fromTT` 与 `fromUT1` 使用内置 ΔT 换算；`fromValues` 可提供外部 TT、UT1 与 ΔT（秒），三个值必须一致。UTC 标签按 UT1 近似，不含完整 UTC/TAI 闰秒或 EOP 模型。

`DateTime` 按时间戳导入，不重新解释其年月日。民用字段采用混合儒略历／格里高利历，1582-10-15 切换，年 0 表示公元前 1 年。需要验证日期时用 `ZonedTime`；底层 `julianDay` 允许日字段溢出归一化。

## 几何位置与视位置

| 结果 | 中心／坐标系 | 单位 |
| --- | --- | --- |
| `earthState`、`planetHeliocentricState` | 日心，J2000 平黄道／平春分点 | AU、AU/day |
| `moonState` | 地心，同上 | km、km/day |
| `moonHeliocentricState`、`embState` | 日心，同上 | AU、AU/day |
| `apparentBodyPosition`、`apparentBodyState` | 地心，选定的黄道／赤道参考系 | 角度为度，距离 AU；速度为度/day、AU/day |

几何速度由级数解析求导；视位置速度是完整修正链的差分。单位方向接口返回无量纲向量及其每日导数，不是线速度。

`SkyFrame.j2000` 是 J2000 平黄道／平春分点，不是 ICRS；`meanOfDate` 为日期平参考系；`trueOfDate` 为日期真参考系。视位置默认启用光行时、光行差和太阳引力偏折，不含多天体偏折或 Shapiro 延迟。

## 三档精度与范围

位置默认 `Accuracy.accurate`，三档使用离线准备的系数前缀。这里的“全量”指本包发布系数，不是完整 VSOP2013/ELP 理论原表。没有全局可变精度设置。

常规模型目标区间约为 −6000～10000 年，但不同天体与年代的误差并不相同；不应把可计算范围当作统一精度保证。冥王星代表其系统质心，推荐区间为 1600～2200，区间外为粗略模型和平滑过渡。未来 ΔT 包含实验性拟合。

气朔三档还改变模型和求解流程，详见[气朔与太阳时](qi-shuo-solar-time.md)。
