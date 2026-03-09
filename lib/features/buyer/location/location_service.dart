import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio de ubicación (Geolocator). Sin lógica de UI.
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
    return position;
  }
}
