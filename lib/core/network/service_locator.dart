import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/auth/login/login_service.dart';
import 'package:komi_fe/features/auth/register/register_service.dart';

abstract final class ServiceLocator {
  ServiceLocator._();

  static final httpClient = HttpClient(
    baseUrl: 'https://mms-komi-qa.up.railway.app',
  );

  static final loginService = LoginService(httpClient);
  static final registerService = RegisterService(httpClient);
}
