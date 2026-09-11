/// 单次计算的精度档位，不修改全局状态。
///
/// 几何位置三档控制系数前缀；气朔三档还采用不同模型与求解流程。
/// 位置默认 accurate，气朔默认 mid；档位不构成固定误差上限的保证。
enum Accuracy {
  /// 位置使用较短前缀；气朔采用固定阶段的快速求解。
  fast,

  /// 位置使用中等前缀；气朔采用专用事件模型并迭代求解。
  mid,

  /// 位置使用本包全量系数；气朔采用完整视位置链迭代求解。
  ///
  /// “全量”指本包发布的系数，不是上游完整理论的全部项。
  accurate,
}

/// Convert a configuration string or typed accuracy; null selects [fallback].
Accuracy checkedAccuracy(
  Object? value, {
  Accuracy fallback = Accuracy.accurate,
}) {
  if (value == null) return fallback;
  if (value is Accuracy) return value;
  for (final a in Accuracy.values) {
    if (value == a.name) return a;
  }
  throw RangeError('accuracy must be fast, mid or accurate');
}
