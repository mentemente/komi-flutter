import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_state.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_provider.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_state.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_controller.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/executive_dish_tile.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/main_course_tile.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/restaurant_detail_header.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/restaurant_detail_load_error_body.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/restaurant_menu_mode_tab.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/restaurant_order_cart_bar.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/store_closed_today_panel.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/widgets/store_open_status_banner.dart';

class RestaurantDetailPage extends ConsumerStatefulWidget {
  const RestaurantDetailPage({
    super.key,
    required this.storeId,
    this.storeName = '',
  });

  final String storeId;
  final String storeName;

  @override
  ConsumerState<RestaurantDetailPage> createState() =>
      _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends ConsumerState<RestaurantDetailPage> {
  late final RestaurantDetailController _controller;

  int _selectedTab = 0;
  String? _expandedDishId;
  String? _selectedAppetizerId;
  String? _selectedBeverageId;
  String? _selectedDessertId;
  final List<MenuCartEntry> _menuCart = [];
  final Map<String, int> _execCounts = {};

  @override
  void initState() {
    super.initState();
    _controller = RestaurantDetailController(
      ServiceLocator.restaurantDetailService,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.load(widget.storeId),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── cart helpers ─────────────────────────────────────────────────────────

  int _menuCount(String dishId) =>
      _menuCart.where((e) => e.mainCourse.id == dishId).length;

  bool get _hasCartItems =>
      _menuCart.isNotEmpty || _execCounts.values.any((c) => c > 0);

  double _calcSubtotal(MenuDishes dishes) {
    double total = 0;
    for (final e in _menuCart) {
      total += e.mainCourse.price;
    }
    for (final entry in _execCounts.entries) {
      DishItem? dish;
      for (final d in dishes.executiveDish) {
        if (d.id == entry.key) {
          dish = d;
          break;
        }
      }
      if (dish != null) total += dish.price * entry.value;
    }
    return total;
  }

  void _addMenuCartItem(DishItem mainCourse, MenuDishes dishes) {
    DishItem? appetizer;
    DishItem? beverage;
    DishItem? dessert;

    if (_selectedAppetizerId != null) {
      for (final a in dishes.appetizer) {
        if (a.id == _selectedAppetizerId) {
          appetizer = a;
          break;
        }
      }
    }
    if (_selectedBeverageId != null) {
      for (final b in dishes.beverage) {
        if (b.id == _selectedBeverageId) {
          beverage = b;
          break;
        }
      }
    }
    if (_selectedDessertId != null) {
      for (final d in dishes.dessert) {
        if (d.id == _selectedDessertId) {
          dessert = d;
          break;
        }
      }
    }

    setState(() {
      _menuCart.add(
        MenuCartEntry(
          mainCourse: mainCourse,
          appetizer: appetizer,
          beverage: beverage,
          dessert: dessert,
        ),
      );
      _expandedDishId = null;
      _selectedAppetizerId = null;
      _selectedBeverageId = null;
      _selectedDessertId = null;
    });
  }

  void _toggleMenuExpansion(String dishId) {
    setState(() {
      if (_expandedDishId == dishId) {
        _expandedDishId = null;
      } else {
        _expandedDishId = dishId;
      }
      _selectedAppetizerId = null;
      _selectedBeverageId = null;
      _selectedDessertId = null;
    });
  }

  void _addExecDish(DishItem dish) {
    setState(() => _execCounts[dish.id] = (_execCounts[dish.id] ?? 0) + 1);
  }

  void _removeExecDish(String dishId) {
    setState(() {
      final cur = _execCounts[dishId] ?? 0;
      if (cur > 1) {
        _execCounts[dishId] = cur - 1;
      } else {
        _execCounts.remove(dishId);
      }
    });
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loggedIn = ref.watch(authSessionProvider) != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MobileViewportContainer(
        backgroundColor: AppColors.background,
        panelColor: AppColors.background,
        child: SafeArea(
          child: ValueListenableBuilder<RestaurantDetailState>(
            valueListenable: _controller.state,
            builder: (context, state, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RestaurantDetailHeader(
                    title: state is RestaurantDetailReady
                        ? state.menu.store.name
                        : widget.storeName,
                    loggedIn: loggedIn,
                  ),
                  Expanded(child: _buildBody(state)),
                  if (_hasCartItems && state is RestaurantDetailReady)
                    _buildCartBottomBar(state.menu),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RestaurantDetailState state) {
    return switch (state) {
      RestaurantDetailLoading() => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      RestaurantDetailStoreClosedToday(:final weekdayKey) =>
        StoreClosedTodayPanel(weekdayKey: weekdayKey),
      RestaurantDetailError(:final message) => RestaurantDetailLoadErrorBody(
        message: message,
        onRetry: () => _controller.load(widget.storeId),
      ),
      RestaurantDetailReady(:final menu) => _buildReadyBody(menu),
    };
  }

  Widget _buildReadyBody(StoreMenu menu) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StoreOpenStatusBanner(store: menu.store),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 28,
              color: AppColors.textGray.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Menú del dia',
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _buildTabSelector(),
                const SizedBox(height: 20),
                if (_selectedTab == 0)
                  _buildMenuTab(menu.dishes)
                else
                  _buildALaCarteTab(menu.dishes),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        Expanded(
          child: RestaurantMenuModeTab(
            label: 'Menus',
            icon: Icons.restaurant_menu_rounded,
            description: 'Incluye plato de fondo, entrada y bebida',
            isSelected: _selectedTab == 0,
            onTap: () => setState(() {
              _selectedTab = 0;
              _expandedDishId = null;
              _selectedAppetizerId = null;
              _selectedBeverageId = null;
              _selectedDessertId = null;
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RestaurantMenuModeTab(
            label: 'Platos a la carta',
            icon: Icons.room_service_outlined,
            description: 'Platos con un precio más elevado',
            isSelected: _selectedTab == 1,
            onTap: () => setState(() {
              _selectedTab = 1;
              _expandedDishId = null;
              _selectedAppetizerId = null;
              _selectedBeverageId = null;
              _selectedDessertId = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTab(MenuDishes dishes) {
    if (dishes.mainCourse.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'No hay platos de fondo disponibles.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Platos de fondo:',
          style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final dish in dishes.mainCourse)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MainCourseTile(
              dish: dish,
              count: _menuCount(dish.id),
              isExpanded: _expandedDishId == dish.id,
              appetizers: dishes.appetizer,
              beverages: dishes.beverage,
              desserts: dishes.dessert,
              selectedAppetizerId: _selectedAppetizerId,
              selectedBeverageId: _selectedBeverageId,
              selectedDessertId: _selectedDessertId,
              onToggle: () => _toggleMenuExpansion(dish.id),
              onAppetizerSelected: (id) => setState(() {
                _selectedAppetizerId = _selectedAppetizerId == id ? null : id;
              }),
              onBeverageSelected: (id) => setState(() {
                _selectedBeverageId = _selectedBeverageId == id ? null : id;
              }),
              onDessertSelected: (id) => setState(() {
                _selectedDessertId = _selectedDessertId == id ? null : id;
              }),
              onAgregar: () => _addMenuCartItem(dish, dishes),
            ),
          ),
      ],
    );
  }

  Widget _buildALaCarteTab(MenuDishes dishes) {
    if (dishes.executiveDish.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'No hay platos a la carta disponibles.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Platos a la carta:',
          style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final dish in dishes.executiveDish)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExecutiveDishTile(
              dish: dish,
              count: _execCounts[dish.id] ?? 0,
              onAdd: () => _addExecDish(dish),
              onRemove: () => _removeExecDish(dish.id),
            ),
          ),
      ],
    );
  }

  bool get _hasAuthToken {
    final session = ref.read(authSessionProvider);
    return session != null && session.token.trim().isNotEmpty;
  }

  Future<void> _showLoginRequiredDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inicia sesión',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Para continuar con tu pedido necesitas iniciar sesión.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Iniciar sesión',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar(StoreMenu menu) {
    final subtotal = _calcSubtotal(menu.dishes);
    final priceStr = subtotal % 1 == 0
        ? 's/${subtotal.toInt()}'
        : 's/${subtotal.toStringAsFixed(2)}';
    return RestaurantOrderCartBar(
      subtotalLabel: priceStr,
      onVerifyOrder: () async {
        if (!_hasAuthToken) {
          await _showLoginRequiredDialog();
          return;
        }
        double userLat = 0.0, userLng = 0.0;
        try {
          final pos = await ServiceLocator.locationService.getCurrentPosition();
          userLat = pos.latitude;
          userLng = pos.longitude;
        } catch (_) {}
        if (!mounted) return;
        ref
            .read(checkoutProvider.notifier)
            .initialize(
              CheckoutInput(
                menuCart: List.from(_menuCart),
                execCounts: Map.from(_execCounts),
                dishes: menu.dishes,
                storeInfo: menu.store,
                storeId: widget.storeId,
                userLat: userLat,
                userLng: userLng,
              ),
            );
        if (!mounted) return;
        context.push(RouteNames.checkout);
      },
    );
  }
}
