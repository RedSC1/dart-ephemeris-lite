# 日月独立入口与 Web 体积

[中文](module-loading.md) | [English](module-loading.en.md) · [文档首页](README.md)

只需要日月几何位置时，可以导入轻量入口：

```dart
import 'package:ephemeris_lite/sun_moon.dart';
```

它提供 `Accuracy`、地球状态、月球状态、地心太阳、日心月球和地月质心等几何计算，使用与主入口相同的系数和精度档位。时间、历法、视位置、升落和日月食等功能仍从 `package:ephemeris_lite/ephemeris_lite.dart` 导入。

## 可运行示例

[sun_moon.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/sun_moon.dart)

```sh
dart run example/sun_moon.dart
```

<!-- example: example/sun_moon.dart -->
```dart
import 'package:ephemeris_lite/sun_moon.dart';

void main() {
  const jdTT = 2451545.0;
  final earth = earthState(jdTT, accuracy: Accuracy.mid);
  final moon = moonState(jdTT, accuracy: Accuracy.fast);
  print('Earth [AU]: ${earth.position}');
  print('Moon [km]: ${moon.position}');
}
```

## 体积说明

Dart Web 会删除程序无法访问的代码。轻量入口不会引入其他行星的系数，因此只做日月计算的网页通常可以得到更小的 JavaScript 输出。一次固定探针的编译结果如下：

| 同一个程序 | 拆分前 | 拆分后 |
| --- | ---: | ---: |
| dart2js 输出字节 | 930484 | 355331 |
| Node.js 默认 gzip 字节 | 374925 | 140823 |

数字仅说明这一入口在该探针中的裁剪效果，不代表固定的 Flutter、Web 或原生应用体积；实际结果取决于编译器、构建选项和应用调用的 API。pub 源码包仍包含全部系数，轻量入口减少的是最终程序的可达代码，不降低日月计算精度。

通用行星视位置以及部分地方食接口可能需要其他行星；使用这些功能时应导入主入口。
