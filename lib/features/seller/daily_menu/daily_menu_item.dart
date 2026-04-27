import 'package:komi_fe/core/models/menu_item_type.dart';

export 'package:komi_fe/core/models/menu_item_type.dart';

class DailyMenuItem {
  DailyMenuItem({
    this.id,
    required this.name,
    this.price,
    required this.stock,
    required this.isActive,
    required this.type,
  });

  /// Item from API (`GET` / `POST /v1/food`).
  factory DailyMenuItem.fromFoodApiMap(Map<String, dynamic> json) {
    final priceVal = json['price'];
    double? price;
    if (priceVal is num) {
      price = priceVal.toDouble();
    }
    return DailyMenuItem(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      price: price,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      type: menuItemTypeFromApi(json['type'] as String?),
    );
  }

  /// From [AddDishModal]: `unit` is the text of units/stock.
  factory DailyMenuItem.fromAddDishModal({
    required String name,
    required MenuItemType type,
    required String unit,
    double? price,
  }) {
    final parsed = int.tryParse(unit.trim());
    final stock = (parsed == null || parsed < 0) ? 0 : parsed;
    return DailyMenuItem(
      name: name,
      price: price,
      stock: stock,
      isActive: true,
      type: type,
    );
  }

  final String? id;
  String name;
  double? price;
  int stock;
  bool isActive;
  final MenuItemType type;

  /// Item for `foods` in `POST /v1/food`.
  Map<String, dynamic> toPublishFoodJson() {
    return <String, dynamic>{
      'name': name,
      'stock': stock,
      'price': price ?? 0,
      'type': type.name,
    };
  }
}
