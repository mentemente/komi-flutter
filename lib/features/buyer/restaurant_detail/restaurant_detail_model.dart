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
    required this.prepaid,
    required this.cashOnDelivery,
  });

  final String name;
  final bool isOpenNow;
  final StoreMenuSchedule schedule;
  final bool pickupEnabled;
  final bool deliveryEnabled;
  final double deliveryCost;
  final String paymentQr;

  /// Yape/Plin (prepaid), per `store.payments.prepaid` in the API.
  final bool prepaid;

  /// Cash on delivery, per `store.payments.cashOnDelivery`.
  final bool cashOnDelivery;

  factory StoreMenuInfo.fromJson(Map<String, dynamic> json) {
    final pay = json['payments'] is Map<String, dynamic>
        ? json['payments'] as Map<String, dynamic>
        : <String, dynamic>{};
    final legacyNoPayments = !json.containsKey('payments');
    final prepaid = legacyNoPayments
        ? true
        : (pay['prepaid'] as bool? ?? false);
    final cashOnDelivery = legacyNoPayments
        ? true
        : (pay['cashOnDelivery'] as bool? ?? false);

    return StoreMenuInfo(
      name: json['name'] as String? ?? '',
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      schedule: StoreMenuSchedule.fromJson(
        json['schedule'] as Map<String, dynamic>? ?? {},
      ),
      pickupEnabled: json['pickupEnabled'] as bool? ?? false,
      deliveryEnabled: json['deliveryEnabled'] as bool? ?? false,
      deliveryCost: (json['deliveryCost'] as num?)?.toDouble() ?? 0.0,
      paymentQr: json['paymentQr'] as String? ?? '',
      prepaid: prepaid,
      cashOnDelivery: cashOnDelivery,
    );
  }
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
    List<DishItem> parseDishes(String key, {bool activeOnly = true}) {
      final raw = json[key] as List<dynamic>? ?? [];
      final list = raw
          .map((e) => DishItem.fromJson(e as Map<String, dynamic>))
          .toList();
      if (activeOnly) {
        return list.where((d) => d.isActive).toList();
      }
      return list;
    }

    return MenuDishes(
      appetizer: parseDishes('appetizer', activeOnly: false),
      mainCourse: parseDishes('main_course', activeOnly: false),
      executiveDish: parseDishes('executive_dish', activeOnly: false),
      beverage: parseDishes('beverage', activeOnly: false),
      dessert: parseDishes('dessert', activeOnly: false),
    );
  }
}

class StoreMenu {
  const StoreMenu({required this.store, required this.dishes});

  final StoreMenuInfo store;
  final MenuDishes dishes;

  factory StoreMenu.fromJson(Map<String, dynamic> data) => StoreMenu(
    store: StoreMenuInfo.fromJson(data['store'] as Map<String, dynamic>? ?? {}),
    dishes: MenuDishes.fromJson(data['dishes'] as Map<String, dynamic>? ?? {}),
  );
}

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
