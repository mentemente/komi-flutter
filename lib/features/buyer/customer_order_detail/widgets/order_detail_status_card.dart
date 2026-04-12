import 'package:flutter/material.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_accordion.dart';
import 'package:komi_fe/features/buyer/customer_order_detail/widgets/order_detail_timeline.dart';

class OrderDetailStatusCard extends StatelessWidget {
  const OrderDetailStatusCard({
    super.key,
    required this.steps,
    required this.activeIndex,
  });

  final List<OrderDetailTimelineStep> steps;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return OrderDetailAccordion(
      icon: Icons.route_rounded,
      title: 'Seguimiento',
      initiallyExpanded: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
        child: OrderDetailTimeline(
          steps: steps,
          activeIndex: activeIndex,
        ),
      ),
    );
  }
}
