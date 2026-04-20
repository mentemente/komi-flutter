import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class NoNearbyStoresView extends StatelessWidget {
  const NoNearbyStoresView({
    super.key,
    required this.onRetry,
    this.searchText,
    this.onClearSearch,
  });

  final VoidCallback onRetry;
  final String? searchText;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final q = searchText?.trim();
    final hasQuery = q != null && q.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'No encontramos tiendas cercanas',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasQuery
                        ? 'No hay resultados para "$q" en tu zona. Prueba con otra búsqueda o quita los filtros.'
                        : 'No hay tiendas disponibles cerca de tu ubicación. Intenta nuevamente en unos minutos o cambia de zona.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (hasQuery && onClearSearch != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onClearSearch,
                child: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
