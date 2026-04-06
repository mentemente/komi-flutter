import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_state.dart';
import 'package:komi_fe/features/seller/daily_menu/widgets/daily_menu_grouped_sections.dart';

/// Main content according to [DailyMenuState] (loading, error or grouped list).
class DailyMenuBody extends StatelessWidget {
  const DailyMenuBody({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onActiveChanged,
    required this.onSave,
  });

  final DailyMenuState state;
  final VoidCallback onRetry;
  final Future<void> Function(DailyMenuItem item, bool value) onActiveChanged;
  final void Function(DailyMenuItem item, String name, double? price, int stock)
  onSave;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DailyMenuLoading() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      DailyMenuError(:final message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message, style: const TextStyle(color: AppColors.textDark)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
      DailyMenuReady(:final items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailyMenuGroupedSections(
            items: items,
            onActiveChanged: onActiveChanged,
            onSave: onSave,
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No hay platos en el menú.\nPublica desde «Mis platos».',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGray.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    };
  }
}
