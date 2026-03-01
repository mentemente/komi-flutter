enum UserType {
  buyer,
  seller;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserType.buyer,
    );
  }
}
