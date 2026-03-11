import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum RestaurantPaymentFilter { yapePlin, cash }

enum RestaurantDeliveryFilter { pickup, delivery }

class RestaurantsFilterSheet extends StatefulWidget {
  const RestaurantsFilterSheet({
    super.key,
    this.initialPayment,
    this.initialDelivery,
    required this.onApply,
  });

  final RestaurantPaymentFilter? initialPayment;
  final RestaurantDeliveryFilter? initialDelivery;
  final void Function(
    RestaurantPaymentFilter? payment,
    RestaurantDeliveryFilter? delivery,
  )
  onApply;

  static Future<void> show(
    BuildContext context, {
    RestaurantPaymentFilter? initialPayment,
    RestaurantDeliveryFilter? initialDelivery,
    required void Function(
      RestaurantPaymentFilter? payment,
      RestaurantDeliveryFilter? delivery,
    )
    onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestaurantsFilterSheet(
        initialPayment: initialPayment,
        initialDelivery: initialDelivery,
        onApply: onApply,
      ),
    );
  }

  @override
  State<RestaurantsFilterSheet> createState() => _RestaurantsFilterSheetState();
}

class _RestaurantsFilterSheetState extends State<RestaurantsFilterSheet> {
  late RestaurantPaymentFilter? _payment;
  late RestaurantDeliveryFilter? _delivery;

  @override
  void initState() {
    super.initState();
    _payment = widget.initialPayment;
    _delivery = widget.initialDelivery;
  }

  void _clear() {
    setState(() {
      _payment = null;
      _delivery = null;
    });
  }

  void _apply() {
    widget.onApply(_payment, _delivery);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHandle(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Tipo de pago',
            children: [
              _FilterChip(
                label: 'Yape/Plin',
                icon: Image.asset(
                  'assets/images/yape_plin.webp',
                  height: 18,
                  width: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.phone_android,
                    size: 18,
                    color: AppColors.textGray,
                  ),
                ),
                selected: _payment == RestaurantPaymentFilter.yapePlin,
                onTap: () => setState(() {
                  _payment = _payment == RestaurantPaymentFilter.yapePlin
                      ? null
                      : RestaurantPaymentFilter.yapePlin;
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Efectivo',
                icon: Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.textGray,
                ),
                selected: _payment == RestaurantPaymentFilter.cash,
                onTap: () => setState(() {
                  _payment = _payment == RestaurantPaymentFilter.cash
                      ? null
                      : RestaurantPaymentFilter.cash;
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Recojo',
            children: [
              _FilterChip(
                label: 'Para recoger',
                icon: Icon(
                  Icons.directions_walk_rounded,
                  size: 18,
                  color: AppColors.textGray,
                ),
                selected: _delivery == RestaurantDeliveryFilter.pickup,
                onTap: () => setState(() {
                  _delivery = _delivery == RestaurantDeliveryFilter.pickup
                      ? null
                      : RestaurantDeliveryFilter.pickup;
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Delivery',
                icon: Icon(
                  Icons.electric_moped_rounded,
                  size: 18,
                  color: AppColors.textGray,
                ),
                selected: _delivery == RestaurantDeliveryFilter.delivery,
                onTap: () => setState(() {
                  _delivery = _delivery == RestaurantDeliveryFilter.delivery
                      ? null
                      : RestaurantDeliveryFilter.delivery;
                }),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _apply,
              child: const Text('Aplicar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text('Filtrar por:', style: AppTextStyles.h4),
        const Spacer(),
        TextButton(
          onPressed: _clear,
          child: Text('Limpiar', style: AppTextStyles.caption),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppColors.textGray,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.background,
            minimumSize: const Size(40, 40),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle2.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        Row(children: children),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.accentLight : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.textGray.withValues(alpha: 0.25),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 36, height: 20, child: Center(child: icon)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDark,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
