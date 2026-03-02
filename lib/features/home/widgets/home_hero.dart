import 'package:flutter/material.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/logo.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key, this.logoFontSize = 72});

  final double logoFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Logo(fontSize: logoFontSize),
        const SizedBox(height: 24),
        Text(
          '¿Qué vas a comer hoy?',
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
