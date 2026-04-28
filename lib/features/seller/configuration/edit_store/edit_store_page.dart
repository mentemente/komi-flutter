import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/configuration/models/seller_store_model.dart';
import 'package:komi_fe/features/seller/creation/widgets/delivery_options_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/payment_method_section.dart';
import 'package:komi_fe/features/seller/creation/widgets/schedule_section.dart';

class EditStorePage extends StatefulWidget {
  const EditStorePage({
    super.key,
    required this.store,
    this.embedded = false,
    this.onSaved,
  });

  final SellerStore store;

  /// Si es true, solo se pinta el formulario (sin [Scaffold] ni AppBar); el padre debe dar navegación y cabecera.
  final bool embedded;

  /// Tras guardar exitosamente en modo incrustado; no se hace `pop`.
  final VoidCallback? onSaved;

  @override
  State<EditStorePage> createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  static const _apiDayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  // Schedules
  ScheduleMode _scheduleMode = ScheduleMode.custom;
  TimeOfDay _allDaysOpen = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _allDaysClose = const TimeOfDay(hour: 20, minute: 0);
  late List<bool> _enabledDays;
  late List<TimeOfDay> _dayOpenTimes;
  late List<TimeOfDay> _dayCloseTimes;

  // Delivery
  final Set<DeliveryOption> _deliveryOptions = {};
  final _deliveryCostController = TextEditingController();

  // Payment
  final Set<PaymentMethod> _paymentMethods = {};

  /// URL devuelta por el upload de QR (no incluye el QR previo del servidor hasta que el usuario sube de nuevo).
  String? _paymentQrFromUpload;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initSchedules();
    _initDelivery();
    _initPayments();
    _deliveryCostController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _deliveryCostController.removeListener(_onChanged);
    _deliveryCostController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  // ──────────────────────────── Init helpers ────────────────────────────

  static TimeOfDay _parseTime(String? s) {
    if (s == null || s.isEmpty) return const TimeOfDay(hour: 8, minute: 0);
    final parts = s.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 8, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  void _initSchedules() {
    _enabledDays = List.filled(7, false);
    _dayOpenTimes = List.generate(
      7,
      (_) => const TimeOfDay(hour: 8, minute: 0),
    );
    _dayCloseTimes = List.generate(
      7,
      (_) => const TimeOfDay(hour: 20, minute: 0),
    );

    for (final schedule in widget.store.schedules) {
      final idx = _apiDayKeys.indexOf(schedule.day.toLowerCase());
      if (idx < 0) continue;
      _enabledDays[idx] = !schedule.isClosed;
      if (!schedule.isClosed) {
        _dayOpenTimes[idx] = _parseTime(schedule.open);
        _dayCloseTimes[idx] = _parseTime(schedule.close);
      }
    }

    // If all days are open with the same open/close → allDays mode
    if (_enabledDays.every((e) => e)) {
      final firstOpen = _dayOpenTimes[0];
      final firstClose = _dayCloseTimes[0];
      final sameOpen = _dayOpenTimes.every(
        (t) => t.hour == firstOpen.hour && t.minute == firstOpen.minute,
      );
      final sameClose = _dayCloseTimes.every(
        (t) => t.hour == firstClose.hour && t.minute == firstClose.minute,
      );
      if (sameOpen && sameClose) {
        _scheduleMode = ScheduleMode.allDays;
        _allDaysOpen = firstOpen;
        _allDaysClose = firstClose;
      }
    }
  }

  void _initDelivery() {
    if (widget.store.pickupEnabled) _deliveryOptions.add(DeliveryOption.pickup);
    if (widget.store.deliveryEnabled) {
      _deliveryOptions.add(DeliveryOption.delivery);
    }
    if (widget.store.deliveryEnabled && widget.store.deliveryCost > 0) {
      final raw = widget.store.deliveryCost;
      _deliveryCostController.text = raw % 1 == 0
          ? raw.toInt().toString()
          : raw.toStringAsFixed(2);
    }
  }

  void _initPayments() {
    if (widget.store.payments.prepaid) {
      _paymentMethods.add(PaymentMethod.yapePlin);
    }
    if (widget.store.payments.cashOnDelivery) {
      _paymentMethods.add(PaymentMethod.cash);
    }
  }

  // ──────────────────────────── Helpers ────────────────────────────────

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

  bool _isFormValid() {
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

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) setState(() => onPicked(picked));
  }

  Future<void> _onSave() async {
    if (!_isFormValid() || _isSubmitting) return;
    final loc = widget.store.location;
    if (loc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La tienda no tiene ubicación registrada.'),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final pickup = _deliveryOptions.contains(DeliveryOption.pickup);
      final delivery = _deliveryOptions.contains(DeliveryOption.delivery);
      final costStr = _deliveryCostController.text.trim().replaceFirst(
        ',',
        '.',
      );
      final deliveryCost = delivery ? (double.tryParse(costStr) ?? 0) : 0.0;

      final prepaid = _paymentMethods.contains(PaymentMethod.yapePlin);
      final qr = _paymentQrFromUpload?.trim();
      final paymentQr = prepaid && qr != null && qr.isNotEmpty ? qr : null;

      await ServiceLocator.storeService.patchStore(
        storeId: widget.store.id,
        schedules: _schedulesPayload(),
        pickupEnabled: pickup,
        deliveryEnabled: delivery,
        deliveryCost: deliveryCost,
        cashOnDelivery: _paymentMethods.contains(PaymentMethod.cash),
        prepaid: prepaid,
        latitude: loc.lat,
        longitude: loc.lng,
        paymentQr: paymentQr,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tienda actualizada correctamente')),
      );
      if (widget.embedded) {
        widget.onSaved?.call();
      } else {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.displayMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ──────────────────────────── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final form = SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScheduleSection(
                  mode: _scheduleMode,
                  onModeChanged: (m) => setState(() => _scheduleMode = m),
                  allDaysOpen: _allDaysOpen,
                  allDaysClose: _allDaysClose,
                  onAllDaysOpenTap: () => _pickTime(
                    initial: _allDaysOpen,
                    onPicked: (t) => _allDaysOpen = t,
                  ),
                  onAllDaysCloseTap: () => _pickTime(
                    initial: _allDaysClose,
                    onPicked: (t) => _allDaysClose = t,
                  ),
                  enabledDays: _enabledDays,
                  onDayToggled: (i) =>
                      setState(() => _enabledDays[i] = !_enabledDays[i]),
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
                ),
                const SizedBox(height: 28),
                DeliveryOptionsSection(
                  selectedOptions: _deliveryOptions,
                  onOptionToggled: _toggleDeliveryOption,
                  deliveryCostController: _deliveryCostController,
                ),
                const SizedBox(height: 28),
                PaymentMethodSection(
                  selectedMethods: _paymentMethods,
                  onMethodToggled: _togglePaymentMethod,
                  onPaymentQrUrlChanged: (url) =>
                      setState(() => _paymentQrFromUpload = url),
                  initialPaymentQrUrl: widget.store.paymentQr,
                  qrRequiredMessage: null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _isFormValid() && !_isSubmitting
                        ? _onSave
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.35,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(
                      _isSubmitting ? 'Guardando…' : 'Guardar cambios',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return form;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.primary,
        ),
        title: Text(
          'Editar tienda',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: form,
    );
  }
}
