import 'package:komi_fe/models/auth_response_dto.dart';
import 'package:komi_fe/models/user_type.dart';
import 'package:komi_fe/services/api_client.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  Future<AuthResponseDto> login({
    required String phone,
    required String password,
  }) async {
    final response = await _api.post(
      '/v1/auth/login',
      fromJson: AuthResponseDto.fromJson,
      body: {'phone': phone, 'password': password},
    );
    _api.setToken(response.token);
    return response;
  }

  Future<AuthResponseDto> register({
    required String phone,
    required String password,
    required String name,
    required UserType type,
    String? email,
  }) async {
    final response = await _api.post(
      '/v1/auth/signup',
      fromJson: AuthResponseDto.fromJson,
      body: {'phone': phone, 'password': password, 'name': name, 'type': type.name, 'email': email},
    );
    _api.setToken(response.token);
    return response;
  }
}
