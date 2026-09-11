/// J2000.0 历元的 TT 儒略日：2451545.0。
const j2000 = 2451545.0;

/// 一个天文单位对应的千米数：149597870.7。
const auKm = 149597870.7;

/// 地球与月球质量比，用于地球、月球和地月质心之间的转换。
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
  /// 三维位置和解析速度，分量顺序为 x、y、z，列表不可修改。
  ///
  /// 行星及日心状态为 AU、AU/day；地心月球为 km、km/day。
  /// 方向状态则为无量纲单位向量及其每日导数。
  final List<double> position, velocity;
  CartesianState(List<double> position, List<double> velocity)
    : position = List.unmodifiable(position),
      velocity = List.unmodifiable(velocity);
}
