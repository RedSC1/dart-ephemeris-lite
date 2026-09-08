// Port of the scalar/angle crossing primitives in event-search.js. MPL-2.0.
import 'dart:math' as math;
import 'sky_math.dart';

class Crossing {
  final double time;
  const Crossing(this.time);
}

/// Sign-changing roots in [start,end). Tangencies or multiple roots inside a
/// sampling step are not guaranteed. Time units follow the supplied evaluator.
List<Crossing> searchCrossings(
  double Function(double) evaluate,
  double start,
  double end, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
}) {
  if (!start.isFinite || !end.isFinite) {
    throw ArgumentError('search bounds must be finite');
  }
  if (end < start) {
    throw RangeError('end must not precede start');
  }
  if (!stepDays.isFinite ||
      !toleranceDays.isFinite ||
      toleranceDays < 1e-9 ||
      stepDays <= toleranceDays) {
    throw RangeError('stepDays must exceed toleranceDays >= 1e-9');
  }
  final rawCount = (end - start) / stepDays;
  if (!rawCount.isFinite || rawCount > 200000) {
    throw RangeError('search exceeds 200000 samples; split the interval');
  }
  final count = rawCount.ceil();
  if (count == 0) {
    return const [];
  }
  double sample(double t) {
    final v = evaluate(t);
    if (!v.isFinite) {
      throw ArgumentError('search sample must be finite');
    }
    return v;
  }

  final roots = <Crossing>[];
  void push(double t) {
    if (t < start ||
        t >= end ||
        (roots.isNotEmpty && t - roots.last.time <= toleranceDays * 2)) {
      return;
    }
    roots.add(Crossing(t));
  }

  var left = start, fLeft = sample(start);
  if (fLeft == 0) {
    push(left);
  }
  for (var i = 1; i <= count; i++) {
    final right = math.min(end, start + i * stepDays), fRight = sample(right);
    if (fLeft == 0 && fRight == 0) {
      throw RangeError(
        'adjacent samples are both zero; roots are not isolated at this step',
      );
    }
    if (fRight == 0) {
      push(right);
    } else if (fLeft != 0 && fLeft.sign != fRight.sign) {
      var a = left, b = right, fa = fLeft;
      for (var j = 0; j < 80 && b - a > toleranceDays; j++) {
        final mid = a + (b - a) / 2;
        if (mid == a || mid == b) {
          break;
        }
        final fm = sample(mid);
        if (fm == 0) {
          a = b = mid;
          break;
        }
        if (fm.sign == fa.sign) {
          a = mid;
          fa = fm;
        } else {
          b = mid;
        }
      }
      final root = a + (b - a) / 2;
      sample(root);
      push(root);
    }
    left = right;
    fLeft = fRight;
  }
  return List.unmodifiable(roots);
}

/// Periodic angle roots in [start,end), with antipodes rejected.
List<Crossing> searchAngleCrossings(
  double Function(double) evaluateDegrees,
  double targetDeg,
  double start,
  double end, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
}) {
  if (!targetDeg.isFinite) {
    throw ArgumentError('targetDeg must be finite');
  }
  final target = normDeg(targetDeg);
  double delta(double t) {
    final a = evaluateDegrees(t);
    if (!a.isFinite) {
      throw ArgumentError('angle sample must be finite');
    }
    return signedDeg(a - target);
  }

  return List.unmodifiable(
    searchCrossings(
      (t) => math.sin(delta(t) / rad),
      start,
      end,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).where((r) => delta(r.time).abs() < 90),
  );
}
