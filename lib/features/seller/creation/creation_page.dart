import 'package:flutter/material.dart';
import 'package:komi_fe/core/widgets/komi_brand_panel.dart';
import 'package:komi_fe/core/widgets/responsive_layout.dart';
import 'package:komi_fe/features/seller/creation/widgets/creation_step_one_form.dart';
import 'package:komi_fe/features/seller/creation/widgets/creation_step_two_form.dart';
import 'package:komi_fe/features/seller/creation/widgets/delivery_options_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/payment_method_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/schedule_section.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({super.key});

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  int _currentStep = 0;
  static const _totalSteps = 2;

  // --- Step 1: Info general + horarios ---
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();

  ScheduleMode _scheduleMode = ScheduleMode.allDays;

  TimeOfDay _allDaysOpen = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _allDaysClose = const TimeOfDay(hour: 16, minute: 0);

  late final List<bool> _enabledDays;
  late final List<TimeOfDay> _dayOpenTimes;
  late final List<TimeOfDay> _dayCloseTimes;

  // --- Step 2: Opciones de entrega + pago ---
  final Set<DeliveryOption> _deliveryOptions = {};
  final _deliveryCostController = TextEditingController();
  final Set<PaymentMethod> _paymentMethods = {};

  @override
  void initState() {
    super.initState();
    _enabledDays = List.filled(7, true);
    _dayOpenTimes = List.generate(
      7,
      (_) => const TimeOfDay(hour: 12, minute: 0),
    );
    _dayCloseTimes = List.generate(
      7,
      (_) => const TimeOfDay(hour: 16, minute: 0),
    );
    _deliveryCostController.addListener(_onStepTwoInputChanged);
  }

  void _onStepTwoInputChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _deliveryCostController.removeListener(_onStepTwoInputChanged);
    _deliveryCostController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  void _goToStepTwo() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _currentStep = 1);
  }

  void _goBackToStepOne() {
    setState(() => _currentStep = 0);
  }

  void _toggleDeliveryOption(DeliveryOption option) {
    setState(() {
      if (_deliveryOptions.contains(option)) {
        _deliveryOptions.remove(option);
      } else {
        _deliveryOptions.add(option);
      }
    });
  }

  void _togglePaymentMethod(PaymentMethod method) {
    setState(() {
      if (_paymentMethods.contains(method)) {
        _paymentMethods.remove(method);
      } else {
        _paymentMethods.add(method);
      }
    });
  }

  bool _isStepTwoValid() {
    if (_paymentMethods.isEmpty) return false;
    if (_deliveryOptions.isEmpty) return false;
    if (_deliveryOptions.contains(DeliveryOption.delivery)) {
      final cost = _deliveryCostController.text.trim();
      if (cost.isEmpty) return false;
      final value = double.tryParse(cost.replaceFirst(',', '.'));
      if (value == null || value < 0) return false;
    }
    return true;
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'am' : 'pm';
    return '$h:$m$period';
  }

  void _onCreate() {
    if (!_isStepTwoValid()) return;

    final dayLabels = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    final schedule = _scheduleMode == ScheduleMode.allDays
        ? {
            'modo': 'Todos los días',
            'Lunes – Domingo':
                '${_formatTime(_allDaysOpen)} – ${_formatTime(_allDaysClose)}',
          }
        : {
            'modo': 'Personalizado',
            'días': Map.fromIterables(
              dayLabels,
              List.generate(
                7,
                (i) => _enabledDays[i]
                    ? '${_formatTime(_dayOpenTimes[i])} – ${_formatTime(_dayCloseTimes[i])}'
                    : 'Cerrado',
              ),
            ),
          };

    final deliveryCost = _deliveryOptions.contains(DeliveryOption.delivery)
        ? _deliveryCostController.text.trim()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: KomiBrandPanel()),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      0 => _buildStepOne(),
      _ => _buildStepTwo(),
    };
  }

  Widget _buildStepOne() {
    return CreationStepOneForm(
      formKey: _formKey,
      currentStep: 0,
      totalSteps: _totalSteps,
      nameController: _nameController,
      addressController: _addressController,
      referenceController: _referenceController,
      descriptionController: _descriptionController,
      scheduleMode: _scheduleMode,
      onScheduleModeChanged: (m) => setState(() => _scheduleMode = m),
      allDaysOpen: _allDaysOpen,
      allDaysClose: _allDaysClose,
      onAllDaysOpenTap: () =>
          _pickTime(initial: _allDaysOpen, onPicked: (t) => _allDaysOpen = t),
      onAllDaysCloseTap: () =>
          _pickTime(initial: _allDaysClose, onPicked: (t) => _allDaysClose = t),
      enabledDays: _enabledDays,
      onDayToggled: (i) => setState(() => _enabledDays[i] = !_enabledDays[i]),
      dayOpenTimes: _dayOpenTimes,
      dayCloseTimes: _dayCloseTimes,
      onDayOpenTap: (i) => _pickTime(
        initial: _dayOpenTimes[i],
        onPicked: (t) => _dayOpenTimes[i] = t,
      ),
      onDayCloseTap: (i) => _pickTime(
        initial: _dayCloseTimes[i],
        onPicked: (t) => _dayCloseTimes[i] = t,
      ),
      onNext: _goToStepTwo,
    );
  }

  Widget _buildStepTwo() {
    return CreationStepTwoForm(
      currentStep: 1,
      totalSteps: _totalSteps,
      selectedDeliveryOptions: _deliveryOptions,
      onDeliveryOptionToggled: _toggleDeliveryOption,
      deliveryCostController: _deliveryCostController,
      selectedPaymentMethods: _paymentMethods,
      onPaymentMethodToggled: _togglePaymentMethod,
      onBack: _goBackToStepOne,
      onCreate: _onCreate,
      isCreateEnabled: _isStepTwoValid(),
    );
  }
}
