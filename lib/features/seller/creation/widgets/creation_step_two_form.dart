import 'package:flutter/material.dart';
import 'package:komi_fe/features/seller/creation/widgets/creation_header.dart';
import 'package:komi_fe/features/seller/creation/widgets/delivery_options_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/payment_method_section.dart';

class CreationStepTwoForm extends StatelessWidget {
  const CreationStepTwoForm({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.selectedDeliveryOptions,
    required this.onDeliveryOptionToggled,
    required this.deliveryCostController,
    required this.selectedPaymentMethods,
    required this.onPaymentMethodToggled,
    required this.onBack,
    required this.onCreate,
    this.isCreateEnabled = false,
  });

  final int currentStep;
  final int totalSteps;

  final Set<DeliveryOption> selectedDeliveryOptions;
  final void Function(DeliveryOption) onDeliveryOptionToggled;
  final TextEditingController deliveryCostController;

  final Set<PaymentMethod> selectedPaymentMethods;
  final void Function(PaymentMethod) onPaymentMethodToggled;

  final VoidCallback onBack;
  final VoidCallback onCreate;
  final bool isCreateEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CreationHeader(currentStep: currentStep, totalSteps: totalSteps),
        const SizedBox(height: 8),
        DeliveryOptionsSection(
          selectedOptions: selectedDeliveryOptions,
          onOptionToggled: onDeliveryOptionToggled,
          deliveryCostController: deliveryCostController,
        ),
        const SizedBox(height: 32),
        PaymentMethodSection(
          selectedMethods: selectedPaymentMethods,
          onMethodToggled: onPaymentMethodToggled,
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Atrás'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isCreateEnabled ? onCreate : null,
                  child: const Text('Crear'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
