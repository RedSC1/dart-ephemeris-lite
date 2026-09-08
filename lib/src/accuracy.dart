/// Position-series truncation. Event accuracy will have additional semantics.
enum Accuracy { fast, mid, accurate }

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
