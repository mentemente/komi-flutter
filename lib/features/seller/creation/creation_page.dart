import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/widgets/komi_brand_panel.dart';
import 'package:komi_fe/core/widgets/responsive_layout.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:komi_fe/features/seller/creation/widgets/creation_step_one_form.dart';
import 'package:komi_fe/features/seller/creation/widgets/creation_step_two_form.dart';
import 'package:komi_fe/features/seller/creation/widgets/delivery_options_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/payment_method_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/schedule_section.dart';
import 'package:komi_fe/core/config/app_config.dart';
import 'package:komi_fe/features/seller/creation/places_service.dart';

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

  // Location coordinates
  double? _storeLatitude;
  double? _storeLongitude;

  static const String _googleMapsApiKey = AppConfig.googleMapsApiKey;

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
  String? _paymentQrUrl;
  bool _isSubmitting = false;

  static const _apiDayKeys = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

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
    if (_storeLatitude == null || _storeLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación')),
      );
      return;
    }
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
        if (method == PaymentMethod.yapePlin) {
          _paymentQrUrl = null;
        }
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
    if (_paymentMethods.contains(PaymentMethod.yapePlin)) {
      final qr = _paymentQrUrl?.trim();
      if (qr == null || qr.isEmpty) return false;
    }
    return true;
  }

  String _timeToApi(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  List<Map<String, dynamic>> _schedulesPayload() {
    if (_scheduleMode == ScheduleMode.allDays) {
      return List.generate(7, (i) {
        return <String, dynamic>{
          'day': _apiDayKeys[i],
          'open': _timeToApi(_allDaysOpen),
          'close': _timeToApi(_allDaysClose),
        };
      });
    }
    final list = <Map<String, dynamic>>[];
    for (var i = 0; i < 7; i++) {
      if (!_enabledDays[i]) continue;
      list.add(<String, dynamic>{
        'day': _apiDayKeys[i],
        'open': _timeToApi(_dayOpenTimes[i]),
        'close': _timeToApi(_dayCloseTimes[i]),
      });
    }
    return list;
  }

  Future<void> _onCreate() async {
    if (!_isStepTwoValid() || _isSubmitting) return;
    if (_storeLatitude == null || _storeLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación no disponible')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty
          ? 'Tienda de comida'
          : _descriptionController.text.trim();
      final paymentQr = (_paymentQrUrl != null && _paymentQrUrl!.isNotEmpty)
          ? _paymentQrUrl!
          : 'https://example.com/logo.png';

      final pickup = _deliveryOptions.contains(DeliveryOption.pickup);
      final delivery = _deliveryOptions.contains(DeliveryOption.delivery);
      final costStr = _deliveryCostController.text.trim().replaceFirst(
        ',',
        '.',
      );
      final deliveryCost = delivery ? (double.tryParse(costStr) ?? 0) : 0.0;

      final storeData = await ServiceLocator.storeService.createStore(
        name: name,
        description: description,
        paymentQr: paymentQr,
        schedules: _schedulesPayload(),
        pickupEnabled: pickup,
        deliveryEnabled: delivery,
        deliveryCost: deliveryCost,
        payments: {
          'cashOnDelivery': _paymentMethods.contains(PaymentMethod.cash),
          'prepaid': _paymentMethods.contains(PaymentMethod.yapePlin),
        },
        latitude: _storeLatitude!,
        longitude: _storeLongitude!,
      );

      if (!mounted) return;

      await ProviderScope.containerOf(
        context,
        listen: false,
      ).read(authSessionProvider.notifier).addStoreFromApiData(storeData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tienda creada correctamente')),
      );

      if (!mounted) return;
      context.go('${RouteNames.seller}${RouteNames.overview}');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear la tienda: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
      onLocationSelected: (LocationCoordinates coords) {
        setState(() {
          _storeLatitude = coords.latitude;
          _storeLongitude = coords.longitude;
        });
      },
      googleApiKey: _googleMapsApiKey,
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
      onPaymentQrUrlChanged: (url) => setState(() => _paymentQrUrl = url),
      paymentQrRequiredMessage:
          _paymentMethods.contains(PaymentMethod.yapePlin) &&
              (_paymentQrUrl == null || _paymentQrUrl!.trim().isEmpty)
          ? 'Debes subir el código QR de Yape o Plin para crear la tienda.'
          : null,
      onBack: _goBackToStepOne,
      onCreate: _onCreate,
      isCreateEnabled: _isStepTwoValid(),
      isSubmitting: _isSubmitting,
    );
  }
}
