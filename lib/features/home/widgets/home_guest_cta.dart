import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class HomeGuestCta extends StatelessWidget {
  const HomeGuestCta({super.key, required this.onRegisterPressed});

  final VoidCallback? onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('¿Aun no tienes una cuenta?', style: AppTextStyles.subtitle1),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: AppTextStyles.caption,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: onRegisterPressed ?? () => context.go(RouteNames.register),
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }
}
