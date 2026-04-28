class StoreSchedule {
  const StoreSchedule({
    required this.day,
    required this.isClosed,
    this.open,
    this.close,
  });

  final String day;
  final bool isClosed;
  final String? open;
  final String? close;

  factory StoreSchedule.fromJson(Map<String, dynamic> json) {
    return StoreSchedule(
      day: json['day'] as String? ?? '',
      isClosed: json['isClosed'] as bool? ?? false,
      open: json['open'] as String?,
      close: json['close'] as String?,
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

class StoreGeoLocation {
  const StoreGeoLocation({required this.lat, required this.lng});

  final double lat;
  final double lng;

  /// Google Maps URL with the marker at `q=lat,lng` (paste in Maps or in the browser).
  String get mapsUrl => 'https://www.google.com/maps?q=$lat,$lng';

  static StoreGeoLocation? fromLocationJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final coords = json['coordinates'];
    if (coords is Map<String, dynamic>) {
      final lat = (coords['lat'] as num?)?.toDouble();
      final lng = (coords['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        return StoreGeoLocation(lat: lat, lng: lng);
      }
    }
    if (coords is List && coords.length >= 2) {
      final lng = (coords[0] as num?)?.toDouble();
      final lat = (coords[1] as num?)?.toDouble();
      if (lat != null && lng != null) {
        return StoreGeoLocation(lat: lat, lng: lng);
      }
    }
    return null;
  }
}

class SellerStore {
  const SellerStore({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.paymentQr,
    required this.schedules,
    required this.ownerId,
    required this.pickupEnabled,
    required this.deliveryEnabled,
    required this.deliveryCost,
    required this.payments,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  /// URL del código QR de Yape/Plin (GET `/v1/store/:id`).
  final String? paymentQr;
  final List<StoreSchedule> schedules;
  final String ownerId;
  final bool pickupEnabled;
  final bool deliveryEnabled;
  final double deliveryCost;
  final StorePayments payments;
  final StoreGeoLocation? location;
  final String? createdAt;
  final String? updatedAt;

  static const _dayOrder = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  factory SellerStore.fromJson(Map<String, dynamic> json) {
    final rawList = json['schedules'] as List<dynamic>? ?? [];
    final parsed = rawList
        .map(
          (e) => StoreSchedule.fromJson(
            e is Map<String, dynamic> ? e : <String, dynamic>{},
          ),
        )
        .toList();
    parsed.sort((a, b) {
      final ia = _dayOrder.indexOf(a.day.toLowerCase());
      final ib = _dayOrder.indexOf(b.day.toLowerCase());
      if (ia < 0 && ib < 0) return 0;
      if (ia < 0) return 1;
      if (ib < 0) return -1;
      return ia.compareTo(ib);
    });

    return SellerStore(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      paymentQr: json['paymentQr'] as String?,
      schedules: parsed,
      ownerId: json['ownerId'] as String? ?? '',
      pickupEnabled: json['pickupEnabled'] as bool? ?? false,
      deliveryEnabled: json['deliveryEnabled'] as bool? ?? false,
      deliveryCost: (json['deliveryCost'] as num?)?.toDouble() ?? 0,
      payments: StorePayments.fromJson(
        json['payments'] is Map<String, dynamic>
            ? json['payments'] as Map<String, dynamic>
            : {},
      ),
      location: StoreGeoLocation.fromLocationJson(
        json['location'] is Map<String, dynamic>
            ? json['location'] as Map<String, dynamic>
            : null,
      ),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

String scheduleDayLabelEs(String day) {
  switch (day.toLowerCase()) {
    case 'monday':
      return 'Lunes';
    case 'tuesday':
      return 'Martes';
    case 'wednesday':
      return 'Miércoles';
    case 'thursday':
      return 'Jueves';
    case 'friday':
      return 'Viernes';
    case 'saturday':
      return 'Sábado';
    case 'sunday':
      return 'Domingo';
    default:
      return day;
  }
}
