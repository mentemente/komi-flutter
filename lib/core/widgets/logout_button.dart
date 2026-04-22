import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

/// Botón de salida: icono + «Salir». Limpia token y usuario en almacenamiento local
/// ([AuthSessionNotifier.clear]) and navigates to [RouteNames.login].
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        await ref.read(authSessionProvider.notifier).clear();
        if (!context.mounted) return;
        context.go(RouteNames.login);
      },
      icon: const Icon(Icons.logout, size: 18, color: AppColors.textDark),
      label: Text(
        'Salir',
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.textDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
