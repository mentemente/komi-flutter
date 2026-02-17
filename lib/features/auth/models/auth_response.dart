import 'package:komi_fe/features/auth/models/auth_store.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';

class AuthResponse {
  final String token;
  final String phone;
  final UserType type;
  final String name;
  final List<AuthStore> stores;

  const AuthResponse({
    required this.token,
    required this.phone,
    required this.type,
    required this.name,
    required this.stores,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      phone: json['phone'] as String,
      type: UserType.fromString(json['type'] as String),
      name: json['name'] as String,
      stores: (json['stores'] as List<dynamic>)
          .map((e) => AuthStore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'phone': phone,
      'type': type.name,
      'name': name,
      'stores': stores.map((e) => e.toJson()).toList(),
    };
  }
}
