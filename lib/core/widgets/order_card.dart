import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

enum DeliveryType { pickup, delivery }

enum OrderStatus {
  pending,
  confirmed,
  ready,
  delivered,
  completed,
  cancelled;

  String get apiValue => name;

  static OrderStatus fromApi(String? raw) {
    switch (raw) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'ready':
        return OrderStatus.ready;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

extension OrderStatusBorderColor on OrderStatus {
  Color get borderColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFCA8A04);
      case OrderStatus.confirmed:
        return const Color(0xFF2563EB);
      case OrderStatus.ready:
        return const Color(0xFF16A34A);
      case OrderStatus.delivered:
        return const Color(0xFF0891B2);
      case OrderStatus.completed:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
        return const Color(0xFF64748B);
    }
  }

  String get labelEs {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Destination statuses allowed from [current] according to [deliveryType] (transition rules).
List<OrderStatus> allowedNextOrderStatuses({
  required DeliveryType deliveryType,
  required OrderStatus current,
}) {
  switch (deliveryType) {
    case DeliveryType.pickup:
      switch (current) {
        case OrderStatus.pending:
          return [OrderStatus.confirmed, OrderStatus.cancelled];
        case OrderStatus.confirmed:
          return [
            OrderStatus.ready,
            OrderStatus.completed,
            OrderStatus.cancelled,
          ];
        case OrderStatus.ready:
          return [OrderStatus.completed, OrderStatus.cancelled];
        case OrderStatus.delivered:
        case OrderStatus.completed:
        case OrderStatus.cancelled:
          return [];
      }
    case DeliveryType.delivery:
      switch (current) {
        case OrderStatus.pending:
          return [OrderStatus.confirmed, OrderStatus.cancelled];
        case OrderStatus.confirmed:
          return [
            OrderStatus.ready,
            OrderStatus.delivered,
            OrderStatus.cancelled,
          ];
        case OrderStatus.ready:
          return [OrderStatus.delivered, OrderStatus.cancelled];
        case OrderStatus.delivered:
          return [OrderStatus.completed, OrderStatus.cancelled];
        case OrderStatus.completed:
        case OrderStatus.cancelled:
          return [];
      }
  }
}

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
  final String orderId;
  final String customerName;
  final DeliveryType deliveryType;
  final List<String> paymentMethods;
  final double amount;
  final String timeAgo;
  final OrderStatus status;
  final String? orderNumber;
  final List<OrderDish> dishes;
  final String? notes;

  const OrderCardData({
    required this.orderId,
    required this.customerName,
    required this.deliveryType,
    required this.paymentMethods,
    required this.amount,
    required this.timeAgo,
    required this.status,
    this.orderNumber,
    this.dishes = const [],
    this.notes,
  });
}

class OrderCard extends StatefulWidget {
  final OrderCardData data;

  /// Called when the user selects a new status from the dialog.
  /// Should call the API and throw on failure.
  /// The UI will only update after this completes successfully.
  /// [cancelledReason] solo aplica si [newStatus] es [OrderStatus.cancelled].
  final Future<void> Function(
    OrderStatus newStatus, {
    String? cancelledReason,
  })? onStatusChange;

