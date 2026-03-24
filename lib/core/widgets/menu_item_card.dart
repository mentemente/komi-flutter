import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.onActiveChanged,
    required this.onSave,
  });

  final DailyMenuItem item;
  final ValueChanged<bool> onActiveChanged;
  final void Function(DailyMenuItem item, String name, double? price, int stock)
      onSave;

  Color get _borderColor => item.type.cardColor;

  void _onEditTap(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _EditMenuItemModal(
        item: item,
        onSave: (name, price, stock) => onSave(item, name, price, stock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.price != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'S/${item.price!.toStringAsFixed(0)}',
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
                  'Stock: ${item.stock}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _onEditTap(context),
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textGray,
            iconSize: 22,
            style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
          ),
          Switch(
            value: item.isActive,
            onChanged: onActiveChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.textGray.withValues(alpha: 0.35),
            inactiveThumbColor: AppColors.white,
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
              return states.contains(WidgetState.selected)
                  ? null
                  : Colors.transparent;
            }),
          ),
        ],
      ),
    );
  }
}

class _EditMenuItemModal extends StatefulWidget {
  const _EditMenuItemModal({
    required this.item,
    required this.onSave,
  });

  final DailyMenuItem item;
  final void Function(String name, double? price, int stock) onSave;

  @override
  State<_EditMenuItemModal> createState() => _EditMenuItemModalState();
}

class _EditMenuItemModalState extends State<_EditMenuItemModal> {
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: '${widget.item.stock}');
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    widget.onSave(widget.item.name, widget.item.price, stock);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textGray.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textDark, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Stock',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.textGray.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Actualizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
