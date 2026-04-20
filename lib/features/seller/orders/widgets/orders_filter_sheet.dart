import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum OrdersPaymentFilter { yapePlin, cash }

enum OrdersDeliveryFilter { pickup, delivery }

enum OrdersStatusFilter {
  pending,
  confirmed,
  ready,
  delivered,
  completed,
  cancelled,
}

class OrdersFilterSheet extends StatefulWidget {
  const OrdersFilterSheet({
    super.key,
    this.initialPayment,
    this.initialDelivery,
    this.initialStatus,
    required this.onApply,
  });

  final OrdersPaymentFilter? initialPayment;
  final OrdersDeliveryFilter? initialDelivery;
  final OrdersStatusFilter? initialStatus;
  final void Function(
    OrdersPaymentFilter? payment,
    OrdersDeliveryFilter? delivery,
    OrdersStatusFilter? status,
  )
  onApply;

  static Future<void> show(
    BuildContext context, {
    OrdersPaymentFilter? initialPayment,
    OrdersDeliveryFilter? initialDelivery,
    OrdersStatusFilter? initialStatus,
    required void Function(
      OrdersPaymentFilter? payment,
      OrdersDeliveryFilter? delivery,
      OrdersStatusFilter? status,
    )
    onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrdersFilterSheet(
        initialPayment: initialPayment,
        initialDelivery: initialDelivery,
        initialStatus: initialStatus,
        onApply: onApply,
      ),
    );
  }

  @override
  State<OrdersFilterSheet> createState() => _OrdersFilterSheetState();
}

class _OrdersFilterSheetState extends State<OrdersFilterSheet> {
  late OrdersPaymentFilter? _payment;
  late OrdersDeliveryFilter? _delivery;
  late OrdersStatusFilter? _status;

  @override
  void initState() {
    super.initState();
    _payment = widget.initialPayment;
    _delivery = widget.initialDelivery;
    _status = widget.initialStatus;
  }

  void _clear() {
    setState(() {
      _payment = null;
      _delivery = null;
      _status = null;
    });
  }

  void _apply() {
    widget.onApply(_payment, _delivery, _status);
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
            title: 'Recojo',
            children: [
              _FilterChip(
                label: 'Para recoger',
                icon: const Icon(
                  Icons.directions_walk_rounded,
                  size: 18,
                  color: AppColors.textGray,
                ),
                selected: _delivery == OrdersDeliveryFilter.pickup,
                onTap: () => setState(() {
                  _delivery = _delivery == OrdersDeliveryFilter.pickup
                      ? null
                      : OrdersDeliveryFilter.pickup;
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Delivery',
                icon: const Icon(
                  Icons.electric_moped_rounded,
                  size: 18,
                  color: AppColors.textGray,
                ),
                selected: _delivery == OrdersDeliveryFilter.delivery,
                onTap: () => setState(() {
                  _delivery = _delivery == OrdersDeliveryFilter.delivery
                      ? null
                      : OrdersDeliveryFilter.delivery;
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.phone_android,
                    size: 18,
                    color: AppColors.textGray,
                  ),
                ),
                selected: _payment == OrdersPaymentFilter.yapePlin,
                onTap: () => setState(() {
                  _payment = _payment == OrdersPaymentFilter.yapePlin
                      ? null
                      : OrdersPaymentFilter.yapePlin;
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Efectivo',
                icon: const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.textGray,
                ),
                selected: _payment == OrdersPaymentFilter.cash,
                onTap: () => setState(() {
                  _payment = _payment == OrdersPaymentFilter.cash
                      ? null
                      : OrdersPaymentFilter.cash;
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusSection(),
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

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: AppTextStyles.subtitle2.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              label: 'Pendiente',
              value: OrdersStatusFilter.pending,
              groupValue: _status,
              onTap: (v) => setState(() => _status = v),
            ),
            _StatusChip(
              label: 'Confirmado',
              value: OrdersStatusFilter.confirmed,
              groupValue: _status,
              onTap: (v) => setState(() => _status = v),
            ),
            _StatusChip(
              label: 'Listo',
              value: OrdersStatusFilter.ready,
              groupValue: _status,
              onTap: (v) => setState(() => _status = v),
            ),
            _StatusChip(
              label: 'Enviado',
              value: OrdersStatusFilter.delivered,
              groupValue: _status,
              onTap: (v) => setState(() => _status = v),
            ),
            _StatusChip(
              label: 'Completado',
              value: OrdersStatusFilter.completed,
              groupValue: _status,
              onTap: (v) => setState(() => _status = v),
            ),
            _StatusChip(
              label: 'Cancelado',
              value: OrdersStatusFilter.cancelled,
              groupValue: _status,
              onTap: (v) => setState(() => _status = v),
            ),
          ],
        ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  final String label;
  final OrdersStatusFilter value;
  final OrdersStatusFilter? groupValue;
  final ValueChanged<OrdersStatusFilter> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentLight : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.textGray.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDark,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Labels for active filter chips (aligned with the bottom sheet).
extension OrdersPaymentFilterBadgeLabel on OrdersPaymentFilter {
  String get badgeLabel => switch (this) {
    OrdersPaymentFilter.yapePlin => 'Yape/Plin',
    OrdersPaymentFilter.cash => 'Efectivo',
  };
}

extension OrdersDeliveryFilterBadgeLabel on OrdersDeliveryFilter {
  String get badgeLabel => switch (this) {
    OrdersDeliveryFilter.pickup => 'Para recoger',
    OrdersDeliveryFilter.delivery => 'Delivery',
  };
}

extension OrdersStatusFilterBadgeLabel on OrdersStatusFilter {
  String get badgeLabel => switch (this) {
    OrdersStatusFilter.pending => 'Pendiente',
    OrdersStatusFilter.confirmed => 'Confirmado',
    OrdersStatusFilter.ready => 'Listo',
    OrdersStatusFilter.delivered => 'Enviado',
    OrdersStatusFilter.completed => 'Completado',
    OrdersStatusFilter.cancelled => 'Cancelado',
  };
}
