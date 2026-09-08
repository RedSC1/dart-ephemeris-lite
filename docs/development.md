# 开发与数据同步

本库正常使用及测试不需要 JS 仓库。只有重新生成系数和 JS 对拍数据时需要 Node.js 与上游 checkout。
在仓库根目录运行：

```sh
node tool/import_js_data.mjs ../taiyin-lite
node tool/generate_oracles.mjs ../taiyin-lite
dart pub get
dart test
dart analyze
```

生成器必须针对同一个已提交的上游版本运行。`tool/upstream.json` 记录数据来源；提交生成数据、fixture 与该清单。
生成 Dart 常量使用原始 double 的可往返十进制形式，不调整频率、不重新拟合、不更改系数排序。
前缀计数也直接从上游导入，尤其保留地球独有的档位配额。

JS fixture 生成使用固定种子，测试不联网；没有使用 Dart 自己算出的值作为 JS 期望值。
目前容差：行星各坐标与速度 `1e-11 AU` / `1e-11 AU/day`；月球 `1e-6 km` / `1e-6 km/day`。
这是跨语言移植容差，不是模型相对观测或 DE441 的误差声明。

手写 Dart 文件使用 `dart format`。生成的系数文件不参与格式检查，避免格式化后制造无意义的大量 diff。
CI 运行静态分析、回归测试，并编译/执行纯 Dart 示例的 JavaScript 输出。

## 非目标

- 不通过 Dart FFI 调用 C++。
- 不嵌入 JS 引擎或依赖旧 Dart 底层。
- 不在移植时偷偷更换天文模型或历法策略。
- 不在新底层尚不可用时修改旧排盘包。
