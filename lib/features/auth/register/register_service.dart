import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';

class RegisterService {
  final HttpClient _client;

  RegisterService(this._client);

  Future<AuthResponse> register({
    required String phone,
    required String password,
    required String name,
    required UserType type,
    String? email,
  }) async {
    final response = await _client.post(
      '/v1/auth/signup',
      fromJson: AuthResponse.fromJson,
      body: {
        'phone': phone,
        'password': password,
        'name': name,
        'type': type.name,
        'email': email,
      },
    );
    _client.setToken(response.token);
    return response;
  }
}
