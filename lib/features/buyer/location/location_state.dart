/// Estado de la pantalla de permiso de ubicación.
sealed class LocationPermissionState {
  const LocationPermissionState();
}

final class LocationPermissionInitial extends LocationPermissionState {
  const LocationPermissionInitial();
}

final class LocationPermissionLoading extends LocationPermissionState {
  const LocationPermissionLoading();
}

final class LocationPermissionDenied extends LocationPermissionState {
  const LocationPermissionDenied([this.message = '']);
  final String message;
}

final class LocationPermissionGranted extends LocationPermissionState {
  const LocationPermissionGranted();
}

final class LocationPermissionError extends LocationPermissionState {
  const LocationPermissionError(this.message);
  final String message;
}
