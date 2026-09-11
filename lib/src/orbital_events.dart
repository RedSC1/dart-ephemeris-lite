// Port of orbital-events.js. MPL-2.0. All search epochs are JD(TT).
import 'dart:math' as math;
import 'apparent.dart';
import 'coordinates.dart';
import 'ephemeris.dart';
import 'event_search.dart';
import 'sky_math.dart';
import 'time.dart';

enum ApsisBody { moon, earth }

enum ApsisKind { periapsis, apoapsis }

enum NodeKind { ascending, descending }

enum ElongationKind { eastern, western }

String _frame(SkyFrame f) => switch (f) {
  SkyFrame.j2000 => 'j2000',
  SkyFrame.meanOfDate => 'mean-of-date',
  SkyFrame.trueOfDate => 'true-of-date',
};

/// 具有物理事件时刻与 JSON 表示的轨道事件。
abstract class OrbitalEvent {
  JulianTime get time;
  Map<String, Object> toJson();
}

/// 月球近远地点或地球近远日点；距离同时提供 km 与 AU。
class ApsisEvent implements OrbitalEvent {
  final ApsisBody body;
  @override
  final JulianTime time;
  final ApsisKind kind;
  final double distanceKm, distanceAu;
  const ApsisEvent._(
    this.body,
    this.time,
    this.kind,
    this.distanceKm,
    this.distanceAu,
  );
  String get center => body == ApsisBody.moon ? 'earth' : 'sun';
  @override
  Map<String, Object> toJson() => {
    'body': body.name,
    'time': time.toJson(),
    'center': center,
    'kind': kind.name,
    'distanceKm': distanceKm,
    'distanceAu': distanceAu,
  };
}

/// 月球穿越参考黄道的事件；角度为度，距离为 km。
class LunarNodeEvent implements OrbitalEvent {
  @override
  final JulianTime time;
  final SkyFrame frame;
  final NodeKind kind;
  final double longitudeDeg, latitudeDeg, distanceKm;
  const LunarNodeEvent._(
    this.time,
    this.frame,
    this.kind,
    this.longitudeDeg,
    this.latitudeDeg,
    this.distanceKm,
  );
  SkyBody get body => SkyBody.moon;
  @override
  Map<String, Object> toJson() => {
    'body': body.name,
    'time': time.toJson(),
    'frame': _frame(frame),
    'kind': kind.name,
    'longitudeDeg': longitudeDeg,
    'latitudeDeg': latitudeDeg,
    'distanceKm': distanceKm,
  };
}

/// 水星或金星大距；距角及黄道坐标以度表示。
class ElongationEvent implements OrbitalEvent {
  final SkyBody body;
  @override
  final JulianTime time;
  final SkyFrame frame;
  final ElongationKind kind;
  final double elongationDeg, longitudeDeg, latitudeDeg;
  const ElongationEvent._(
    this.body,
    this.time,
    this.frame,
    this.kind,
    this.elongationDeg,
    this.longitudeDeg,
    this.latitudeDeg,
  );
  @override
  Map<String, Object> toJson() => {
    'body': body.name,
    'time': time.toJson(),
    'frame': _frame(frame),
    'kind': kind.name,
    'elongationDeg': elongationDeg,
    'longitudeDeg': longitudeDeg,
    'latitudeDeg': latitudeDeg,
  };
}

/// 两天体达到指定赤经差的事件；角度均以度表示。
class RelativeRightAscensionEvent implements OrbitalEvent {
  final SkyBody body, other;
  @override
  final JulianTime time;
  final SkyFrame frame;
  final double angleDeg,
      rightAscensionDeg,
      declinationDeg,
      declinationDifferenceDeg;
  const RelativeRightAscensionEvent._(
    this.body,
    this.other,
    this.time,
    this.frame,
    this.angleDeg,
    this.rightAscensionDeg,
    this.declinationDeg,
    this.declinationDifferenceDeg,
  );
  @override
  Map<String, Object> toJson() => {
    'body': body.name,
    'other': other.name,
    'time': time.toJson(),
    'frame': _frame(frame),
    'angleDeg': angleDeg,
    'rightAscensionDeg': rightAscensionDeg,
    'declinationDeg': declinationDeg,
    'declinationDifferenceDeg': declinationDifferenceDeg,
  };
}

