import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:komi_fe/core/constants/app_colors.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput({super.key, required this.controller, this.validator});

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Número de teléfono',
        prefixIcon: Icon(Icons.phone),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu número de teléfono';
            }
            if (value.length != 9) return 'El número debe tener 9 dígitos';
            return null;
          },
    );
  }
}
