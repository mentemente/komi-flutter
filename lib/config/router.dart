import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/widgets/seller_bottom_nav.dart';
import 'package:komi_fe/features/404/not_found_page.dart';
import 'package:komi_fe/features/auth/login/login_page.dart';
import 'package:komi_fe/features/auth/register/register_page.dart';
import 'package:komi_fe/features/home/home_page.dart';
import 'package:komi_fe/features/buyer/location/location_permission_page.dart';
import 'package:komi_fe/features/seller/creation/creation_page.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_page.dart';
import 'package:komi_fe/features/seller/dishes/dishes_page.dart';
import 'package:komi_fe/features/seller/orders/orders_page.dart';
import 'package:komi_fe/features/seller/overview/overview_page.dart';
import 'package:komi_fe/features/seller/profile/profile_page.dart';

final goRouter = _createRouter();

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: RouteNames.home,
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
        path: RouteNames.seller,
        redirect: (context, state) {
          final p = state.uri.path;
          if (p == RouteNames.seller || p == '${RouteNames.seller}/') {
            return '${RouteNames.seller}${RouteNames.overview}';
          }
          return null;
        },
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              final location = state.uri.path;
              const tabs = [
                '${RouteNames.seller}${RouteNames.orders}',
                '${RouteNames.seller}${RouteNames.dailyMenu}',
                '${RouteNames.seller}${RouteNames.overview}',
                '${RouteNames.seller}${RouteNames.dishes}',
                '${RouteNames.seller}${RouteNames.profile}',
              ];
              final currentIndex = tabs.indexWhere(
                (t) => location.startsWith(t),
              );

              return Scaffold(
                body: child,
                bottomNavigationBar: SellerBottomNav(
                  currentIndex: currentIndex,
                  tabs: tabs,
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
                path: RouteNames.profile,
                pageBuilder: (context, state) =>
                    _page(key: state.pageKey, child: const ProfilePage()),
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
