import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'widgets/overview_orders_section.dart';
import 'widgets/overview_stats_bar.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menú Luisa', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              const OverviewStatsBar(),
              const SizedBox(height: 28),
              const OverviewOrdersSection(),
              const SizedBox(height: 8),
              _SectionHeader(title: 'Menú /Carta', onTap: () {}),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: AppTextStyles.h3),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'ver mas',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textGray,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textGray,
            ),
          ),
        ),
      ],
    );
  }
}
