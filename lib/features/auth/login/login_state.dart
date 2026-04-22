import 'package:komi_fe/features/auth/models/auth_response.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.response);
  final AuthResponse response;
}

final class LoginError extends LoginState {
  const LoginError(this.message);
  final String message;
}
