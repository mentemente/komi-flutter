import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/menu_type_color_legend.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

bool _typeNeedsPrice(MenuItemType type) => type.isPricedDishCategory;

String _stripPricePrefix(String s) {
  return s.replaceFirst(RegExp(r'^s?/?\s*', caseSensitive: false), '');
}

String _priceString(double p) {
  if (p % 1 == 0) return p.toInt().toString();
  return p.toString();
}

class _FoodRowEdit {
  _FoodRowEdit._({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.stock,
  });

  final String id;
  final MenuItemType type;
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController stock;

  factory _FoodRowEdit.fromItem(DailyMenuItem e) {
    return _FoodRowEdit._(
      id: e.id!,
      type: e.type,
      name: TextEditingController(text: e.name),
      price: TextEditingController(
        text: e.price != null ? _priceString(e.price!) : '',
      ),
      stock: TextEditingController(text: e.stock.toString()),
    );
  }

  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
  }

  String? _validate() {
    final n = name.text.trim();
    if (n.length < 3) {
      return 'Cada plato requiere un nombre de al menos 3 caracteres.';
    }
    if (_typeNeedsPrice(type)) {
      final p = double.tryParse(_stripPricePrefix(price.text.trim()));
      if (p == null || p.isNaN || p <= 0) {
        return 'Los platos con precio deben indicar un monto mayor a 0.';
      }
    }
    final st = int.tryParse(stock.text.trim());
    if (st == null || st < 0) {
      return 'El stock debe ser un número entero ≥ 0.';
    }
    return null;
  }

  Map<String, dynamic> toBodyMap() {
    final n = name.text.trim();
    final st = int.parse(stock.text.trim());
    final out = <String, dynamic>{'id': id, 'name': n, 'stock': st};
    if (_typeNeedsPrice(type)) {
      final p = double.tryParse(_stripPricePrefix(price.text.trim()));
      out['price'] = p ?? 0.0;
    } else {
      final raw = price.text.trim();
      if (raw.isEmpty) {
        out['price'] = 0.0;
      } else {
        final p = double.tryParse(_stripPricePrefix(raw));
        out['price'] = p != null && !p.isNaN ? p : 0.0;
      }
    }
    return out;
  }
}

class BulkEditCatalogFoodsModal extends StatefulWidget {
  const BulkEditCatalogFoodsModal({super.key, required this.items});

  final List<DailyMenuItem> items;

  @override
  State<BulkEditCatalogFoodsModal> createState() =>
      _BulkEditCatalogFoodsModalState();
}

class _BulkEditCatalogFoodsModalState extends State<BulkEditCatalogFoodsModal> {
  final _scrollController = ScrollController();
  late final List<_FoodRowEdit> _rows;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rows = widget.items
        .where((e) => e.id != null && e.id!.isNotEmpty)
        .map(_FoodRowEdit.fromItem)
        .toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit(String storeId) async {
    for (final r in _rows) {
      final e = r._validate();
      if (e != null) {
        setState(() => _error = e);
        return;
      }
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final body = _rows.map((r) => r.toBodyMap()).toList();
      await ServiceLocator.foodService.patchFoodsMany(
        storeId: storeId,
        foods: body,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.displayMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    if (_rows.isEmpty) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No hay platos con id para editar.',
            style: AppTextStyles.bodySmall,
          ),
        ),
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxH),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textGray.withValues(alpha: 0.25)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edición masiva de platos',
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textGray,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: MenuTypeColorLegend(),
            ),
            if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _error!,
                  style: AppTextStyles.small.copyWith(
                    color: const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
            Flexible(
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: _rows.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = _rows[i];
                    return _EditFoodRowFields(row: r);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving
                        ? null
                        : () {
                            final m = _BulkEditStoreId.maybeOf(context);
                            if (m == null || m.isEmpty) return;
                            _submit(m);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: AppColors.white,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provides [storeId] to the modal; set when opening the dialog.
class _BulkEditStoreId extends InheritedWidget {
  const _BulkEditStoreId({required this.storeId, required super.child});

  final String storeId;

  static String? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_BulkEditStoreId>()
        ?.storeId;
  }

  @override
  bool updateShouldNotify(_BulkEditStoreId oldWidget) =>
      storeId != oldWidget.storeId;
}

class _EditFoodRowFields extends StatelessWidget {
  const _EditFoodRowFields({required this.row});

  final _FoodRowEdit row;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: AppColors.textGray.withValues(alpha: 0.55)),
  );

  static final _inputBorderFocused = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: AppColors.textDark.withValues(alpha: 0.9)),
  );

  @override
  Widget build(BuildContext context) {
    final needsPrice = _typeNeedsPrice(row.type);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: row.type.cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: row.name,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Nombre',
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorderFocused,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            if (needsPrice)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: row.price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Precio (S/)',
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                        focusedBorder: _inputBorderFocused,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: row.stock,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Stock',
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                        focusedBorder: _inputBorderFocused,
                      ),
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: row.stock,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Stock',
                  border: _inputBorder,
                  enabledBorder: _inputBorder,
                  focusedBorder: _inputBorderFocused,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Open the bulk edit modal. Returns `true` if saved successfully.
Future<bool?> showBulkEditCatalogFoodsModal({
  required BuildContext context,
  required String storeId,
  required List<DailyMenuItem> catalogFoods,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _BulkEditStoreId(
      storeId: storeId,
      child: BulkEditCatalogFoodsModal(
        items: List<DailyMenuItem>.of(catalogFoods),
      ),
    ),
  );
}
