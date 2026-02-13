import 'package:komi_fe/models/auth_store_dto.dart';
import 'package:komi_fe/models/user_type.dart';

class AuthResponseDto {
  final String token;
  final String phone;
  final UserType type;
  final String name;
  final List<AuthStoreDto> stores;

  const AuthResponseDto({
    required this.token,
    required this.phone,
    required this.type,
    required this.name,
    required this.stores,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String,
      phone: json['phone'] as String,
      type: UserType.fromString(json['type'] as String),
      name: json['name'] as String,
      stores: (json['stores'] as List<dynamic>)
          .map((e) => AuthStoreDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
