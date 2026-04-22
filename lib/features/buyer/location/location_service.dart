import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    return enabled;
  }

  Future<LocationPermission> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission;
  }

  Future<LocationPermission> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission;
  }

  Future<Position> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (kDebugMode) {
      debugPrint('[LocationService] latitud: ${position.latitude}');
      debugPrint('[LocationService] longitud: ${position.longitude}');
      debugPrint('[LocationService] altitud (m): ${position.altitude}');
      debugPrint(
        '[LocationService] precisión horizontal (m): ${position.accuracy}',
      );
    }
    return position;
  }
}
