import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

sealed class DailyMenuState {
  const DailyMenuState();
}

final class DailyMenuLoading extends DailyMenuState {
  const DailyMenuLoading();
}

final class DailyMenuError extends DailyMenuState {
  const DailyMenuError(this.message);
  final String message;
}

final class DailyMenuReady extends DailyMenuState {
  const DailyMenuReady(this.items);
  final List<DailyMenuItem> items;
}
