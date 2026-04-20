import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/menu_item_card.dart';
import 'package:komi_fe/core/widgets/title_profile_header.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/overview/overview_controller.dart';
import 'package:komi_fe/features/seller/overview/overview_service.dart';
import 'package:komi_fe/features/seller/overview/overview_state.dart';
import 'package:komi_fe/features/seller/overview/widgets/overview_menu_empty_state.dart';
import 'package:komi_fe/features/seller/overview/widgets/overview_orders_section.dart';
import 'package:komi_fe/features/seller/overview/widgets/overview_section_header.dart';
import 'package:komi_fe/features/seller/overview/widgets/overview_stats_bar.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  late final OverviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OverviewController(
      OverviewService(
        ServiceLocator.dailyMenuService,
        ServiceLocator.foodService,
      ),
    );
    _controller.menuState.addListener(_onMenuStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoad());
  }

  void _onMenuStateChanged() {
    if (mounted) setState(() {});
  }

  void _startLoad() {
    final session = ref.read(authSessionProvider);
    final storeId = session?.stores.isNotEmpty == true
        ? session!.stores.first.id
        : null;
    _controller.loadMenu(storeId: storeId);
  }

  String? _storeId() {
    final session = ref.read(authSessionProvider);
    return session?.stores.isNotEmpty == true ? session!.stores.first.id : null;
  }

  Future<void> _onMenuActiveChanged(DailyMenuItem item, bool value) async {
    try {
      await _controller.setItemActive(item, value, storeId: _storeId());
    } catch (_) {}
  }

  void _onMenuSave(DailyMenuItem item, String name, double? price, int stock) {
    _controller.saveItemFields(item, name, price, stock);
  }

  @override
  void dispose() {
    _controller.menuState.removeListener(_onMenuStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeName = ref.watch(authSessionProvider)?.stores.first.name;
    final menuTitle = (storeName != null && storeName.isNotEmpty)
        ? storeName
        : 'Menú';

    final menu = _controller.menuState.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleProfileHeader(title: menuTitle),
              const SizedBox(height: 16),
              if (menu is OverviewMenuEmpty)
                OverviewMenuEmptyState(
                  onUploadTap: () =>
                      context.go('${RouteNames.seller}${RouteNames.dishes}'),
                )
              else ...[
                // TODO: Implement stats bar
                // const OverviewStatsBar(),
                const OverviewOrdersSection(),
                const SizedBox(height: 8),
                OverviewSectionHeader(
                  title: 'Menú / Carta',
                  onTap: () =>
                      context.go('${RouteNames.seller}${RouteNames.dailyMenu}'),
                ),
                const SizedBox(height: 12),
                _buildMenuSection(menu),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(OverviewMenuState menu) {
    if (menu is OverviewMenuLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (menu is OverviewMenuError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              menu.message,
              style: AppTextStyles.body.copyWith(color: AppColors.textGray),
            ),
            TextButton(onPressed: _startLoad, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (menu is OverviewMenuReady) {
      return Column(
        children: menu.items
            .map(
              (item) => MenuItemCard(
                item: item,
                onActiveChanged: (v) => _onMenuActiveChanged(item, v),
                onSave: (i, name, price, stock) =>
                    _onMenuSave(i, name, price, stock),
              ),
            )
            .toList(),
      );
    }
    return const SizedBox.shrink();
  }
}
