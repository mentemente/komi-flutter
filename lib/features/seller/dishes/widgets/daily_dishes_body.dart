import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/dishes/widgets/daily_dish_card.dart';

class DailyDishesBody extends StatelessWidget {
  const DailyDishesBody({
    super.key,
    required this.dailyDishes,
    this.catalogFoods = const [],
    this.catalogLoading = false,
    this.catalogError,
    this.onRetryCatalog,
    this.onEditItem,
    this.onDeleteItem,
    this.onPublishToday,
    this.isPublishing = false,
  });

  final List<DailyMenuItem> catalogFoods;
  final bool catalogLoading;
  final String? catalogError;
  final VoidCallback? onRetryCatalog;

  final List<DailyMenuItem> dailyDishes;
  final void Function(int index, DailyMenuItem item)? onEditItem;
  final void Function(int index)? onDeleteItem;
  final Future<void> Function()? onPublishToday;
  final bool isPublishing;

  @override
  Widget build(BuildContext context) {
    final showFullEmpty =
        dailyDishes.isEmpty &&
        catalogFoods.isEmpty &&
        !catalogLoading &&
        catalogError == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (catalogLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          if (catalogError != null) ...[
            Text(
              catalogError!,
              style: AppTextStyles.small.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
            if (onRetryCatalog != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetryCatalog,
                child: const Text('Reintentar'),
              ),
            ],
            const SizedBox(height: 12),
          ],
          if (catalogFoods.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Platos publicados',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...catalogFoods.map((d) => DailyDishCard(item: d, readOnly: true)),
            const SizedBox(height: 20),
          ],
          if (dailyDishes.isNotEmpty) ...[
            if (catalogFoods.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menú de hoy',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...dailyDishes.asMap().entries.map((entry) {
              final index = entry.key;
              final d = entry.value;
              return DailyDishCard(
                item: d,
                onEdit: onEditItem != null
                    ? (item) => onEditItem!(index, item)
                    : null,
                onDelete: onDeleteItem != null
                    ? (_) => onDeleteItem!(index)
                    : null,
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: isPublishing || onPublishToday == null
                    ? null
                    : () => onPublishToday!(),
                child: isPublishing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publicar menú de hoy'),
              ),
            ),
          ] else if (showFullEmpty) ...[
            Image.asset(
              'assets/images/ollin_con_plato.webp',
              width: 160,
              height: 160,
            ),
            const SizedBox(height: 20),
            Text(
              '¿Qué se cocina hoy?',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega platos manualmente, desde tu historial o subiendo una foto del menú para detectar tus platos. \n'
              'Siempre podrás revisarlos antes.',
              style: AppTextStyles.body.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ] else if (!catalogLoading &&
              catalogError == null &&
              catalogFoods.isNotEmpty) ...[
            Text(
              'Agrega platos manualmente, desde tu historial o subiendo una foto del menú para detectar tus platos. \n'
              'Siempre podrás revisarlos antes.',
              style: AppTextStyles.body.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
