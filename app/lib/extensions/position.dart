import 'package:geolocator/geolocator.dart';

extension AsLatLonList on Position {
  List<double> asLatLonList() => [latitude, longitude];
}
