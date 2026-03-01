import 'package:flutter/material.dart';

import 'package:komi_fe/core/constants/app_colors.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleObscure,
    this.validator,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleObscure,
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
    );
  }
}
