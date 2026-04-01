import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/dishes/widgets/daily_dish_card.dart';

class DailyDishesBody extends StatelessWidget {
  const DailyDishesBody({
    super.key,
    required this.dailyDishes,
    this.onEditItem,
    this.onDeleteItem,
  });

  final List<DailyMenuItem> dailyDishes;
  final void Function(int index, DailyMenuItem item)? onEditItem;
  final void Function(int index)? onDeleteItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dailyDishes.isNotEmpty) ...[
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
                onPressed: () {},
                child: const Text('Públicar menú de hoy'),
              ),
            ),
          ] else ...[
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
              'Agrega platos manualmente, desde tu historial\n'
              'o subiendo una foto del menú para detectar tus platos.\n'
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
