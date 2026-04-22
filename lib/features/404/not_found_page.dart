import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ollin_404.webp',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.search_off_rounded,
                    size: 120,
                    color: AppColors.textGray.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '404',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Página no encontrada',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'La ruta que buscas no existe. Volvamos al inicio.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go(RouteNames.home),
                    child: const Text('Ir al inicio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
