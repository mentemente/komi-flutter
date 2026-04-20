class DishItem {
  const DishItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    required this.isActive,
  });

  final String id;
  final String name;
  final int stock;
  final double price;
  final bool isActive;

  factory DishItem.fromJson(Map<String, dynamic> json) => DishItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        stock: json['stock'] as int? ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

class StoreMenuSchedule {
  const StoreMenuSchedule({
    required this.day,
    required this.open,
    required this.close,
  });

  final String day;
  final String open;
  final String close;

  factory StoreMenuSchedule.fromJson(Map<String, dynamic> json) =>
      StoreMenuSchedule(
        day: json['day'] as String? ?? '',
        open: json['open'] as String? ?? '',
        close: json['close'] as String? ?? '',
      );
}

class StoreMenuInfo {
  const StoreMenuInfo({
    required this.name,
    required this.isOpenNow,
    required this.schedule,
    required this.pickupEnabled,
    required this.deliveryEnabled,
    required this.deliveryCost,
    required this.paymentQr,
  });

  final String name;
  final bool isOpenNow;
  final StoreMenuSchedule schedule;
  final bool pickupEnabled;
  final bool deliveryEnabled;
  final double deliveryCost;
  final String paymentQr;

  factory StoreMenuInfo.fromJson(Map<String, dynamic> json) => StoreMenuInfo(
        name: json['name'] as String? ?? '',
        isOpenNow: json['isOpenNow'] as bool? ?? false,
        schedule: StoreMenuSchedule.fromJson(
          json['schedule'] as Map<String, dynamic>? ?? {},
        ),
        pickupEnabled: json['pickupEnabled'] as bool? ?? false,
        deliveryEnabled: json['deliveryEnabled'] as bool? ?? false,
        deliveryCost: (json['deliveryCost'] as num?)?.toDouble() ?? 0.0,
        paymentQr: json['paymentQr'] as String? ?? '',
      );
}

class MenuDishes {
  const MenuDishes({
    required this.appetizer,
    required this.mainCourse,
    required this.executiveDish,
    required this.beverage,
    required this.dessert,
  });

  final List<DishItem> appetizer;
  final List<DishItem> mainCourse;
  final List<DishItem> executiveDish;
  final List<DishItem> beverage;
  final List<DishItem> dessert;

  bool get hasMenuItems => mainCourse.isNotEmpty;
  bool get hasALaCarteItems => executiveDish.isNotEmpty;

  factory MenuDishes.fromJson(Map<String, dynamic> json) {
    List<DishItem> parseDishes(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => DishItem.fromJson(e as Map<String, dynamic>))
          .where((d) => d.isActive)
          .toList();
    }

    return MenuDishes(
      appetizer: parseDishes('appetizer'),
      mainCourse: parseDishes('main_course'),
      executiveDish: parseDishes('executive_dish'),
      beverage: parseDishes('beverage'),
      dessert: parseDishes('dessert'),
    );
  }
}

class StoreMenu {
  const StoreMenu({required this.store, required this.dishes});

  final StoreMenuInfo store;
  final MenuDishes dishes;

  factory StoreMenu.fromJson(Map<String, dynamic> data) => StoreMenu(
        store: StoreMenuInfo.fromJson(
          data['store'] as Map<String, dynamic>? ?? {},
        ),
        dishes: MenuDishes.fromJson(
          data['dishes'] as Map<String, dynamic>? ?? {},
        ),
      );
}

/// Un ítem del carrito de tipo "menú": plato de fondo + entrada, bebida y postre opcionales.
/// Por regla de negocio, ninguno de los acompañantes (appetizer/beverage/dessert) tiene precio.
class MenuCartEntry {
  const MenuCartEntry({
    required this.mainCourse,
    this.appetizer,
    this.beverage,
    this.dessert,
  });

  final DishItem mainCourse;
  final DishItem? appetizer;
  final DishItem? beverage;
  final DishItem? dessert;
}
