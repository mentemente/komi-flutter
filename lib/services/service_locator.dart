import 'package:komi_fe/services/api_client.dart';
import 'package:komi_fe/services/auth_service.dart';

abstract final class ServiceLocator {
  static final apiClient = ApiClient(
    baseUrl: 'https://mms-komi-qa.up.railway.app',
  );

  static final authService = AuthService(apiClient);
}
