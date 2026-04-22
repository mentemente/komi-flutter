import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/title_profile_header.dart';
import 'package:komi_fe/features/seller/dishes/dishes_controller.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/dishes/widgets/add_dish_modal.dart';
import 'package:komi_fe/features/seller/dishes/widgets/daily_dishes_body.dart';
import 'package:komi_fe/features/seller/dishes/widgets/dish_accordion.dart';
import 'package:komi_fe/features/seller/dishes/widgets/pending_dishes_body.dart';
import 'package:komi_fe/features/seller/dishes/widgets/previous_dishes_bottom_sheet.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

bool _typeRequiresPrice(MenuItemType type) {
  return type == MenuItemType.main_course ||
      type == MenuItemType.executive_dish;
}

String? _publishValidationMessage(List<DailyMenuItem> dishes) {
  for (final d in dishes) {
    final name = d.name.trim();
    if (name.length < 3) {
      return 'Cada plato debe tener un nombre de al menos 3 caracteres.';
    }
    if (_typeRequiresPrice(d.type)) {
      final p = d.price;
      if (p == null || p.isNaN || p <= 0) {
        return 'Los platos de segundo y a la carta deben tener un precio mayor a 0.';
      }
    }
  }
  return null;
}

class DishesPage extends ConsumerStatefulWidget {
  const DishesPage({super.key});

  @override
  ConsumerState<DishesPage> createState() => _DishesPageState();
}

class _DishesPageState extends ConsumerState<DishesPage> {
  late final DishesController _controller;
  bool _publishingMenu = false;

  List<DailyMenuItem> _catalogFoods = [];
  bool _catalogLoading = true;
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    _controller = DishesController();
    _controller.dailyExpanded.addListener(_onControllerUpdate);
    _controller.dailyDishes.addListener(_onControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCatalogFoods());
  }

  Future<void> _loadCatalogFoods() async {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId = (stores != null && stores.isNotEmpty)
        ? stores.first.id
        : null;
    if (storeId == null || storeId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _catalogLoading = false;
        _catalogError = 'No se encontró la tienda.';
      });
      return;
    }

    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    try {
      final list = await ServiceLocator.dailyMenuService.listFoods(
        storeId: storeId,
      );
      if (!mounted) return;
      setState(() {
        _catalogFoods = list;
        _catalogLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogError = e.displayMessage;
        _catalogLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogError = '$e';
        _catalogLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dailyExpanded.removeListener(_onControllerUpdate);
    _controller.dailyDishes.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() => setState(() {});

  void _openPendingDishesModal() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _PendingDishesDialog(
        onSaveToDaily: (dishes) {
          _controller.addDishesToDaily(dishes);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  String _todayDateYmd() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  Future<void> _publishMenuToday() async {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId = (stores != null && stores.isNotEmpty)
        ? stores.first.id
        : null;
    if (storeId == null || storeId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la tienda.')),
      );
      return;
    }

    final foods = List<DailyMenuItem>.from(_controller.dailyDishes.value);
    if (foods.isEmpty) return;

    setState(() => _publishingMenu = true);
    try {
      await ServiceLocator.foodService.publishDailyFood(
        storeId: storeId,
        date: _todayDateYmd(),
        foods: foods,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Éxito'),
          content: const Text('El menú se creó correctamente.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('${RouteNames.seller}${RouteNames.dailyMenu}');
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _publishingMenu = false);
    }
  }

  void _openEditDailyModal(
    BuildContext context,
    int index,
    DailyMenuItem item,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => EditDishModal(
        item: item,
        onSave: (updated) {
          _controller.updateDishAt(index, updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyExpanded = _controller.dailyExpanded.value;
    final dailyDishes = _controller.dailyDishes.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'dishes_pending_camera',
            onPressed: _openPendingDishesModal,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            elevation: 3,
            child: const Icon(Icons.photo_camera_outlined),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'dishes_add',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => AddDishModal(
                  onCreated: (name, type, unit, price) {
                    final item = DailyMenuItem.fromAddDishModal(
                      name: name,
                      type: type,
                      unit: unit,
                      price: price,
                    );
                    _controller.addDishesToDaily([item]);
                  },
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleProfileHeader(title: 'Mis platos'),
              const SizedBox(height: 20),
              if (dailyDishes.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _publishingMenu
                        ? null
                        : () async {
                            final msg =
                                _publishValidationMessage(dailyDishes);
                            if (msg != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg)),
                              );
                              return;
                            }
                            await _publishMenuToday();
                          },
                    child: _publishingMenu
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
                const SizedBox(height: 16),
              ],
              DishAccordion(
                title: 'Platos del día',
                isExpanded: dailyExpanded,
                onToggle: _controller.toggleDailyExpanded,
                body: DailyDishesBody(
                  catalogFoods: _catalogFoods,
                  catalogLoading: _catalogLoading,
                  catalogError: _catalogError,
                  onRetryCatalog: _loadCatalogFoods,
                  dailyDishes: dailyDishes,
                  onEditItem: (index, item) =>
                      _openEditDailyModal(context, index, item),
                  onDeleteItem: (index) => _controller.removeDishAt(index),
                ),
              ),
              const SizedBox(height: 8),
              _DishesActionButton(
                label: 'Usar platos anteriores',
                isPrimary: false,
                onPressed: () {
                  showPreviousDishesBottomSheet(
                    context,
                    onAddSelected: (previews) {
                      _controller.addDishesToDaily(
                        previews.map((p) => p.toDailyMenuItem()).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingDishesDialog extends StatelessWidget {
  const _PendingDishesDialog({required this.onSaveToDaily});

  final void Function(List<DailyMenuItem> dishes) onSaveToDaily;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxH),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Subir platos con cámara',
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.textDark,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: PendingDishesBody(onSaveToDaily: onSaveToDaily),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DishesActionButton extends StatelessWidget {
  const _DishesActionButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final borderColor = isPrimary
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.textDark.withValues(alpha: 0.22);
    final textColor = isPrimary ? AppColors.primary : AppColors.textDark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_radius),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.accentLight.withValues(alpha: 0.25),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
