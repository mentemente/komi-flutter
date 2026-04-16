import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

class RestaurantCardData {
  const RestaurantCardData({
    required this.menuTitle,
    required this.hasPickup,
    required this.hasDelivery,
    required this.hasYapePlin,
    required this.hasCash,
    required this.restaurantName,
    required this.takeawayPrice,
    required this.dailyItems,
    required this.mainDishes,
    this.storeId,
    this.imagePath,
    this.imageUrl,
  });

  final String menuTitle;
  final bool hasPickup;
  final bool hasDelivery;
  final bool hasYapePlin;
  final bool hasCash;
  final String restaurantName;
  final String takeawayPrice;
  final List<String> dailyItems;
  final List<String> mainDishes;

  final String? storeId;

  final String? imagePath;

  final String? imageUrl;
}

const String _defaultRestaurantImagePath = 'assets/images/ollin_y_pizarra.webp';

/// Outer border radius of the card; the content is clipped a bit more to not eat the border stroke.
const double _kCardRadius = 16;
const double _kCardInnerClipRadius = 14;

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
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: Border.all(color: AppColors.textDark, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_kCardInnerClipRadius),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _buildLeftSection()),
                  Expanded(flex: 2, child: _buildRightSection(context)),
                ],
              ),
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
                          if (data.hasPickup)
                            const Icon(
                              Icons.directions_walk_rounded,
                              size: 24,
                              color: AppColors.textDark,
                            ),
                          if (data.hasPickup && data.hasDelivery)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                '/',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (data.hasDelivery)
                            const Icon(
                              Icons.electric_moped_rounded,
                              size: 24,
                              color: AppColors.textDark,
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
                              color: AppColors.textDark,
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

  Widget _buildRightSection(BuildContext context) {
    final netUrl = data.imageUrl;
    final assetPath = data.imagePath ?? _defaultRestaurantImagePath;

    return Container(
      color: AppColors.white,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: netUrl != null && netUrl.isNotEmpty
          ? GestureDetector(
              onTap: () => _showFullscreenMenuImage(context, netUrl),
              behavior: HitTestBehavior.opaque,
              child: Image.network(
                netUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, _, _) => Icon(
                  Icons.restaurant_menu_rounded,
                  size: 40,
                  color: AppColors.textGray.withValues(alpha: 0.4),
                ),
              ),
            )
          : Image.asset(
              assetPath,
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

void _showFullscreenMenuImage(BuildContext context, String imageUrl) {
  showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.94),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: _FullscreenMenuImageView(imageUrl: imageUrl),
      );
    },
  );
}

class _FullscreenMenuImageView extends StatelessWidget {
  const _FullscreenMenuImageView({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: padding.top + 4,
                bottom: padding.bottom + 4,
                left: 8,
                right: 8,
              ),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                clipBehavior: Clip.none,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    width: size.width - 16,
                    height: size.height - padding.vertical - 8,
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 120,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: padding.top + 4,
            right: 8,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Cerrar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
