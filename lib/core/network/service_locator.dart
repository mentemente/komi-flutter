import 'package:komi_fe/core/config/app_config.dart';
import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/core/network/upload_service.dart';
import 'package:komi_fe/features/auth/login/login_service.dart';
import 'package:komi_fe/features/buyer/checkout/order_service.dart';
import 'package:komi_fe/features/seller/dishes/food_service.dart';
import 'package:komi_fe/features/seller/creation/store_service.dart';
import 'package:komi_fe/features/auth/register/register_service.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_service.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_service.dart';
import 'package:komi_fe/features/buyer/location/location_service.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_service.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_service.dart';
import 'package:komi_fe/features/seller/orders/orders_service.dart';

abstract final class ServiceLocator {
  ServiceLocator._();

  static final httpClient = HttpClient(
    baseUrl: AppConfig.apiBaseUrl,
  );

  static final locationService = LocationService();
  static final orderService = OrderService(httpClient);
  static final foodService = FoodService(httpClient);
  static final storeService = StoreService(httpClient);
  static final loginService = LoginService(httpClient);
  static final ordersService = OrdersService(httpClient);
  static final uploadService = UploadService(httpClient);
  static final registerService = RegisterService(httpClient);
  static final dailyMenuService = DailyMenuService(httpClient);
  static final restaurantsService = RestaurantsService(httpClient);
  static final restaurantDetailService = RestaurantDetailService(httpClient);
  static final customerOrdersService = CustomerOrdersService(httpClient);
}
