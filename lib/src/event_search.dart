// Port of the scalar/angle crossing primitives in event-search.js. MPL-2.0.
import 'dart:math' as math;
import 'sky_math.dart';
import 'apparent.dart';
import 'time.dart';

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

/// Direction immediately after a station, otherwise at the event itself.
enum MotionDirection { direct, retrograde }

class SkyEvent {
  final SkyBody body;
  final JulianTime time;
  final SkyFrame frame;
  final double longitudeDeg, longitudeSpeedDegPerDay;
  final MotionDirection direction;
  const SkyEvent({
    required this.body,
    required this.time,
    required this.frame,
    required this.longitudeDeg,
    required this.longitudeSpeedDegPerDay,
    required this.direction,
  });
  Map<String, Object> toJson() => {
    'body': body.name,
    'time': time.toJson(),
    'frame': switch (frame) {
      SkyFrame.j2000 => 'j2000',
      SkyFrame.meanOfDate => 'mean-of-date',
      SkyFrame.trueOfDate => 'true-of-date',
    },
    'longitudeDeg': longitudeDeg,
    'longitudeSpeedDegPerDay': longitudeSpeedDegPerDay,
    'direction': direction.name,
  };
}

class LongitudeCrossing extends SkyEvent {
  final double targetDeg;
  @override
  Map<String, Object> toJson() => {...super.toJson(), 'targetDeg': targetDeg};
  LongitudeCrossing._(SkyEvent e, this.targetDeg)
    : super(
        body: e.body,
        time: e.time,
        frame: e.frame,
        longitudeDeg: e.longitudeDeg,
        longitudeSpeedDegPerDay: e.longitudeSpeedDegPerDay,
        direction: e.direction,
      );
}

class RelativeLongitudeEvent extends SkyEvent {
  final SkyBody other;
  final double angleDeg;
  @override
  Map<String, Object> toJson() => {
    ...super.toJson(),
    'other': other.name,
    'angleDeg': angleDeg,
  };
  RelativeLongitudeEvent._(SkyEvent e, this.other, this.angleDeg)
    : super(
        body: e.body,
        time: e.time,
        frame: e.frame,
        longitudeDeg: e.longitudeDeg,
        longitudeSpeedDegPerDay: e.longitudeSpeedDegPerDay,
        direction: e.direction,
      );
}

class IngressEvent extends SkyEvent {
  final double boundaryDeg;
  final int fromSign, toSign;
  @override
  Map<String, Object> toJson() => {
    ...super.toJson(),
    'boundaryDeg': boundaryDeg,
    'fromSign': fromSign,
    'toSign': toSign,
  };
  IngressEvent._(SkyEvent e, this.boundaryDeg, this.fromSign, this.toSign)
    : super(
        body: e.body,
        time: e.time,
        frame: e.frame,
        longitudeDeg: e.longitudeDeg,
        longitudeSpeedDegPerDay: e.longitudeSpeedDegPerDay,
        direction: e.direction,
      );
}

SkyEvent _skyEvent(
  SkyBody body,
  double tt,
  ApparentOptions options, {
  MotionDirection? direction,
}) {
  final p = apparentBodyState(body, tt, options: options);
  return SkyEvent(
    body: body,
    time: JulianTime.fromTT(tt),
    frame: p.frame,
    longitudeDeg: p.longitudeDeg,
    longitudeSpeedDegPerDay: p.longitudeSpeedDegPerDay,
    direction:
        direction ??
        (p.longitudeSpeedDegPerDay < 0
            ? MotionDirection.retrograde
            : MotionDirection.direct),
  );
}

/// 在 TT 儒略日起止区间内搜索目标黄经穿越。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
List<LongitudeCrossing> searchLongitudeCrossings(
  SkyBody body,
  double targetDeg,
  double startTT,
  double endTT, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) => List.unmodifiable(
  searchAngleCrossings(
    (t) => apparentBodyPosition(body, t, options: apparent).longitudeDeg,
    targetDeg,
    startTT,
    endTT,
    stepDays: stepDays,
    toleranceDays: toleranceDays,
  ).map(
    (r) => LongitudeCrossing._(
      _skyEvent(body, r.time, apparent),
      normDeg(targetDeg),
    ),
  ),
);

/// 在 TT 儒略日起止区间内搜索两天体的目标黄经差。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 角度定义为 body 减 other 的黄经差（度），不是三维角距离的极小值。
List<RelativeLongitudeEvent> searchRelativeLongitude(
  SkyBody body,
  SkyBody other,
  double angleDeg,
  double startTT,
  double endTT, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) {
  if (body == other) {
    throw RangeError('relative search requires different bodies');
  }
  return List.unmodifiable(
    searchAngleCrossings(
      (t) =>
          apparentBodyPosition(body, t, options: apparent).longitudeDeg -
          apparentBodyPosition(other, t, options: apparent).longitudeDeg,
      angleDeg,
      startTT,
      endTT,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).map(
      (r) => RelativeLongitudeEvent._(
        _skyEvent(body, r.time, apparent),
        other,
        normDeg(angleDeg),
      ),
    ),
  );
}

/// 在 TT 儒略日起止区间内搜索天体黄经留（黄经速度过零）。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
List<SkyEvent> searchStations(
  SkyBody body,
  double startTT,
  double endTT, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) {
  double speed(double t) =>
      apparentBodyState(body, t, options: apparent).longitudeSpeedDegPerDay;
  return List.unmodifiable(
    searchCrossings(
      speed,
      startTT,
      endTT,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).map(
      (r) => _skyEvent(
        body,
        r.time,
        apparent,
        direction: speed(r.time + 0.01) < 0
            ? MotionDirection.retrograde
            : MotionDirection.direct,
      ),
    ),
  );
}

/// 在 TT 儒略日起止区间内搜索天体顺行或逆行跨越黄道十二宫边界。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 每 30° 为一个边界，宫序号为 0～11，包含逆行重新进入。
List<IngressEvent> searchIngresses(
  SkyBody body,
  double startTT,
  double endTT, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) {
  return List.unmodifiable(
    searchCrossings(
      (t) => math.sin(
        apparentBodyPosition(body, t, options: apparent).longitudeDeg / rad * 6,
      ),
      startTT,
      endTT,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).map((r) {
      final e = _skyEvent(body, r.time, apparent),
          boundary = (e.longitudeDeg / 30 + 0.5).floor() % 12;
      final direct = e.direction == MotionDirection.direct;
      return IngressEvent._(
        e,
        boundary * 30.0,
        direct ? (boundary + 11) % 12 : boundary,
        direct ? boundary : (boundary + 11) % 12,
      );
    }),
  );
}
