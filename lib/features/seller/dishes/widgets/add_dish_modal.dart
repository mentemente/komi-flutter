import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

bool _typeRequiresPrice(MenuItemType type) {
  return type != MenuItemType.entrada && type != MenuItemType.bebida;
}

class AddDishModal extends StatefulWidget {
  const AddDishModal({super.key, this.onCreated});

  final void Function(
    String name,
    MenuItemType type,
    String unit,
    double? price,
  )?
  onCreated;

  @override
  State<AddDishModal> createState() => _AddDishModalState();
}

class _AddDishModalState extends State<AddDishModal> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  MenuItemType _selectedType = MenuItemType.platoSegundo;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.textGray.withValues(alpha: 0.6)),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final unit = _unitController.text.trim();
    final price = _typeRequiresPrice(_selectedType)
        ? double.tryParse(
            _priceController.text.trim().replaceFirst(RegExp(r'^s/\s*'), ''),
          )
        : null;
    widget.onCreated?.call(name, _selectedType, unit, price);
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
            Text(
              'Agregar plato:',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textDark, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nombre del plato',
                filled: true,
                fillColor: AppColors.white,
                border: _inputBorder,
                enabledBorder: _inputBorder,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MenuItemType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de comida',
                filled: true,
                fillColor: AppColors.white,
                border: _inputBorder,
                enabledBorder: _inputBorder,
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: MenuItemType.entrada,
                  child: Text('Entrada'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.bebida,
                  child: Text('Bebida'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.platoSegundo,
                  child: Text('Plato de segundo'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.platoALaCarta,
                  child: Text('Plato a la carta'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    decoration: InputDecoration(
                      labelText: 'Unid',
                      filled: true,
                      fillColor: AppColors.white,
                      border: _inputBorder,
                      enabledBorder: _inputBorder,
                    ),
                  ),
                ),
                if (_typeRequiresPrice(_selectedType)) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 's/',
                        filled: true,
                        fillColor: AppColors.white,
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Crear plato'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDishModal extends StatefulWidget {
  const EditDishModal({super.key, required this.item, this.onSave});

  final DailyMenuItem item;
  final void Function(DailyMenuItem updated)? onSave;

  @override
  State<EditDishModal> createState() => _EditDishModalState();
}

class _EditDishModalState extends State<EditDishModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _unitController;
  late final TextEditingController _priceController;
  late MenuItemType _selectedType;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.textGray.withValues(alpha: 0.6)),
  );

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item.name);
    _unitController = TextEditingController(text: '${item.stock}');
    _priceController = TextEditingController(
      text: item.price != null ? item.price!.toStringAsFixed(0) : '',
    );
    _selectedType = item.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final stock = int.tryParse(_unitController.text.trim()) ?? 0;
    final double? priceValue;
    if (_typeRequiresPrice(_selectedType)) {
      final parsed = double.tryParse(
        _priceController.text.trim().replaceFirst(RegExp(r'^s/\s*'), ''),
      );
      priceValue =
          parsed != null && !parsed.isNaN && parsed > 0 ? parsed : null;
    } else {
      priceValue = null;
    }
    final updated = DailyMenuItem(
      name: name,
      price: priceValue,
      stock: stock,
      isActive: widget.item.isActive,
      type: _selectedType,
    );
    widget.onSave?.call(updated);
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
            Text(
              'Editar plato:',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textDark, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nombre del plato',
                filled: true,
                fillColor: AppColors.white,
                border: _inputBorder,
                enabledBorder: _inputBorder,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MenuItemType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de comida',
                filled: true,
                fillColor: AppColors.white,
                border: _inputBorder,
                enabledBorder: _inputBorder,
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: MenuItemType.entrada,
                  child: Text('Entrada'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.bebida,
                  child: Text('Bebida'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.platoSegundo,
                  child: Text('Plato de segundo'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.platoALaCarta,
                  child: Text('Plato a la carta'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    decoration: InputDecoration(
                      labelText: 'Stock',
                      filled: true,
                      fillColor: AppColors.white,
                      border: _inputBorder,
                      enabledBorder: _inputBorder,
                    ),
                  ),
                ),
                if (_typeRequiresPrice(_selectedType)) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 's/',
                        filled: true,
                        fillColor: AppColors.white,
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
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
