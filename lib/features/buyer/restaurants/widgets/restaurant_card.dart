import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

/// Datos para mostrar en la card de un restaurante / menú.
class RestaurantCardData {
  const RestaurantCardData({
    required this.menuTitle,
    required this.priceRange,
    required this.hasPickup,
    required this.hasDelivery,
    required this.hasYapePlin,
    required this.hasCash,
    required this.restaurantName,
    required this.takeawayPrice,
    required this.dailyItems,
    required this.mainDishes,
    this.imagePath,
  });

  final String menuTitle;
  final String priceRange;
  final bool hasPickup;
  final bool hasDelivery;
  final bool hasYapePlin;
  final bool hasCash;
  final String restaurantName;
  final String takeawayPrice;
  final List<String> dailyItems;
  final List<String> mainDishes;

  final String? imagePath;
}

const String _defaultRestaurantImagePath = 'assets/images/ollin_y_pizarra.webp';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.data, this.onTap});

  final RestaurantCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildLeftSection()),
                Expanded(flex: 2, child: _buildRightSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.menuTitle,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.priceRange,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 16,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recojo',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_walk_rounded,
                            size: 24,
                            color: data.hasPickup
                                ? AppColors.textDark
                                : AppColors.textGray,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '/',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.electric_moped_rounded,
                            size: 24,
                            color: data.hasDelivery
                                ? AppColors.textDark
                                : AppColors.textGray,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 16,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pago',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (data.hasYapePlin)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Image.asset(
                                'assets/images/yape_plin.webp',
                                height: 24,
                                width: 56,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.phone_android,
                                  size: 28,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ),
                          if (data.hasYapePlin && data.hasCash)
                            Text(
                              ' / ',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                          if (data.hasCash)
                            Icon(
                              Icons.payments_outlined,
                              size: 24,
                              color: AppColors.textGray,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection() {
    final imagePath = data.imagePath ?? _defaultRestaurantImagePath;
    return Container(
      color: AppColors.white,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.restaurant_menu_rounded,
          size: 40,
          color: AppColors.textGray.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
