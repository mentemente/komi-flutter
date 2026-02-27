class AuthStore {
  final String id;
  final String name;

  const AuthStore({required this.id, required this.name});

  factory AuthStore.fromJson(Map<String, dynamic> json) {
    return AuthStore(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
