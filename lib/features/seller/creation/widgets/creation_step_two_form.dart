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
    this.onPaymentQrUrlChanged,
    this.paymentQrRequiredMessage,
    required this.onBack,
    required this.onCreate,
    this.isCreateEnabled = false,
    this.isSubmitting = false,
  });

  final int currentStep;
  final int totalSteps;

  final Set<DeliveryOption> selectedDeliveryOptions;
  final void Function(DeliveryOption) onDeliveryOptionToggled;
  final TextEditingController deliveryCostController;

  final Set<PaymentMethod> selectedPaymentMethods;
  final void Function(PaymentMethod) onPaymentMethodToggled;
  final ValueChanged<String?>? onPaymentQrUrlChanged;
  final String? paymentQrRequiredMessage;

  final VoidCallback onBack;
  final VoidCallback onCreate;
  final bool isCreateEnabled;
  final bool isSubmitting;

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
          onPaymentQrUrlChanged: onPaymentQrUrlChanged,
          qrRequiredMessage: paymentQrRequiredMessage,
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
                  onPressed:
                      (isCreateEnabled && !isSubmitting) ? onCreate : null,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear'),
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
