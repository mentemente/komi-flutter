import 'package:flutter/material.dart';
import 'package:komi_fe/theme/app_text_styles.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Mis Platos',
          style: AppTextStyles.h2,
        ),
      ),
    );
  }
}
