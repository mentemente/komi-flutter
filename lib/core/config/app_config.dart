abstract final class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static const xApiKey = String.fromEnvironment('X_API_KEY');
}
