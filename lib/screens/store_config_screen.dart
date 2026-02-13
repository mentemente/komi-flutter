import 'package:flutter/material.dart';
import 'package:komi_fe/theme/app_text_styles.dart';

class StoreConfigScreen extends StatelessWidget {
  const StoreConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KOMI', style: AppTextStyles.h3)),
      body: const Center(
        child: Text(
          'CONFIGURACIÓN DE TIENDA',
          style: AppTextStyles.h2,
        ),
      ),
    );
  }
}
