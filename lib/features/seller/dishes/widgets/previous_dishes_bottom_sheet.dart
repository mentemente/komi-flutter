import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

/// Datos de vista previa para un plato anterior reutilizable.
class PreviousDishPreview {
  const PreviousDishPreview({
    required this.name,
    required this.category,
    required this.cardColor,
    this.priceLabel,
  });

  final String name;
  final String category;
  final Color cardColor;
  final String? priceLabel;
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

class _PreviousDishesSheet extends StatelessWidget {
  const _PreviousDishesSheet({this.onUseToday});

  final void Function(PreviousDishPreview dish)? onUseToday;

  // TODO: remove this
  static const _items = <PreviousDishPreview>[
    PreviousDishPreview(
      name: 'Tequeños',
      category: 'Entrada',
      cardColor: Color(0xFFB8D4E8),
    ),
    PreviousDishPreview(
      name: 'Cau Cau',
      category: 'De fondo',
      cardColor: Color(0xFFC8E6C9),
      priceLabel: 'S/12',
    ),
    PreviousDishPreview(
      name: 'Pollada',
      category: 'A la carta',
      cardColor: Color(0xFFE1BEE7),
      priceLabel: 'S/20',
    ),
  ];

  static const double _sheetTopRadius = 28;

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
            border: Border.all(color: AppColors.textDark, width: 1.5),
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
                              onUseToday?.call(dish);
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
                const SizedBox(height: 2),
                Text(
                  'Stock: 0 · ${dish.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textGray,
                  ),
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
