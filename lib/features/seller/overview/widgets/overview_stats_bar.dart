import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class OverviewStatsBar extends StatelessWidget {
  const OverviewStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatChip(value: '3', label: 'Pedidos de hoy', highlighted: false),
          const SizedBox(width: 8),
          _StatChip(value: '2', label: 'Activos', highlighted: true),
          const SizedBox(width: 8),
          _StatChip(value: 'S/11', label: 'Por cobrar', highlighted: true),
          const SizedBox(width: 8),
          _StatChip(value: 'S/58', label: 'Ingresos', highlighted: false),
          const SizedBox(width: 8),
          _StatChip(value: '1', label: 'Completados', highlighted: false),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final bool highlighted;

  const _StatChip({
    required this.value,
    required this.label,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF5C842);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? amber : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted ? amber : const Color(0xFFDDDDDD),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 10,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
