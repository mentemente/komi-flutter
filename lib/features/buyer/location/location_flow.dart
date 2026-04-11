import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:komi_fe/features/buyer/location/location_service.dart';

Future<bool> ensureLocationPermissionForRestaurants({
  LocationService? service,
}) async {
  final s = service ?? LocationService();
  try {
    final enabled = await s.isLocationServiceEnabled();
    if (!enabled) {
      return false;
    }

    var permission = await s.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await s.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }

    await s.getCurrentPosition();
    return true;
  } catch (e, stack) {
    debugPrint('[ensureLocationPermissionForRestaurants] $e');
    debugPrint('[ensureLocationPermissionForRestaurants] $stack');
    return false;
  }
}
