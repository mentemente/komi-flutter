import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/menu_item_card.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'widgets/overview_orders_section.dart';
import 'widgets/overview_stats_bar.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  // TODO: change this to get the items from the API
  static final List<DailyMenuItem> _menuPreviewItems = [
    DailyMenuItem(
      name: 'Tequeños',
      stock: 20,
      isActive: true,
      type: MenuItemType.entrada,
    ),
    DailyMenuItem(
      name: 'Arroz con pollo',
      price: 12,
      stock: 15,
      isActive: true,
      type: MenuItemType.platoSegundo,
    ),
    DailyMenuItem(
      name: 'Lomo saltado',
      price: 17,
      stock: 8,
      isActive: true,
      type: MenuItemType.platoALaCarta,
    ),
  ];

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
              _SectionHeader(
                title: 'Menú /Carta',
                onTap: () =>
                    context.go('${RouteNames.seller}${RouteNames.dailyMenu}'),
              ),
              const SizedBox(height: 12),
              ..._menuPreviewItems.map(
                (item) => MenuItemCard(
                  item: item,
                  onActiveChanged: (_) {},
                  onSave: (_, _, _, _) {},
                ),
              ),
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
