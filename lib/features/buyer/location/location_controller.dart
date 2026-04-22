import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:komi_fe/features/buyer/location/location_service.dart';
import 'package:komi_fe/features/buyer/location/location_state.dart';

class LocationPermissionController {
  LocationPermissionController({
    required LocationService service,
    required VoidCallback onNavigateToRestaurants,
  }) : _service = service,
       _onNavigateToRestaurants = onNavigateToRestaurants;

  final LocationService _service;
  final VoidCallback _onNavigateToRestaurants;

  final ValueNotifier<LocationPermissionState> state = ValueNotifier(
    const LocationPermissionInitial(),
  );

  Future<void> requestPermission() async {
    state.value = const LocationPermissionLoading();

    try {
      final enabled = await _service.isLocationServiceEnabled();
      if (!enabled) {
        state.value = const LocationPermissionError(
          'Activa el GPS o la ubicación en tu dispositivo.',
        );
        return;
      }

      var permission = await _service.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _service.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        state.value = const LocationPermissionDenied(
          'Permiso denegado de forma permanente. Actívalo en ajustes.',
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        state.value = const LocationPermissionDenied('Permiso denegado.');
        return;
      }

      await _service.getCurrentPosition();
      state.value = const LocationPermissionGranted();
      _onNavigateToRestaurants();
    } catch (e, stack) {
      debugPrint('[LocationPermissionController] Error: $e');
      debugPrint('[LocationPermissionController] Stack: $stack');
      state.value = LocationPermissionError(e.toString());
    }
  }

  void denyPermission() {
    state.value = const LocationPermissionDenied();
  }

  void resetToInitial() {
    state.value = const LocationPermissionInitial();
  }

  void dispose() {
    state.dispose();
  }
}
