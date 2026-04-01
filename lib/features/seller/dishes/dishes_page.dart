import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/dishes/dishes_controller.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/dishes/widgets/add_dish_modal.dart';
import 'package:komi_fe/features/seller/dishes/widgets/daily_dishes_body.dart';
import 'package:komi_fe/features/seller/dishes/widgets/dish_accordion.dart';
import 'package:komi_fe/features/seller/dishes/widgets/pending_dishes_body.dart';
import 'package:komi_fe/features/seller/dishes/widgets/previous_dishes_bottom_sheet.dart';

class DishesPage extends StatefulWidget {
  const DishesPage({super.key});

  @override
  State<DishesPage> createState() => _DishesPageState();
}

class _DishesPageState extends State<DishesPage> {
  late final DishesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DishesController();
    _controller.dailyExpanded.addListener(_onControllerUpdate);
    _controller.dailyDishes.addListener(_onControllerUpdate);
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
                    // TODO: agregar plato a la lista
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 152),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mis platos', style: AppTextStyles.h2),
              const SizedBox(height: 20),
              DishAccordion(
                title: 'Platos del día',
                isExpanded: dailyExpanded,
                onToggle: _controller.toggleDailyExpanded,
                body: DailyDishesBody(
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
                  showPreviousDishesBottomSheet(context);
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

/// Botón de acción debajo de los acordeones. Estilo alineado con [DishAccordion].
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
