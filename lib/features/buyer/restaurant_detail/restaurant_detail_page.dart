import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/logout_button.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_controller.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_state.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

const Color _kOpenDot = Color(0xFF2D9D5C);
const Color _kOpenBg = Color(0xFFDCF5E3);
const Color _kClosedDot = Color(0xFFD84040);
const Color _kClosedBg = Color(0xFFFBDFDB);
const Color _kCountGreen = Color(0xFF2D9D5C);

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
                  _buildHeader(state, loggedIn),
                  Expanded(child: _buildBody(state)),
                  if (_hasCartItems && state is RestaurantDetailReady)
                    _buildCartBottomBar(state.menu.dishes),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RestaurantDetailState state, bool loggedIn) {
    final name = state is RestaurantDetailReady
        ? state.menu.store.name
        : widget.storeName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(RouteNames.restaurants),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textDark,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.25),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (loggedIn) ...[
            const SizedBox(width: 8),
            const LogoutButton(),
          ] else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody(RestaurantDetailState state) {
    return switch (state) {
      RestaurantDetailLoading() => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      RestaurantDetailError(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _controller.load(widget.storeId),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
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
            child: _StatusBanner(store: menu.store),
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
          child: _TabOption(
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
          child: _TabOption(
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
            child: _MainCourseTile(
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
            child: _ExecutiveDishTile(
              dish: dish,
              count: _execCounts[dish.id] ?? 0,
              onAdd: () => _addExecDish(dish),
              onRemove: () => _removeExecDish(dish.id),
            ),
          ),
      ],
    );
  }

  Widget _buildCartBottomBar(MenuDishes dishes) {
    final subtotal = _calcSubtotal(dishes);
    final priceStr = subtotal % 1 == 0
        ? 's/${subtotal.toInt()}'
        : 's/${subtotal.toStringAsFixed(2)}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.textGray.withValues(alpha: 0.2)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de pedido próximamente'),
                    duration: Duration(seconds: 2),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Verificar pedido',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subtotal', style: AppTextStyles.small),
              Text(
                priceStr,
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── _StatusBanner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.store});

  final StoreMenuInfo store;

  @override
  Widget build(BuildContext context) {
    final isOpen = store.isOpenNow;
    final bg = isOpen ? _kOpenBg : _kClosedBg;
    final dot = isOpen ? _kOpenDot : _kClosedDot;
    final label = isOpen
        ? 'Abierto ahora · Cierra a las ${_formatTime(store.schedule.close)}'
        : 'Cerrado ahora';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                color: dot,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _TabOption ────────────────────────────────────────────────────────────────

class _TabOption extends StatelessWidget {
  const _TabOption({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.textDark : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textDark, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppColors.white : AppColors.textDark,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.small.copyWith(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.72)
                      : AppColors.textGray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _MainCourseTile ───────────────────────────────────────────────────────────

class _MainCourseTile extends StatelessWidget {
  const _MainCourseTile({
    required this.dish,
    required this.count,
    required this.isExpanded,
    required this.appetizers,
    required this.beverages,
    required this.desserts,
    required this.selectedAppetizerId,
    required this.selectedBeverageId,
    required this.selectedDessertId,
    required this.onToggle,
    required this.onAppetizerSelected,
    required this.onBeverageSelected,
    required this.onDessertSelected,
    required this.onAgregar,
  });

  final DishItem dish;
  final int count;
  final bool isExpanded;
  final List<DishItem> appetizers;
  final List<DishItem> beverages;
  final List<DishItem> desserts;
  final String? selectedAppetizerId;
  final String? selectedBeverageId;
  final String? selectedDessertId;
  final VoidCallback onToggle;
  final ValueChanged<String> onAppetizerSelected;
  final ValueChanged<String> onBeverageSelected;
  final ValueChanged<String> onDessertSelected;
  final VoidCallback onAgregar;

  bool get _hasAnyExtras =>
      appetizers.isNotEmpty || beverages.isNotEmpty || desserts.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? AppColors.textDark
              : AppColors.textGray.withValues(alpha: 0.3),
          width: isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fila principal: nombre + precio + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    dish.name,
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (dish.price > 0)
                  Text(
                    _formatPrice(dish.price),
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 8),
                _CountBadge(count: count, onTap: onToggle),
              ],
            ),

            if (isExpanded) ...[
              const SizedBox(height: 16),

              // ── Entradas ──────────────────────────────────────────────────
              if (appetizers.isNotEmpty) ...[
                _SectionHeader(label: 'Escoge tu entrada'),
                const SizedBox(height: 6),
                for (final item in appetizers)
                  _SelectableDishRow(
                    item: item,
                    isSelected: item.id == selectedAppetizerId,
                    onTap: () => onAppetizerSelected(item.id),
                  ),
                if (beverages.isNotEmpty || desserts.isNotEmpty)
                  const _SectionDivider(),
              ],

              // ── Bebidas ───────────────────────────────────────────────────
              if (beverages.isNotEmpty) ...[
                _SectionHeader(label: 'Escoge tu bebida'),
                const SizedBox(height: 6),
                for (final item in beverages)
                  _SelectableDishRow(
                    item: item,
                    isSelected: item.id == selectedBeverageId,
                    onTap: () => onBeverageSelected(item.id),
                  ),
                if (desserts.isNotEmpty) const _SectionDivider(),
              ],

              // ── Postres ───────────────────────────────────────────────────
              if (desserts.isNotEmpty) ...[
                _SectionHeader(label: 'Escoge tu postre'),
                const SizedBox(height: 6),
                for (final item in desserts)
                  _SelectableDishRow(
                    item: item,
                    isSelected: item.id == selectedDessertId,
                    onTap: () => onDessertSelected(item.id),
                  ),
              ],

              if (_hasAnyExtras) const SizedBox(height: 4),
              const SizedBox(height: 12),

              // ── Botón Agregar (siempre activo: todo es opcional) ──────────
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onAgregar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: AppColors.textDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Agregar',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── _SectionHeader ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          'Opcional',
          style: AppTextStyles.small.copyWith(
            color: AppColors.textGray,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── _SectionDivider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: AppColors.textGray.withValues(alpha: 0.15),
      ),
    );
  }
}

// ── _SelectableDishRow ────────────────────────────────────────────────────────
// Fila genérica para seleccionar entradas, bebidas o postres (sin precio).

class _SelectableDishRow extends StatelessWidget {
  const _SelectableDishRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final DishItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.textDark,
              checkColor: AppColors.white,
              side: BorderSide(
                color: AppColors.textGray.withValues(alpha: 0.5),
                width: 1.5,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name, style: AppTextStyles.bodySmall)),
          ],
        ),
      ),
    );
  }
}

