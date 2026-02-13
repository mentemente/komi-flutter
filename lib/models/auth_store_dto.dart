class AuthStoreDto {
  final String id;
  final String name;

  const AuthStoreDto({required this.id, required this.name});

  factory AuthStoreDto.fromJson(Map<String, dynamic> json) {
    return AuthStoreDto(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
