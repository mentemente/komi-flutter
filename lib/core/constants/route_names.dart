abstract final class RouteNames {
  RouteNames._();

  static const String root = '/';
  static const String home = '/inicio';
  static const String login = '/login';
  static const String register = '/registro';
  static const String creation = '/creacion';
  static const String locationPermission = '/ubicacion';

  // Buyer routes
  static const String restaurants = '/restaurantes';

  // Detail of a restaurant for buyer (`/restaurantes/:storeId`).
  static String restaurantDetail(String storeId) => '$restaurants/$storeId';

  // Detail of an order for buyer (`/ordenes/detalle/:orderId`).
  static String buyerOrderDetail(String orderId) => '$orders/detalle/$orderId';

  // Seller routes
  static const String seller = '/vendedor';
  static const String orders = '/ordenes';
  static const String dailyMenu = '/carta-del-dia';
  static const String overview = '/resumen';
  static const String dishes = '/mis-platos';
}
