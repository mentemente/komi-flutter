import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';

class LoginService {
  final HttpClient _client;

  LoginService(this._client);

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      '/v1/auth/login',
      fromJson: AuthResponse.fromJson,
      body: {'phone': phone, 'password': password},
    );
    _client.setToken(response.token);
    return response;
  }

  void logout() {
    _client.setToken(null);
  }
}
