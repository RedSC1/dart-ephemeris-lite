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

abstract class OrbitalEvent {
  JulianTime get time;
  Map<String, Object> toJson();
}

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

/// Geocentric geometric distance extrema, without light-time corrections.
List<ApsisEvent> searchLunarApsides(
  double startTT,
  double endTT, {
  double stepDays = 1,
  double toleranceDays = 1e-8,
}) => _apsides(ApsisBody.moon, startTT, endTT, stepDays, toleranceDays);

/// Heliocentric geometric Earth distance extrema, without apparent corrections.
List<ApsisEvent> searchEarthApsides(
  double startTT,
  double endTT, {
  double stepDays = 2,
  double toleranceDays = 1e-8,
}) => _apsides(ApsisBody.earth, startTT, endTT, stepDays, toleranceDays);

/// Actual Moon crossings of the selected ecliptic plane, not mean orbital nodes.
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

/// Maxima of 3D apparent separation from the Sun. East/west labels always use
/// date ecliptic longitudes, independently of the selected output frame.
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

/// Right ascension body-other. A zero crossing is an RA conjunction, not a
/// minimum 3D angular separation. Search interval is [startTT,endTT).
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
