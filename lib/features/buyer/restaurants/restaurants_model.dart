import 'package:komi_fe/features/buyer/restaurants/widgets/restaurant_card.dart';

class StoreSchedule {
  const StoreSchedule({
    required this.day,
    required this.isClosed,
    required this.open,
    required this.close,
  });

  final String day;
  final bool isClosed;
  final String open;
  final String close;

  factory StoreSchedule.fromJson(Map<String, dynamic> json) {
    return StoreSchedule(
      day: json['day'] as String? ?? '',
      isClosed: json['isClosed'] as bool? ?? false,
      open: json['open'] as String? ?? '',
      close: json['close'] as String? ?? '',
    );
  }
}

class StorePayments {
  const StorePayments({required this.cashOnDelivery, required this.prepaid});

  final bool cashOnDelivery;
  final bool prepaid;

  factory StorePayments.fromJson(Map<String, dynamic> json) {
    return StorePayments(
      cashOnDelivery: json['cashOnDelivery'] as bool? ?? false,
      prepaid: json['prepaid'] as bool? ?? false,
    );
  }
}

class NearbyStore {
  const NearbyStore({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.schedules,
    required this.pickupEnabled,
    required this.deliveryEnabled,
    required this.deliveryCost,
    required this.payments,
    required this.dailyMenuImageUrl,
    required this.matchingFoods,
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<StoreSchedule> schedules;
  final bool pickupEnabled;
  final bool deliveryEnabled;
  final double deliveryCost;
  final StorePayments payments;
  final String? dailyMenuImageUrl;
  final List<String> matchingFoods;

  factory NearbyStore.fromJson(Map<String, dynamic> json) {
    final schedulesRaw = json['schedules'] as List<dynamic>? ?? [];
    final foodsRaw = json['matchingFoods'] as List<dynamic>? ?? [];

    return NearbyStore(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      schedules: schedulesRaw
          .map((e) => StoreSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      pickupEnabled: json['pickupEnabled'] as bool? ?? false,
      deliveryEnabled: json['deliveryEnabled'] as bool? ?? false,
      deliveryCost: (json['deliveryCost'] as num?)?.toDouble() ?? 0.0,
      payments: StorePayments.fromJson(
        json['payments'] as Map<String, dynamic>? ?? {},
      ),
      dailyMenuImageUrl: json['dailyMenuImageUrl'] as String?,
      matchingFoods: foodsRaw.map((e) => e.toString()).toList(),
    );
  }

  RestaurantCardData toCardData() {
    return RestaurantCardData(
      storeId: id,
      menuTitle: name,
      hasPickup: pickupEnabled,
      hasDelivery: deliveryEnabled,
      hasYapePlin: payments.prepaid,
      hasCash: payments.cashOnDelivery,
      restaurantName: name,
      takeawayPrice: '',
      dailyItems: const [],
      mainDishes: matchingFoods,
      imageUrl: dailyMenuImageUrl,
    );
  }
}