  const OrderCard({super.key, required this.data, this.onStatusChange});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExpanded = false;
  bool _isUpdating = false;
  late OrderStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.data.status;
  }

  Color get _borderColor => _status.borderColor;

  String get _statusLabel => _status.labelEs;

  bool get _isTerminalCompleted => _status == OrderStatus.completed;

  bool get _isTerminalCancelled => _status == OrderStatus.cancelled;

  bool get _isTerminalVisual => _isTerminalCompleted || _isTerminalCancelled;

  Color get _cardBackgroundColor {
    if (_isTerminalCancelled) {
      return const Color(0xFFF8FAFC);
    }
    if (_isTerminalCompleted) {
      return const Color(0xFFF0FDF4);
    }
    return AppColors.white;
  }

  Future<void> _showStatusDialog() async {
    final allowed = allowedNextOrderStatuses(
      deliveryType: widget.data.deliveryType,
      current: _status,
    );

    if (allowed.isEmpty) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Estado de la orden', style: AppTextStyles.subtitle2),
            content: Text(
              'No hay cambios de estado disponibles para esta orden.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGray,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (!context.mounted) return;
    final selected = await showDialog<OrderStatus>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado de la orden', style: AppTextStyles.subtitle2),
                const SizedBox(height: 8),
                Divider(color: AppColors.textGray.withValues(alpha: 0.2)),
                const SizedBox(height: 4),
                ...allowed.map(
                  (s) => _StatusOptionTile(
                    label: s.labelEs,
                    value: s,
                    groupValue: _status,
                    onSelected: (v) => Navigator.of(context).pop(v),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    String? cancelledReason;
    if (selected == OrderStatus.cancelled && widget.onStatusChange != null) {
      cancelledReason = await _promptCancellationReason();
      if (!mounted) return;
      if (cancelledReason == null) return;
    }

    if (widget.onStatusChange != null) {
      setState(() => _isUpdating = true);
      try {
        await widget.onStatusChange!(
          selected,
          cancelledReason: cancelledReason,
        );
        if (mounted) setState(() => _status = selected);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo actualizar el estado. Intenta de nuevo.',
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    } else {
      setState(() => _status = selected);
    }
  }

  /// Devuelve el motivo o `null` si el usuario cierra sin confirmar.
  Future<String?> _promptCancellationReason() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setInner) {
            return AlertDialog(
              title: Text(
                'Motivo de cancelación',
                style: AppTextStyles.subtitle2,
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Indica por qué cancelas la orden',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGray,
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.textGray.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: AppTextStyles.bodySmall,
                onChanged: (_) => setInner(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Atrás'),
                ),
                FilledButton(
                  onPressed: controller.text.trim().isEmpty
                      ? null
                      : () =>
                          Navigator.of(ctx).pop(controller.text.trim()),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _borderColor,
            width: _isTerminalVisual ? 2 : 1.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isTerminalVisual) _buildTerminalBanner(),
              _buildHeader(),
              if (_isExpanded) _buildDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalBanner() {
    final accent = _borderColor;
    return Material(
      color: accent.withValues(alpha: 0.11),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              _isTerminalCancelled
                  ? Icons.cancel_outlined
                  : Icons.task_alt_rounded,
              size: 17,
              color: accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isTerminalCancelled ? 'Orden cancelada' : 'Orden completada',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
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
                          color: _borderColor,
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
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
              ...widget.data.paymentMethods.map(
                (m) => _PaymentBadge(method: m),
              ),
              const SizedBox(width: 6),
              Text(
                'S/${widget.data.amount.toStringAsFixed(0)}',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!_isTerminalVisual) ...[
                const SizedBox(width: 2),
                if (_isUpdating)
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  InkWell(
                    onTap: _showStatusDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(widget.data.timeAgo, style: AppTextStyles.small),
              ),
              _buildStatusPill(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill() {
    final accent = _borderColor;
    if (_isTerminalVisual) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Text(
          _statusLabel,
          style: AppTextStyles.small.copyWith(
            color: accent.withValues(alpha: 0.95),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textDark, width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusLabel,
        style: AppTextStyles.small.copyWith(
          color: AppColors.textDark,
          fontSize: 11,
        ),
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
                        style: AppTextStyles.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.data.notes!, style: AppTextStyles.small),
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
          const Icon(Icons.dining_sharp, size: 15, color: AppColors.textGray),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: AppTextStyles.small),
                if (dish.description != null)
                  Text(
                    dish.description!,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${dish.quantity}',
            style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String method;

  const _PaymentBadge({required this.method});

  static const _badgeSize = 18.0;
  static const _yapePlinWidth = 64.0;
  static const _yapePlinHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    final normalized = method.toLowerCase();

    if (normalized == 'yape_plin') {
      return Padding(
        padding: const EdgeInsets.only(right: 3),
        child: SizedBox(
          width: _yapePlinWidth,
          height: _yapePlinHeight,
          child: Image.asset(
            'assets/images/yape_plin.webp',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                _fallbackBadge(const Color(0xFF6B21A8), 'Y/P'),
          ),
        ),
      );
    }

    final (color, label) = switch (normalized) {
      'cash' => (const Color(0xFF16A34A), '\$'),
      _ => (AppColors.textGray, '?'),
    };

    return _buildColoredBadge(color, label);
  }

  Widget _fallbackBadge(Color color, String label) {
    return Container(
      width: _badgeSize,
      height: _badgeSize,
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

  Widget _buildColoredBadge(Color color, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 3),
      width: _badgeSize,
      height: _badgeSize,
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

class _StatusOptionTile extends StatelessWidget {
  const _StatusOptionTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final OrderStatus value;
  final OrderStatus groupValue;
  final ValueChanged<OrderStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentLight.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onSelected(value),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