/// 赤经速度过零的留事件；坐标为度，速度为度/日。
class RightAscensionStationEvent implements OrbitalEvent {
  final SkyBody body;
  @override
  final JulianTime time;
  final SkyFrame frame;
  final MotionDirection direction;
  final double rightAscensionDeg, declinationDeg, rightAscensionSpeedDegPerDay;
  const RightAscensionStationEvent._(
    this.body,
    this.time,
    this.frame,
    this.direction,
    this.rightAscensionDeg,
    this.declinationDeg,
    this.rightAscensionSpeedDegPerDay,
  );
  @override
  Map<String, Object> toJson() => {
    'body': body.name,
    'time': time.toJson(),
    'frame': _frame(frame),
    'direction': direction.name,
    'rightAscensionDeg': rightAscensionDeg,
    'declinationDeg': declinationDeg,
    'rightAscensionSpeedDegPerDay': rightAscensionSpeedDegPerDay,
  };
}

List<ApsisEvent> _apsides(
  ApsisBody body,
  double start,
  double end,
  double step,
  double tolerance,
) {
  CartesianState state(double t) =>
      body == ApsisBody.moon ? moonState(t) : earthState(t);
  double rate(double t) {
    final s = state(t);
    return dot(s.position, s.velocity) / norm(s.position);
  }

  return List.unmodifiable(
    searchCrossings(
      rate,
      start,
      end,
      stepDays: step,
      toleranceDays: tolerance,
    ).map((r) {
      final distance = norm(state(r.time).position),
          moon = body == ApsisBody.moon;
      return ApsisEvent._(
        body,
        JulianTime.fromTT(r.time),
        rate(r.time + 0.05) > 0 ? ApsisKind.periapsis : ApsisKind.apoapsis,
        moon ? distance : distance * auKm,
        moon ? distance / auKm : distance,
      );
    }),
  );
}

/// 在 TT 儒略日起止区间内搜索月球地心距离近点与远点。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 采用全量地心几何距离，不含光行时修正。
List<ApsisEvent> searchLunarApsides(
  double startTT,
  double endTT, {
  double stepDays = 1,
  double toleranceDays = 1e-8,
}) => _apsides(ApsisBody.moon, startTT, endTT, stepDays, toleranceDays);

/// 在 TT 儒略日起止区间内搜索地球日心距离近点与远点。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 采用全量日心几何距离，不含视位置修正。
List<ApsisEvent> searchEarthApsides(
  double startTT,
  double endTT, {
  double stepDays = 2,
  double toleranceDays = 1e-8,
}) => _apsides(ApsisBody.earth, startTT, endTT, stepDays, toleranceDays);

/// 在 TT 儒略日起止区间内搜索月球穿越所选黄道的升交点与降交点。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 求月球实际穿越参考黄道平面的时刻，不是平均轨道交点。
List<LunarNodeEvent> searchLunarNodes(
  double startTT,
  double endTT, {
  SkyFrame frame = SkyFrame.meanOfDate,
  double stepDays = 1,
  double toleranceDays = 1e-8,
}) {
  CartesianState state(double t) {
    final s = moonState(t);
    if (frame == SkyFrame.j2000) {
      return s;
    }
    final m = meanEclipticOfDateMatrixState(t);
    var p = transform(m.matrix, s.position),
        v = add(transform(m.matrix, s.velocity), transform(m.rate, s.position));
    if (frame == SkyFrame.trueOfDate) {
      final angle = iau2000bNutation(t).dpsi;
      p = rotateZ(p, angle);
      v = rotateZ(v, angle);
    }
    return CartesianState(p, v);
  }

  return List.unmodifiable(
    searchCrossings(
      (t) => state(t).position[2],
      startTT,
      endTT,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).map((r) {
      final s = state(r.time), p = spherical(s.position);
      return LunarNodeEvent._(
        JulianTime.fromTT(r.time),
        frame,
        s.velocity[2] > 0 ? NodeKind.ascending : NodeKind.descending,
        p.longitudeDeg,
        p.latitudeDeg,
        norm(s.position),
      );
    }),
  );
}

({ApparentState a, double cosine, double rate}) _separation(
  SkyBody body,
  double tt,
  ApparentOptions options,
) {
  final a = apparentBodyState(body, tt, options: options),
      b = apparentBodyState(SkyBody.sun, tt, options: options);
  final p = a.equatorialPositionAu,
      q = b.equatorialPositionAu,
      v = a.equatorialVelocityAuPerDay,
      w = b.equatorialVelocityAuPerDay;
  final r = norm(p), s = norm(q), cosine = dot(p, q) / (r * s);
  final rate =
      (dot(v, q) + dot(p, w)) / (r * s) -
      cosine * (dot(p, v) / (r * r) + dot(q, w) / (s * s));
  return (a: a, cosine: cosine, rate: rate);
}

