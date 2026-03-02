import 'package:flutter/foundation.dart';

import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/auth/login/login_service.dart';
import 'package:komi_fe/features/auth/login/login_state.dart';

class LoginController {
  LoginController(this._service);

  final LoginService _service;

  final ValueNotifier<LoginState> state = ValueNotifier<LoginState>(
    const LoginInitial(),
  );

  bool validate(String phone, String password) {
    return phone.length >= 7 && password.length >= 6;
  }

  Future<void> submit(String phone, String password) async {
    if (!validate(phone, password)) return;

    state.value = const LoginLoading();

    try {
      final response = await _service.login(
        phone: phone.trim(),
        password: password,
      );
      state.value = LoginSuccess(response);
    } on ApiException catch (e) {
      state.value = LoginError(e.displayMessage);
    } catch (_) {
      state.value = const LoginError('Error de conexión. Intenta de nuevo.');
    }
  }

  void reset() {
    state.value = const LoginInitial();
  }

  void dispose() {
    state.dispose();
  }
}
