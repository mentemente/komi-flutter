import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';

/// State of the «Menu / menu» section in the seller's overview.
sealed class OverviewMenuState {
  const OverviewMenuState();
}

final class OverviewMenuLoading extends OverviewMenuState {
  const OverviewMenuLoading();
}

final class OverviewMenuError extends OverviewMenuState {
  const OverviewMenuError(this.message);
  final String message;
}

/// Menu loaded without items → Empty state UI (CTA to upload menu).
final class OverviewMenuEmpty extends OverviewMenuState {
  const OverviewMenuEmpty();
}

/// Menu loaded with at least one item.
final class OverviewMenuReady extends OverviewMenuState {
  const OverviewMenuReady(this.items);
  final List<DailyMenuItem> items;
}
