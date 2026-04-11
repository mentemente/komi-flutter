import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

String _menuTypeCategoryLabel(MenuItemType t) {
  switch (t) {
    case MenuItemType.appetizer:
      return 'Entrada';
    case MenuItemType.beverage:
      return 'Bebida';
    case MenuItemType.main_course:
      return 'Menú';
    case MenuItemType.executive_dish:
      return 'Plato a la carta';
  }
}

class PreviousDishPreview {
  const PreviousDishPreview({
    required this.name,
    required this.category,
    required this.cardColor,
    this.priceLabel,
    required this.type,
    this.price,
  });

  final String name;
  final String category;
  final Color cardColor;
  final String? priceLabel;
  final MenuItemType type;
  final double? price;

  factory PreviousDishPreview.fromApiMap(Map<String, dynamic> json) {
    final type = menuItemTypeFromApi(json['type'] as String?);
    final name = json['name'] as String? ?? '';
    final priceVal = json['price'];
    final price = priceVal is num ? priceVal.toDouble() : null;
    final priceLabel = (price != null && price > 0)
        ? 'S/${price.toStringAsFixed(0)}'
        : null;
    return PreviousDishPreview(
      name: name,
      category: _menuTypeCategoryLabel(type),
      cardColor: type.cardColor,
      priceLabel: priceLabel,
      type: type,
      price: price,
    );
  }

  DailyMenuItem toDailyMenuItem() {
    return DailyMenuItem(
      name: name,
      price: price,
      stock: 0,
      isActive: true,
      type: type,
    );
  }
}

Future<void> showPreviousDishesBottomSheet(
  BuildContext context, {
  void Function(List<PreviousDishPreview> dishes)? onAddSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: false,
    builder: (ctx) => _PreviousDishesSheet(onAddSelected: onAddSelected),
  );
}

class _PreviousDishesSheet extends ConsumerStatefulWidget {
  const _PreviousDishesSheet({this.onAddSelected});

  final void Function(List<PreviousDishPreview> dishes)? onAddSelected;

  @override
  ConsumerState<_PreviousDishesSheet> createState() =>
      _PreviousDishesSheetState();
}

class _PreviousDishesSheetState extends ConsumerState<_PreviousDishesSheet> {
  List<PreviousDishPreview> _items = [];
  bool _loading = true;
  String? _error;
  final Set<int> _selectedIndices = {};

  static const double _sheetTopRadius = 28;

  void _toggleIndex(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _confirmSelection() {
    if (_selectedIndices.isEmpty) return;
    final sorted = _selectedIndices.toList()..sort();
    final dishes = sorted.map((i) => _items[i]).toList();
    widget.onAddSelected?.call(dishes);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId = (stores != null && stores.isNotEmpty)
        ? stores.first.id
        : null;

    if (storeId == null || storeId.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'No se encontró la tienda.';
          _loading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final raw = await ServiceLocator.dailyMenuService.listPreviousUniqueFoods(
        storeId: storeId,
      );
      if (!mounted) return;
      setState(() {
        _items = raw.map(PreviousDishPreview.fromApiMap).toList();
        _selectedIndices.clear();
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.displayMessage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardBottom = media.viewInsets.bottom;
    final safeBottom = media.padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardBottom),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: media.size.height * 0.72,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_sheetTopRadius),
              topRight: Radius.circular(_sheetTopRadius),
            ),
            border: Border.all(color: AppColors.textDark, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Usar platos anteriores',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: _items.isNotEmpty && !_loading && _error == null
                        ? 8
                        : 20 + safeBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _error!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _load,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      else if (_items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No hay platos anteriores disponibles.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                        )
                      else
                        ...List.generate(_items.length, (index) {
                          final dish = _items[index];
                          final selected = _selectedIndices.contains(index);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _items.length - 1 ? 10 : 0,
                            ),
                            child: _PreviousDishCard(
                              dish: dish,
                              isSelected: selected,
                              onToggle: () => _toggleIndex(index),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              if (_items.isNotEmpty && !_loading && _error == null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + safeBottom),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _selectedIndices.isEmpty
                          ? null
                          : _confirmSelection,
                      child: Text(
                        _selectedIndices.isEmpty
                            ? 'Selecciona platos'
                            : 'Agregar al menú de hoy (${_selectedIndices.length})',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviousDishCard extends StatelessWidget {
  const _PreviousDishCard({
    required this.dish,
    required this.isSelected,
    required this.onToggle,
  });

  final PreviousDishPreview dish;
  final bool isSelected;
  final VoidCallback onToggle;

  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    final borderColor = dish.cardColor;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
            width: isSelected ? 2.5 : 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (dish.priceLabel != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          dish.priceLabel!,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
