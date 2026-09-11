# 日月与其他行星的模块拆分

`generated/*_series.dart` 按天体存放系数，`generated/series.dart` 保留聚合导出，
供内部兼容和离线工具使用。地球计算直接读取 `earthSeries`，不经过全部行星
目录；月球仍使用同一套共享相位求值。`planet_evaluator.dart` 提供通用求值器，
不引用任何具体天体表。

`sun_moon_ephemeris.dart` 提供日月状态，`planet_models.dart` 提供其他行星与
冥王星。`apparent_core.dart` 共用视位置算法，日月入口与通用入口通过不可变
求值器参数连接，不使用全局可变注册表，也不引入异步 API。

现有 `package:ephemeris_lite/ephemeris_lite.dart` API 保持兼容；只需要日月
几何位置时也可以显式使用：

```dart
import 'package:ephemeris_lite/sun_moon.dart';

void main() {
  final earth = earthState(2451545, accuracy: Accuracy.mid);
  final moon = moonState(2451545, accuracy: Accuracy.fast);
  print([earth.position, moon.position]);
}
```

不必更换上层八字、紫微的依赖或导入。Dart 编译器按可达代码裁剪；关键是
日月计算不再访问包含所有行星的映射，而不是单纯把一个文件切成多个文件。
通用行星观测接口仍会依赖其他行星；地方食可见性等复用通用观测的功能，
也不保证全部只依赖日月模块。

## Dart Web 体积实测

`tool/bundle_probe.dart` 保持程序相同，通过当前毫秒数构造角度，调用精确
定气与定朔，避免常量结果替代实际计算。编译命令：

```sh
dart compile js -O2 tool/bundle_probe.dart -o /tmp/lunisolar.js
```

| 同一个程序 | 拆分前 | 拆分后 |
| --- | ---: | ---: |
| dart2js 输出字节 | 930484 | 355331 |
| Node.js 默认 gzip 字节 | 374925 | 140823 |

这是单个气朔程序的编译体积，不是 pub 安装包体积，不是整个 Flutter 应用
的体积，也不代表原生 AOT 能获得相同比例。源码包仍包含全部系数。

系数、档位前缀与算法不变；全部生成系数已逐值核对，月球和冥王星声明原样
迁移。用 `tool/state_snapshot.dart` 在约 -6000～10000 年的 33 个历元、
三档精度下比较 1,386 组状态，拆分前后 JSON 输出逐字节一致。新增测试验证
日月视位置与通用入口逐值一致，并限制气朔和太阳时的静态依赖图。

数据导入器通过 `tool/split_series.mjs` 写入拆分表；后续重新导入不会恢复
单个大表。生成来源的哈希清单覆盖 JS 中的实际分体表，而不只记录聚合入口。