// ── _ExecutiveDishTile ────────────────────────────────────────────────────────

class _ExecutiveDishTile extends StatelessWidget {
  const _ExecutiveDishTile({
    required this.dish,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final DishItem dish;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dish.name,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatPrice(dish.price),
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0) ...[
            _SmallRoundButton(label: '−', filled: false, onTap: onRemove),
            const SizedBox(width: 6),
          ],
          _CountBadge(count: count, onTap: onAdd),
        ],
      ),
    );
  }
}

// ── _CountBadge ───────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCount = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: hasCount ? _kCountGreen : Colors.transparent,
          shape: BoxShape.circle,
          border: hasCount
              ? null
              : Border.all(color: AppColors.textDark, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          hasCount ? '$count' : '+',
          style: TextStyle(
            fontSize: hasCount ? 14 : 18,
            fontWeight: FontWeight.w700,
            color: hasCount ? AppColors.white : AppColors.textDark,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ── _SmallRoundButton ─────────────────────────────────────────────────────────

class _SmallRoundButton extends StatelessWidget {
  const _SmallRoundButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? _kCountGreen : Colors.transparent,
          shape: BoxShape.circle,
          border: filled
              ? null
              : Border.all(color: AppColors.textDark, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: filled ? AppColors.white : AppColors.textDark,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ── helpers ───────────────────────────────────────────────────────────────────

String _formatPrice(double price) {
  if (price % 1 == 0) return 's/${price.toInt()}';
  final s = price.toStringAsFixed(2);
  final trimmed = s
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
  return 's/$trimmed';
}

String _formatTime(String time24) {
  if (time24.isEmpty) return '';
  final parts = time24.split(':');
  if (parts.length < 2) return time24;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  final period = h >= 12 ? 'pm' : 'am';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  if (m == 0) return '$h12 $period';
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}
