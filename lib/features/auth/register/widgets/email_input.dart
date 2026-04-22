import 'package:flutter/material.dart';

import 'package:komi_fe/core/constants/app_colors.dart';

final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

class EmailInput extends StatelessWidget {
  const EmailInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: const InputDecoration(
        labelText: 'Email (opcional)',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        if (!_emailRegex.hasMatch(value.trim())) {
          return 'Ingresa un email válido';
        }
        return null;
      },
    );
  }
}
