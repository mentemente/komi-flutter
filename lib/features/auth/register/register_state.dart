import 'package:komi_fe/features/auth/models/auth_response.dart';

sealed class RegisterState {
  const RegisterState();
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess(this.response);
  final AuthResponse response;
}

final class RegisterError extends RegisterState {
  const RegisterError(this.message);
  final String message;
}
