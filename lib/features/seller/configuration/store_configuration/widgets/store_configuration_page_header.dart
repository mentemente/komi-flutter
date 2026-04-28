import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/profile_menu_button.dart';

/// Cabecera de la pantalla de configuración de tienda (volver, título, menú perfil).
class StoreConfigurationPageHeader extends ConsumerWidget {
  const StoreConfigurationPageHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ProfileMenuButton.size,
            child: Material(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('${RouteNames.seller}${RouteNames.overview}');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Volver',
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Configuración de tienda',
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const ProfileMenuButton(),
        ],
      ),
    );
  }
}
