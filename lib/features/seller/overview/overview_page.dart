import 'package:flutter/material.dart';
import 'widgets/overview_stats_bar.dart';
import 'package:go_router/go_router.dart';
import 'widgets/overview_orders_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/menu_item_card.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/core/widgets/title_profile_header.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  List<DailyMenuItem> _menuItems = [];
  bool _menuLoading = true;
  String? _menuError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMenuPreview());
  }

  Future<void> _loadMenuPreview() async {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId = (stores != null && stores.isNotEmpty)
        ? stores.first.id
        : null;

    if (storeId == null || storeId.isEmpty) {
      if (mounted) {
        setState(() {
          _menuError = 'No se encontró la tienda.';
          _menuLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _menuLoading = true;
        _menuError = null;
      });
    }

    try {
      final list = await ServiceLocator.dailyMenuService.listFoods(
        storeId: storeId,
      );
      if (!mounted) return;
      setState(() {
        _menuItems = list;
        _menuLoading = false;
        _menuError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _menuError = e.displayMessage;
        _menuLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _menuError = '$e';
        _menuLoading = false;
      });
    }
  }

  Future<void> _onMenuActiveChanged(DailyMenuItem item, bool value) async {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId = (stores != null && stores.isNotEmpty)
        ? stores.first.id
        : null;
    final id = item.id;

    if (storeId == null || storeId.isEmpty || id == null || id.isEmpty) {
      if (!mounted) return;
      setState(() => item.isActive = value);
      return;
    }

    final previous = item.isActive;
    if (!mounted) return;
    setState(() => item.isActive = value);

    try {
      final updated = await ServiceLocator.foodService.patchFood(
        storeId: storeId,
        foodId: id,
        isActive: value,
      );
      if (!mounted) return;
      setState(() {
        item.name = updated.name;
        item.price = updated.price;
        item.stock = updated.stock;
        item.isActive = updated.isActive;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => item.isActive = previous);
      rethrow;
    } catch (e) {
      if (!mounted) return;
      setState(() => item.isActive = previous);
      rethrow;
    }
  }

  void _onMenuSave(DailyMenuItem item, String name, double? price, int stock) {
    setState(() {
      item.name = name;
      item.price = price;
      item.stock = stock;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeName = ref.watch(authSessionProvider)?.stores.first.name;
    final menuTitle = (storeName != null && storeName.isNotEmpty)
        ? storeName
        : 'Menú';

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
              const OverviewStatsBar(),
              const SizedBox(height: 28),
              const OverviewOrdersSection(),
              const SizedBox(height: 8),
              _SectionHeader(
                title: 'Menú / Carta',
                onTap: () =>
                    context.go('${RouteNames.seller}${RouteNames.dailyMenu}'),
              ),
              const SizedBox(height: 12),
              if (_menuLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_menuError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _menuError!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadMenuPreview,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else if (_menuItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Aún no hay platos en la carta.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                )
              else
                ..._menuItems.map(
                  (item) => MenuItemCard(
                    item: item,
                    onActiveChanged: (v) => _onMenuActiveChanged(item, v),
                    onSave: (i, name, price, stock) =>
                        _onMenuSave(i, name, price, stock),
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
        Text(title, style: AppTextStyles.h4),
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
