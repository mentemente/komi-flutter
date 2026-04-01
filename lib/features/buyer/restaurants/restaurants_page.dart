import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/logo.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/order_in_progress_card.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurant_card.dart';
import 'package:komi_fe/features/buyer/restaurants/widgets/restaurants_filter_sheet.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final _searchController = TextEditingController();
  RestaurantPaymentFilter? _paymentFilter;
  RestaurantDeliveryFilter? _deliveryFilter;

  // TODO: Remove this once we have the API implemented
  static final List<RestaurantCardData> _exampleCards = [
    RestaurantCardData(
      menuTitle: 'Menú Luisa',
      priceRange: 's/ 10-20',
      hasPickup: true,
      hasDelivery: true,
      hasYapePlin: true,
      hasCash: true,
      restaurantName: 'Luisa',
      takeawayPrice: 'S/13.00',
      dailyItems: ['Sopa de moron', 'Ensalada de palta', 'Papa a la huancaina'],
      mainDishes: [
        'Macarrones c/ Pollo',
        'Asado c/ Frejoles',
        'Cau-Cau',
        'Ceviche de pollo',
        'Pescado frito Frejoles',
      ],
    ),
    RestaurantCardData(
      menuTitle: 'Menú Doña Rosa',
      priceRange: 's/ 8-15',
      hasPickup: true,
      hasDelivery: false,
      hasYapePlin: true,
      hasCash: true,
      restaurantName: 'Doña Rosa',
      takeawayPrice: 'S/10.00',
      dailyItems: ['Caldo de gallina', 'Arroz con pollo'],
      mainDishes: ['Lomo saltado', 'Ají de gallina', 'Tallarín saltado'],
    ),
    RestaurantCardData(
      menuTitle: 'Menú El Rincón',
      priceRange: 's/ 12-25',
      hasPickup: true,
      hasDelivery: true,
      hasYapePlin: true,
      hasCash: false,
      restaurantName: 'El Rincón',
      takeawayPrice: 'S/15.00',
      dailyItems: ['Crema de espárragos', 'Ensalada César'],
      mainDishes: ['Seco de cordero', 'Arroz con mariscos', 'Causa rellena'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    RestaurantsFilterSheet.show(
      context,
      initialPayment: _paymentFilter,
      initialDelivery: _deliveryFilter,
      onApply: (payment, delivery) {
        setState(() {
          _paymentFilter = payment;
          _deliveryFilter = delivery;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 12),
                  _buildFilterButton(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OrderInProgressCard(onTapTracking: () {}),
                  ),
                  for (final card in _exampleCards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RestaurantCard(data: card, onTap: () {}),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Expanded(child: Logo(fontSize: 36)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
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

  Widget _buildFilterButton() {
    return Material(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openFilterSheet,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 22, color: AppColors.textDark),
              const SizedBox(width: 8),
              Text(
                'Filtrar',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textDark,
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
