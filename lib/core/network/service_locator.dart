import 'package:komi_fe/core/network/http_client.dart';
import 'package:komi_fe/core/network/upload_service.dart';
import 'package:komi_fe/features/auth/login/login_service.dart';
import 'package:komi_fe/features/seller/dishes/food_service.dart';
import 'package:komi_fe/features/seller/creation/store_service.dart';
import 'package:komi_fe/features/auth/register/register_service.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_service.dart';

abstract final class ServiceLocator {
  ServiceLocator._();

  static final httpClient = HttpClient(
    baseUrl: 'https://mms-komi-qa.up.railway.app',
  );

  static final loginService = LoginService(httpClient);
  static final registerService = RegisterService(httpClient);
  static final uploadService = UploadService(httpClient);
  static final storeService = StoreService(httpClient);
  static final dailyMenuService = DailyMenuService(httpClient);
  static final foodService = FoodService(httpClient);
}
