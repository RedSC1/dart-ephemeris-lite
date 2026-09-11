# 地平坐标与升落

[中文](visibility.md) | [English](visibility.en.md) · [文档首页](README.md)

## 可运行示例

[visibility.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/visibility.dart)

```sh
dart run example/visibility.dart
```

<!-- example: example/visibility.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  const site = Observer(longitudeDeg: 116.4074, latitudeDeg: 39.9042);
  final date = ZonedTime(year: 2026, month: 6, day: 21, offsetMinutes: 480);
  final solar = solarRiseSetForDate(date, site);
  print('Sun: ${solar.altitudeState.name}');
  print(solar.rise?.toZonedTime(480).toJson());
  final moon = bodyRiseSetForDay(SkyBody.moon, date.toJulianTime().jdUT1, site);
  for (final rise in moon.rises) {
    print(rise.toZonedTime(480).toJson());
  }
}
```

## 两种时间窗口

- `solarRiseSetForDate(ZonedTime, observer)` 使用该时区的民用日期，忽略时分秒，以当地正午为中心取 24 小时。
- `computeSolarRiseSetFast(center, observer)`，以及 `solarRiseSetForDate` 的数字／JulianTime 输入，使用以该 UT1 时刻为中心的 24 小时窗口。
- `bodyRiseSetForDay(body, dayStartUT1, observer)` 使用严格的半开区间 `[dayStartUT1, dayStartUT1 + 1)`。要查当地某日，应先由当地零点的 ZonedTime 得到 UT1 起点；接口不会根据经度猜时区。

返回的事件均为 `JulianTime`；可用 `toZonedTime` 显示。通用天体接口返回所有升、落、上中天和下中天事件列表，可能为空或有多个事件。太阳快速接口只返回各一个可空的 rise/set，不等同于通用全天事件列表。

## 几何与选项

`Observer` 使用 WGS84 大地经纬度，经度向东为正，高度单位为米。方位角从北经东计量。
`DiscLimb.upper/center/lower` 分别使用上缘、中心和下缘；折射针对所选边缘的光线计算，不是先折射中心再加视半径。

`bodyHorizontalPosition` 只允许 `SkyFrame.trueOfDate`。`BodyVisibilityOptions.apparent` 保留位置算法的 accuracy 和光行时／光行差／太阳引力偏折开关。
`computeSolarRiseSetFast` 中的 Fast 指太阳升落的近似种子和少次迭代策略，不代表 `Accuracy.fast`；该专用路径保持上游固定的太阳模型，不提供 accuracy 参数。

两条求解链按 JS 原样分别移植，不能要求结果逐秒相同：太阳专用链的视位置、观测点旋转及太阳半径常量与通用链不同。此次移植没有暗中合并或替换它们。

默认站点气压为 1013.25 mbar、温度为 15°C；独立折射函数的默认值按上游保留为 1010 mbar、10°C。
折射模型在 −1°以下截断为零；通用升落求解会拒绝截断跳变造成的伪根。太阳快速回退仍保留上游两小时采样策略，不宣称它与通用求解器有相同的擦边事件检出能力。
通用求解器使用十分钟采样并细化局部极值，以检查同一采样间隔内的两次穿越。

## 状态和限制

`AltitudeState` 区分穿越、持续在阈值上方、持续在下方、相切和未找到。无事件时不伪造时刻；“above/below”均针对用户选择的边缘、折射和地平高度阈值。
这些接口计算几何／视地平位置，不模拟地形遮挡、地平下沉、极移、周日光行差、云量或肉眼可见性。视半径采用近似圆盘，不用于遮掩轮廓精细计算。

公共 `searchCrossings` / `searchAngleCrossings` 只保证所选采样能分辨的变号根，使用 `[start,end)`；不保证任意切触或一个采样步长里的多个根。大量搜索须拆分区间，不能把过大的步长当作无损加速选项。
