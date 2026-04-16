import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/logout_button.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_controller.dart';
import 'package:komi_fe/features/buyer/customer_orders/customer_orders_state.dart';
import 'package:komi_fe/features/buyer/customer_orders/widgets/customer_order_card.dart';

class CustomerOrdersPage extends ConsumerStatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  ConsumerState<CustomerOrdersPage> createState() =>
      _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends ConsumerState<CustomerOrdersPage> {
  late final CustomerOrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerOrdersController(
      ServiceLocator.customerOrdersService,
    );
    _controller.state.addListener(_onControllerChanged);
    if (ref.read(authSessionProvider) == null) {
      _controller.setUnauthenticated();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() => _controller.load();

  @override
  void dispose() {
    _controller.state.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthResponse?>(authSessionProvider, (previous, next) {
      if (next == null) {
        _controller.setUnauthenticated();
      } else if (previous == null) {
        _load();
      }
    });
    final loggedIn = ref.watch(authSessionProvider) != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MobileViewportContainer(
        backgroundColor: AppColors.background,
        panelColor: AppColors.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(RouteNames.restaurants),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textDark,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                        side: BorderSide(
                          color: AppColors.textGray.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pedidos en curso',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (loggedIn) ...[
                      const SizedBox(width: 8),
                      const LogoutButton(),
                    ],
                  ],
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final state = _controller.state.value;

    if (state is CustomerOrdersUnauthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Inicia sesión para ver tus pedidos en curso.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CustomerOrdersLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state is CustomerOrdersError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    if (state is CustomerOrdersReady) {
      if (state.orders.isEmpty) {
        return Center(
          child: Text(
            'No hay pedidos en curso.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: state.orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = state.orders[index];
            return CustomerOrderCard(
              data: order.toCardData(),
              onTap: () => context.push(
                RouteNames.buyerOrderDetail(order.id),
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
