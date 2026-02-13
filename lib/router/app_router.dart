import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/screens/food_screen.dart';
import 'package:komi_fe/screens/home_screen.dart';
import 'package:komi_fe/screens/login_screen.dart';
import 'package:komi_fe/screens/order_screen.dart';
import 'package:komi_fe/screens/register_screen.dart';
import 'package:komi_fe/screens/store_config_screen.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Mapeo: index → path
          const tabs = ['/orders', '/food', '/store'];
          final location = state.uri.path;
          final currentIndex = tabs.indexWhere((t) => location.startsWith(t));

          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex < 0 ? 0 : currentIndex,
              onTap: (index) => context.go(tabs[index]),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ordenes activas'),
                BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Carta del día'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Mi tienda'),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrderScreen(),
          ),
          GoRoute(
            path: '/food',
            name: 'food',
            builder: (context, state) => const FoodScreen(),
          ),
          GoRoute(
            path: '/store',
            name: 'store',
            builder: (context, state) => const StoreConfigScreen(),
          ),
        ],
      ),
    ],
  );
}