/// 在 TT 儒略日起止区间内搜索水星或金星的东大距与西大距。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 求与太阳三维视角距离的极大值；东／西标签始终使用日期黄经，
/// 与选定的输出参考系无关。
List<ElongationEvent> searchGreatestElongations(
  SkyBody body,
  double startTT,
  double endTT, {
  double stepDays = 1,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) {
  if (body != SkyBody.mercury && body != SkyBody.venus) {
    throw RangeError('greatest elongation requires mercury or venus');
  }
  final date = ApparentOptions(
    frame: SkyFrame.trueOfDate,
    accuracy: apparent.accuracy,
    lightTime: apparent.lightTime,
    aberration: apparent.aberration,
    solarDeflection: apparent.solarDeflection,
  );
  return List.unmodifiable(
    searchCrossings(
          (t) => _separation(body, t, apparent).rate,
          startTT,
          endTT,
          stepDays: stepDays,
          toleranceDays: toleranceDays,
        )
        .where(
          (r) =>
              _separation(body, r.time - 0.05, apparent).rate < 0 &&
              _separation(body, r.time + 0.05, apparent).rate > 0,
        )
        .map((r) {
          final s = _separation(body, r.time, apparent);
          final delta = signedDeg(
            apparentBodyPosition(body, r.time, options: date).longitudeDeg -
                apparentBodyPosition(
                  SkyBody.sun,
                  r.time,
                  options: date,
                ).longitudeDeg,
          );
          return ElongationEvent._(
            body,
            JulianTime.fromTT(r.time),
            s.a.frame,
            delta > 0 ? ElongationKind.eastern : ElongationKind.western,
            math.acos(s.cosine.clamp(-1, 1)) * rad,
            s.a.longitudeDeg,
            s.a.latitudeDeg,
          );
        }),
  );
}

/// 在 TT 儒略日起止区间内搜索两天体的目标赤经差。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
///
/// 角度为 body 减 other 的赤经差（度）；0 表示赤经合，
/// 不代表三维角距离最小。区间左闭右开。
List<RelativeRightAscensionEvent> searchRelativeRightAscension(
  SkyBody body,
  SkyBody other,
  double angleDeg,
  double startTT,
  double endTT, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) {
  if (!angleDeg.isFinite) {
    throw ArgumentError('angleDeg must be finite');
  }
  if (body == other) {
    throw RangeError('relative search requires different bodies');
  }
  ApparentPosition position(SkyBody target, double t) =>
      apparentBodyPosition(target, t, options: apparent);
  return List.unmodifiable(
    searchAngleCrossings(
      (t) =>
          position(body, t).rightAscensionDeg -
          position(other, t).rightAscensionDeg,
      angleDeg,
      startTT,
      endTT,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).map((r) {
      final a = position(body, r.time), b = position(other, r.time);
      return RelativeRightAscensionEvent._(
        body,
        other,
        JulianTime.fromTT(r.time),
        a.frame,
        normDeg(angleDeg),
        a.rightAscensionDeg,
        a.declinationDeg,
        a.declinationDeg - b.declinationDeg,
      );
    }),
  );
}

/// 在 TT 儒略日起止区间内搜索天体赤经留（赤经速度过零）。
///
/// 返回事件时刻及对应观测量。数值求根容差不代表天文模型的绝对精度。
List<RightAscensionStationEvent> searchRightAscensionStations(
  SkyBody body,
  double startTT,
  double endTT, {
  double stepDays = 0.5,
  double toleranceDays = 1e-8,
  ApparentOptions apparent = const ApparentOptions(),
}) {
  ApparentState position(double t) =>
      apparentBodyState(body, t, options: apparent);
  double speed(double t) => position(t).rightAscensionSpeedDegPerDay;
  return List.unmodifiable(
    searchCrossings(
      speed,
      startTT,
      endTT,
      stepDays: stepDays,
      toleranceDays: toleranceDays,
    ).map((r) {
      final s = position(r.time);
      return RightAscensionStationEvent._(
        body,
        JulianTime.fromTT(r.time),
        s.frame,
        speed(r.time + 0.01) < 0
            ? MotionDirection.retrograde
            : MotionDirection.direct,
        s.rightAscensionDeg,
        s.declinationDeg,
        s.rightAscensionSpeedDegPerDay,
      );
    }),
  );
}
