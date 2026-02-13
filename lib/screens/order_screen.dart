import 'package:flutter/material.dart';
import 'package:komi_fe/theme/app_text_styles.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KOMI', style: AppTextStyles.h3)),
      body: const Center(
        child: Text(
          'ORDENES>',
          style: AppTextStyles.h2,
        ),
      ),
    );
  }
}
