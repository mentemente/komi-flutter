import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/features/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/features/404/not_found_page.dart';
import 'package:komi_fe/features/auth/login/login_page.dart';
import 'package:komi_fe/core/widgets/seller_bottom_nav.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/features/seller/orders/orders_page.dart';
import 'package:komi_fe/features/seller/dishes/dishes_page.dart';
import 'package:komi_fe/features/auth/register/register_page.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_page.dart';
import 'package:komi_fe/features/seller/overview/overview_page.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/features/seller/creation/creation_page.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_page.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/store_configuration_page.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_page.dart';
import 'package:komi_fe/features/buyer/location/location_permission_page.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_page.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_page.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/customer_order_detail_page.dart';

String? _sellerBranchRedirect(
  GoRouterState state,
  ProviderContainer container,
) {
  final session = container.read(authSessionProvider);
  if (session == null || session.token.trim().isEmpty) {
    return RouteNames.login;
  }
  if (session.type != UserType.seller) {
    return RouteNames.home;
  }
  if (session.stores.isEmpty) {
    return RouteNames.creation;
  }

  final p = state.uri.path;
  if (p == RouteNames.seller || p == '${RouteNames.seller}/') {
    return '${RouteNames.seller}${RouteNames.overview}';
  }
  return null;
}

GoRouter createGoRouter(ProviderContainer container) {
  return GoRouter(
    initialLocation: RouteNames.home,
    refreshListenable: authSessionRouterRefresh,
    routes: [
      GoRoute(
        path: RouteNames.root,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const HomePage()),
      ),
      GoRoute(
        path: RouteNames.home,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const HomePage()),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const RegisterPage()),
      ),
      GoRoute(
        path: RouteNames.creation,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const CreationPage()),
      ),
      GoRoute(
        path: RouteNames.locationPermission,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const LocationPermissionPage()),
      ),
      GoRoute(
        path: RouteNames.restaurants,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return _page(
            key: state.pageKey,
            child: RestaurantsPage(
              initialSearchQuery: q != null && q.isNotEmpty ? q : null,
            ),
          );
        },
      ),
      GoRoute(
        path: '${RouteNames.restaurants}/:storeId',
        pageBuilder: (context, state) {
          final storeId = state.pathParameters['storeId'] ?? '';
          final storeName = state.extra as String? ?? '';
          return _page(
            key: state.pageKey,
            child: RestaurantDetailPage(storeId: storeId, storeName: storeName),
          );
        },
      ),
      GoRoute(
        path: RouteNames.checkout,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const CheckoutPage()),
      ),
      GoRoute(
        path: RouteNames.orders,
        pageBuilder: (context, state) =>
            _page(key: state.pageKey, child: const CustomerOrdersPage()),
      ),
      GoRoute(
        path: '${RouteNames.orders}/detalle/:orderId',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return _page(
            key: state.pageKey,
            child: CustomerOrderDetailPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.seller,
        redirect: (context, state) {
          return _sellerBranchRedirect(state, container);
        },
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              final location = state.uri.path;
              const tabs = [
                '${RouteNames.seller}${RouteNames.overview}',
                '${RouteNames.seller}${RouteNames.dishes}',
                '${RouteNames.seller}${RouteNames.orders}',
                '${RouteNames.seller}${RouteNames.dailyMenu}',
              ];
              final currentIndex = tabs.indexWhere(
                (t) => location.startsWith(t),
              );

              return Scaffold(
                backgroundColor: AppColors.primary,
                body: SellerMobileShell(
                  bottomBar: SellerBottomNav(
                    currentIndex: currentIndex,
                    tabs: tabs,
                  ),
                  child: child,
                ),
              );
            },
            routes: [
              GoRoute(
                path: RouteNames.orders,
                pageBuilder: (context, state) =>
                    _page(key: state.pageKey, child: const OrdersPage()),
              ),
              GoRoute(
                path: RouteNames.dailyMenu,
                pageBuilder: (context, state) =>
                    _page(key: state.pageKey, child: const DailyMenuPage()),
              ),
              GoRoute(
                path: RouteNames.overview,
                pageBuilder: (context, state) =>
                    _page(key: state.pageKey, child: const OverviewPage()),
              ),
              GoRoute(
                path: RouteNames.dishes,
                pageBuilder: (context, state) =>
                    _page(key: state.pageKey, child: const DishesPage()),
              ),
              GoRoute(
                path: RouteNames.storeConfiguration,
                pageBuilder: (context, state) => _page(
                  key: state.pageKey,
                  child: const StoreConfigurationPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundPage(),
  );
}

CustomTransitionPage<void> _page({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}
