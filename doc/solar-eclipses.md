# 日食

[中文](solar-eclipses.md) | [English](solar-eclipses.en.md) · [文档首页](README.md)

## 可运行示例

[local_solar_eclipse.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/local_solar_eclipse.dart)

```sh
dart run example/local_solar_eclipse.dart
```

<!-- example: example/local_solar_eclipse.dart -->
```dart
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  final date = ZonedTime(
    year: 2024,
    month: 4,
    day: 8,
    offsetMinutes: 0,
  ).toJulianTime();
  final global = getSolarEclipseDetails(date);
  if (global == null) {
    print('No solar eclipse in this lunation.');
    return;
  }
  print(global.toJson());
  final local = getLocalSolarEclipse(
    date,
    const Observer(longitudeDeg: -96.8, latitudeDeg: 32.8),
  );
  print(local?.toJson());
}
```

`getSolarEclipseDetails(date)` 查询输入附近朔所属的日食，无食返回 null，不是任意最近日食搜索。`searchSolarEclipses(start,end)` 按全球食甚筛选半开区间；输入为 JulianTime，结束必须晚于开始，一次至多 5000 个朔望月（含内部余量）。

结果包括 partial / total / annular / hybrid、合朔与食甚、最大食地点、食分、带宽、中心食持续时间及接触地理点。不可把全球食甚等同于每个观测点的地方食甚。未发生的中心食接触返回 null。

五点 Newton 插值共享日月三维视向量；中心前后 0.25 天内插值，窗口外重新精确求值。影锥与地表采用 WGS84 椭球，地方食采用三维视圆面交叠。该接口使用固定模型，不提供额外精度开关。

`getLocalSolarEclipse(date, observer)` 使用经纬度和海拔、标准大气 1013.25 mbar / 15°C，忽略 Observer 自定义气象字段，以保持与 JS 一致。返回当地可见食分和食类、日出／日落、地平截断标记及接触时间；地平线下的地方接触会设为 null。可见性按太阳上边缘加折射判断，没有地形或月缘山谷。

全球接触点、最大食地点和瞬时带宽是数值结果；本库不绘制地图。历史／远期的地理点和地方时刻仍受 ΔT 不确定性影响，不应将计算结果理解为观测精度认证。
