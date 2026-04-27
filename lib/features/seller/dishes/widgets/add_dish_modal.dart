import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

bool _typeRequiresPrice(MenuItemType type) => type.isPricedDishCategory;

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
  MenuItemType _selectedType = MenuItemType.main_course;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.textGray.withValues(alpha: 0.6)),
  );

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _unitController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _canSubmit {
    final name = _nameController.text.trim();
    if (name.length < 3) return false;

    final stock = int.tryParse(_unitController.text.trim());
    if (stock == null || stock <= 0) return false;

    if (_typeRequiresPrice(_selectedType)) {
      final priceText = _priceController.text.trim();
      if (priceText.isEmpty) return false;
      final parsed = double.tryParse(
        priceText.replaceFirst(RegExp(r'^s/\s*'), ''),
      );
      if (parsed == null || parsed.isNaN || parsed <= 0) return false;
    }

    return true;
  }

  void _submit() {
    if (!_canSubmit) return;
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final double? price;
    if (_typeRequiresPrice(_selectedType)) {
      final parsed = double.tryParse(
        _priceController.text.trim().replaceFirst(RegExp(r'^s/\s*'), ''),
      );
      price = (parsed != null && !parsed.isNaN && parsed > 0) ? parsed : null;
    } else {
      price = null;
    }
    widget.onCreated?.call(name, _selectedType, unit, price);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 520),
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
              'Agregar plato',
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
                  value: MenuItemType.appetizer,
                  child: Text('Entrada'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.beverage,
                  child: Text('Bebida'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.dessert,
                  child: Text('Postre'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.main_course,
                  child: Text('Plato de segundo'),
                ),
                DropdownMenuItem(
                  value: MenuItemType.executive_dish,
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
                onPressed: _canSubmit ? _submit : null,
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
    _nameController.addListener(_onFormChanged);
    _unitController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _canSubmitEdit {
    final name = _nameController.text.trim();
    if (name.length < 3) return false;

    final stock = int.tryParse(_unitController.text.trim());
    if (stock == null) return false;

    if (_typeRequiresPrice(_selectedType)) {
      final priceText = _priceController.text.trim();
      if (priceText.isEmpty) return false;
      final parsed = double.tryParse(
        priceText.replaceFirst(RegExp(r'^s/\s*'), ''),
      );
      if (parsed == null || parsed.isNaN || parsed <= 0) return false;
    }

    return true;
  }

  void _submit() {
    if (!_canSubmitEdit) return;
    final name = _nameController.text.trim();
    final stock = int.tryParse(_unitController.text.trim()) ?? 0;
    final double? priceValue;
    if (_typeRequiresPrice(_selectedType)) {
      final parsed = double.tryParse(
        _priceController.text.trim().replaceFirst(RegExp(r'^s/\s*'), ''),
      );
      priceValue = parsed != null && !parsed.isNaN && parsed > 0
          ? parsed
          : null;
    } else {
      priceValue = null;
    }
    final updated = DailyMenuItem(
      id: widget.item.id,
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
                    value: MenuItemType.appetizer,
                    child: Text('Entrada'),
                  ),
                  DropdownMenuItem(
                    value: MenuItemType.beverage,
                    child: Text('Bebida'),
                  ),
                  DropdownMenuItem(
                    value: MenuItemType.dessert,
                    child: Text('Postre'),
                  ),
                  DropdownMenuItem(
                    value: MenuItemType.main_course,
                    child: Text('Plato de segundo'),
                  ),
                  DropdownMenuItem(
                    value: MenuItemType.executive_dish,
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
                  onPressed: _canSubmitEdit ? _submit : null,
                  child: const Text('Actualizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
