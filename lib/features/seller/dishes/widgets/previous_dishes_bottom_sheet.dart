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
  void Function(PreviousDishPreview dish)? onUseToday,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: false,
    builder: (ctx) => _PreviousDishesSheet(onUseToday: onUseToday),
  );
}

class _PreviousDishesSheet extends ConsumerStatefulWidget {
  const _PreviousDishesSheet({this.onUseToday});

  final void Function(PreviousDishPreview dish)? onUseToday;

  @override
  ConsumerState<_PreviousDishesSheet> createState() =>
      _PreviousDishesSheetState();
}

class _PreviousDishesSheetState extends ConsumerState<_PreviousDishesSheet> {
  List<PreviousDishPreview> _items = [];
  bool _loading = true;
  String? _error;

  static const double _sheetTopRadius = 28;

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
          constraints: BoxConstraints(maxHeight: media.size.height * 0.72),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_sheetTopRadius),
              topRight: Radius.circular(_sheetTopRadius),
            ),
            border: Border.all(color: AppColors.textDark, width: 1),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20 + safeBottom),
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
                        horizontal: 20,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Text(
                        'No hay platos anteriores disponibles.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        children: List.generate(_items.length, (index) {
                          final dish = _items[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _items.length - 1 ? 10 : 0,
                            ),
                            child: _PreviousDishCard(
                              dish: dish,
                              onUseToday: () {
                                widget.onUseToday?.call(dish);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviousDishCard extends StatelessWidget {
  const _PreviousDishCard({required this.dish, required this.onUseToday});

  final PreviousDishPreview dish;
  final VoidCallback onUseToday;

  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    final borderColor = dish.cardColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _UsarHoyButton(onPressed: onUseToday),
        ],
      ),
    );
  }
}

class _UsarHoyButton extends StatelessWidget {
  const _UsarHoyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textDark, width: 1),
          ),
          child: Text(
            'Usar hoy',
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
