const j2000 = 2451545.0;
const auKm = 149597870.7;
const earthMoonMassRatio = 81.30056822149722;

/// Geometric targets; Pluto denotes its system barycenter.
enum Planet {
  mercury,
  venus,
  earth,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
}

/// Geometric mean J2000 ecliptic position and analytic velocity.
/// Planet states: AU and AU/day. Geocentric Moon: km and km/day.
class CartesianState {
  final List<double> position, velocity;
  CartesianState(List<double> position, List<double> velocity)
    : position = List.unmodifiable(position),
      velocity = List.unmodifiable(velocity);
}
