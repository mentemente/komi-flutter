import 'package:flutter/foundation.dart';

import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';
import 'package:komi_fe/features/auth/register/register_service.dart';
import 'package:komi_fe/features/auth/register/register_state.dart';

class RegisterController {
  RegisterController(this._service);

  final RegisterService _service;

  final ValueNotifier<RegisterState> state = ValueNotifier<RegisterState>(
    const RegisterInitial(),
  );

  bool validate({
    required String name,
    required String phone,
    required String password,
  }) {
    return name.length >= 3 && phone.length >= 7 && password.length >= 6;
  }

  Future<void> submit({
    required String name,
    required String phone,
    required String password,
    required UserType userType,
    String? email,
  }) async {
    if (!validate(name: name, phone: phone, password: password)) return;

    state.value = const RegisterLoading();

    try {
      final response = await _service.register(
        name: name.trim(),
        phone: phone.trim(),
        password: password,
        type: userType,
        email: email?.trim().isEmpty ?? true ? null : email?.trim(),
      );
      state.value = RegisterSuccess(response);
    } on ApiException catch (e) {
      state.value = RegisterError(e.displayMessage);
    } catch (_) {
      state.value = const RegisterError('Error de conexión. Intenta de nuevo.');
    }
  }

  void reset() {
    state.value = const RegisterInitial();
  }

  void dispose() {
    state.dispose();
  }
}
