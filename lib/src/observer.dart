/// WGS84 site and local atmospheric settings. Height is in metres; longitude
/// is east-positive. Validation is applied by the selected visibility API.
class Observer {
  final double longitudeDeg,
      latitudeDeg,
      heightMeters,
      pressureMbar,
      temperatureCelsius;
  const Observer({
    required this.longitudeDeg,
    required this.latitudeDeg,
    this.heightMeters = 0,
    this.pressureMbar = 1013.25,
    this.temperatureCelsius = 15,
  });
}

// Internal: the two upstream visibility solvers have different accepted
// atmosphere/height ranges. Preserve that distinction during the port.
void validateVisibilityObserver(Observer o, {bool solar = false}) {
  if (!o.longitudeDeg.isFinite ||
      !o.latitudeDeg.isFinite ||
      o.longitudeDeg.abs() > 180 ||
      o.latitudeDeg.abs() > 90) {
    throw RangeError('observer requires longitudeDeg ±180 and latitudeDeg ±90');
  }
  if (!o.heightMeters.isFinite ||
      !o.pressureMbar.isFinite ||
      !o.temperatureCelsius.isFinite) {
    throw ArgumentError('height and atmosphere must be finite');
  }
  if (solar
      ? o.pressureMbar <= 0
      : o.heightMeters <= -6370000 ||
            o.pressureMbar < 0 ||
            o.temperatureCelsius <= -273) {
    throw RangeError('invalid height or atmosphere');
  }
}

enum AltitudeState { notFound, crosses, alwaysAbove, alwaysBelow, tangent }

enum DiscLimb { upper, center, lower }
