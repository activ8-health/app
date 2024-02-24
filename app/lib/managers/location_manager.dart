import "package:geolocator/geolocator.dart";

class LocationManager {
  // Set up singleton
  static final LocationManager instance = LocationManager._create();

  LocationManager._create();

  Future<Position> getLocation() async {
    // Check cache for location
    Position? location = await Geolocator.getLastKnownPosition();

    // Fallback to getting the actual location
    location ??= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return location;
  }
}
