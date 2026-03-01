import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum DeliveryType { pickup, delivery }

class OrderDish {
  final String name;
  final int quantity;
  final String? description;

  const OrderDish({
    required this.name,
    required this.quantity,
    this.description,
  });
}

class OrderCardData {
  final String customerName;
  final DeliveryType deliveryType;
  final List<String> paymentMethods;
  final double amount;
  final String timeAgo;
  final Color borderColor;
  final String? orderNumber;
  final List<OrderDish> dishes;
  final String? notes;

  const OrderCardData({
    required this.customerName,
    required this.deliveryType,
    required this.paymentMethods,
    required this.amount,
    required this.timeAgo,
    required this.borderColor,
    this.orderNumber,
    this.dishes = const [],
    this.notes,
  });
}

class OverviewOrderCard extends StatefulWidget {
  final OrderCardData data;

  const OverviewOrderCard({super.key, required this.data});

  @override
  State<OverviewOrderCard> createState() => _OverviewOrderCardState();
}

class _OverviewOrderCardState extends State<OverviewOrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.data.borderColor, width: 1.8),
        ),
        child: Column(
          children: [
            _buildHeader(),
            if (_isExpanded) _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _isExpanded
                      ? Icon(
                          Icons.keyboard_arrow_down_rounded,
                          key: const ValueKey('down'),
                          color: widget.data.borderColor,
                          size: 22,
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          key: const ValueKey('right'),
                          color: AppColors.textGray,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.data.customerName,
                  style: AppTextStyles.subtitle2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(
                widget.data.deliveryType == DeliveryType.pickup
                    ? Icons.directions_walk_rounded
                    : Icons.electric_moped_rounded,
                size: 18,
                color: AppColors.textGray,
              ),
              const SizedBox(width: 6),
              ...widget.data.paymentMethods
                  .map((m) => _PaymentBadge(method: m)),
              const SizedBox(width: 6),
              Text(
                'S/${widget.data.amount.toStringAsFixed(0)}',
                style: AppTextStyles.subtitle2
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: AppColors.textGray,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(
                  widget.data.timeAgo,
                  style: AppTextStyles.small,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textDark, width: 1.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pendiente',
                  style: AppTextStyles.small
                      .copyWith(color: AppColors.textDark, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 12, color: Colors.grey.shade200),
          if (widget.data.orderNumber != null) ...[
            Text(
              'N° de orden: ${widget.data.orderNumber}',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.data.dishes
                      .map((dish) => _buildDishRow(dish))
                      .toList(),
                ),
              ),
              if (widget.data.notes != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas:',
                        style: AppTextStyles.small
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.data.notes!,
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDishRow(OrderDish dish) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lunch_dining_rounded,
              size: 15, color: AppColors.textGray),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: AppTextStyles.small),
                if (dish.description != null)
                  Text(
                    dish.description!,
                    style:
                        AppTextStyles.small.copyWith(fontSize: 10, height: 1.3),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${dish.quantity}',
            style:
                AppTextStyles.small.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String method;

  const _PaymentBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (method) {
      'yape' => (const Color(0xFF6B21A8), 'Y'),
      'plin' => (const Color(0xFF2563EB), 'P'),
      'cash' => (const Color(0xFF16A34A), '\$'),
      _ => (AppColors.textGray, '?'),
    };

    return Container(
      margin: const EdgeInsets.only(right: 3),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
