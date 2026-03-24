import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:komi_fe/core/constants/app_colors.dart';

class NameInput extends StatelessWidget {
  const NameInput({
    super.key,
    required this.controller,
    this.validator,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      maxLength: 20,
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
      decoration: const InputDecoration(
        labelText: 'Nombre',
        prefixIcon: Icon(Icons.person),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa tu nombre';
            }
            if (value.trim().length < 4) {
              return 'El nombre debe tener al menos 4 caracteres';
            }
            return null;
          },
    );
  }
}
