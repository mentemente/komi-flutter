import 'package:flutter/material.dart';

import 'package:komi_fe/core/constants/app_colors.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Email (opcional)',
        prefixIcon: const Icon(Icons.email_outlined),
      ),
    );
  }
}
