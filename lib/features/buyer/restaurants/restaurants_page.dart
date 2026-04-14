import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/widgets/logout_button.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_state.dart';
import 'package:komi_fe/features/buyer/restaurants/restaurants_controller.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurant_card.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/order_in_progress_card.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurants_filter_sheet.dart';

class RestaurantsPage extends ConsumerStatefulWidget {
  const RestaurantsPage({super.key});

  @override
  ConsumerState<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends ConsumerState<RestaurantsPage> {
  final _searchController = TextEditingController();
  late final RestaurantsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantsController(
      restaurantsService: ServiceLocator.restaurantsService,
      locationService: ServiceLocator.locationService,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _controller.applySearch(value);
  }

  void _openFilterSheet(RestaurantsReady current) {
    RestaurantsFilterSheet.show(
      context,
      initialPayment: current.paymentFilter,
      initialDelivery: current.deliveryFilter,
      onApply: (payment, delivery) {
        _controller.applyFilters(payment: payment, delivery: delivery);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MobileViewportContainer(
        backgroundColor: AppColors.background,
        panelColor: AppColors.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              ValueListenableBuilder<RestaurantsState>(
                valueListenable: _controller.state,
                builder: (context, state, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        const SizedBox(width: 12),
                        _buildFilterButton(
                          state is RestaurantsReady ? state : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: ValueListenableBuilder<RestaurantsState>(
                  valueListenable: _controller.state,
                  builder: (context, state, _) {
                    return switch (state) {
                      RestaurantsLoading() => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      RestaurantsError(:final message) => _ErrorView(
                        message: message,
                        onRetry: _controller.load,
                      ),
                      RestaurantsReady(:final filtered) => _RestaurantsList(
                        cards: filtered,
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final loggedIn = ref.watch(authSessionProvider) != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(RouteNames.home),
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
              'Restaurantes',
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (loggedIn) ...[
            const SizedBox(width: 8),
            const LogoutButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar',
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.textGray,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildFilterButton(RestaurantsReady? state) {
    final hasFilters =
        state != null &&
        (state.paymentFilter != null || state.deliveryFilter != null);

    return Material(
      color: hasFilters ? AppColors.primary : AppColors.accentLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: state != null ? () => _openFilterSheet(state) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 22,
                color: hasFilters ? AppColors.white : AppColors.textDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrar',
                style: AppTextStyles.subtitle2.copyWith(
                  color: hasFilters ? AppColors.white : AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantsList extends ConsumerWidget {
  const _RestaurantsList({required this.cards});

  final List<RestaurantCardData> cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOrderBanner = ref.watch(authSessionProvider) != null;

    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No encontramos restaurantes\ncercanos a tu ubicación.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: cards.length + (showOrderBanner ? 1 : 0),
      itemBuilder: (context, index) {
        if (showOrderBanner && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: OrderInProgressCard(),
          );
        }
        final cardIndex = showOrderBanner ? index - 1 : index;
        final card = cards[cardIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RestaurantCard(
            data: card,
            onTap: (card.storeId != null && card.storeId!.isNotEmpty)
                ? () => context.go(
                      RouteNames.restaurantDetail(card.storeId!),
                      extra: card.restaurantName,
                    )
                : null,
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
