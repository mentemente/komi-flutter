import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/network/api_exception.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/formatting/currency_format.dart';
import 'package:komi_fe/core/widgets/mobile_viewport_container.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_provider.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';
import 'package:komi_fe/features/buyer/checkout/checkout_state.dart';
import 'package:komi_fe/features/buyer/restaurant_detail/restaurant_detail_model.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

const _kSuccessGreen = Color(0xFF2D9D5C);

// ── Checkout Page ─────────────────────────────────────────────────────────────

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Form Step 2
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  void _onStep2FieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fullNameCtrl.addListener(_onStep2FieldChanged);
    _phoneCtrl.addListener(_onStep2FieldChanged);
    _referenceCtrl.addListener(_onStep2FieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autofillFormFromSession();
    });
  }

  /// Autocomplete name and phone (same as `komi_auth_user_payload`).
  void _autofillFormFromSession() {
    final session = ref.read(authSessionProvider);
    if (session == null) return;

    if (_fullNameCtrl.text.trim().isEmpty) {
      final n = session.name.trim();
      if (n.isNotEmpty) {
        _fullNameCtrl.text = n.length > 100 ? n.substring(0, 100) : n;
      }
    }

    if (_phoneCtrl.text.trim().isEmpty) {
      final p = _normalizePeruPhoneForForm(session.phone);
      if (p != null) {
        _phoneCtrl.text = p;
      }
    }
  }

  /// Accepts 9 digits or prefix 51; returns 9XXXXXXXX for the form.
  String? _normalizePeruPhoneForForm(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 9 && digits.startsWith('9')) return digits;
    if (digits.length == 11 && digits.startsWith('51')) {
      final rest = digits.substring(2);
      if (rest.length == 9 && rest.startsWith('9')) return rest;
    }
    if (digits.length >= 9) {
      final last = digits.substring(digits.length - 9);
      if (last.startsWith('9')) return last;
    }
    return null;
  }

  @override
  void dispose() {
    _fullNameCtrl.removeListener(_onStep2FieldChanged);
    _phoneCtrl.removeListener(_onStep2FieldChanged);
    _referenceCtrl.removeListener(_onStep2FieldChanged);
    _pageController.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool _isStep2FormValid(CheckoutState checkout) {
    final phone = _phoneCtrl.text.trim();
    if (!_isValidPhoneStep2(phone)) return false;
    final name = _fullNameCtrl.text.trim();
    if (name.isEmpty || name.length > 100) return false;
    if (checkout.deliveryType == DeliveryType.delivery) {
      final reference = _referenceCtrl.text.trim();
      return reference.isNotEmpty && reference.length <= 250;
    }
    return true;
  }

  static bool _isValidPhoneStep2(String s) {
    return s.length == 9 && s.startsWith('9') && RegExp(r'^\d{9}$').hasMatch(s);
  }

  void _goTo(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _goTo(_currentStep - 1);
    } else {
      context.pop();
    }
  }

  Future<void> _confirmOrder() async {
    final notifier = ref.read(checkoutProvider.notifier);
    try {
      await notifier.submitOrder();
      if (!mounted) return;
      notifier.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Pedido confirmado! Te avisaremos cuando esté listo.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
          ),
          backgroundColor: _kSuccessGreen,
          duration: const Duration(seconds: 3),
        ),
      );
      context.go(RouteNames.orders);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showOrderError(e);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al confirmar el pedido. Intenta de nuevo.'),
        ),
      );
    }
  }

  void _showOrderError(ApiException e) {
    final String message;
    switch (e.code) {
      case 'ORDER_FOOD_INACTIVE':
        message = 'Uno o más productos ya no están disponibles';
      case 'STORE_OUTSIDE_BUSINESS_HOURS':
        message = 'El local está fuera de su horario de atención';
      case 'STORE_CLOSED_TODAY':
        message = 'El local está cerrado hoy';
      case 'ORDER_OPTION_NOT_ALLOWED':
        message =
            'El tipo de entrega seleccionado no está disponible en este local';
      default:
        message = e.displayMessage;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    if (checkout == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const SizedBox.shrink();
    }

    // If the session arrives after `hydrate()` (same data as SharedPreferences), fill in.
    ref.listen<AuthResponse?>(authSessionProvider, (prev, next) {
      if (next == null || !mounted) return;
      _autofillFormFromSession();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MobileViewportContainer(
        backgroundColor: AppColors.background,
        panelColor: AppColors.background,
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(checkout),
              _buildStep2(checkout),
              _buildStep3(checkout),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Verification ────────────────────────────────────────────────────

  Widget _buildStep1(CheckoutState checkout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: 'Verificación', onBack: _handleBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCartItems(checkout),
                const SizedBox(height: 16),
                _PriceRow(
                  label: 'Sub total',
                  amount: checkout.subtotal,
                  isTotal: false,
                ),
                const SizedBox(height: 20),
                Text(
                  '¿Cómo quieres tu pedido?',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDeliveryOptions(checkout),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/ollin_carrito.webp',
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(height: 150),
                  ),
                ),
                const SizedBox(height: 20),
                _PriceRow(
                  label: 'Total',
                  amount: checkout.total,
                  isTotal: true,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        _BottomBar(
          label: 'Resumen de pedido',
          total: checkout.total,
          onTap: () => _goTo(1),
        ),
      ],
    );
  }

  Widget _buildCartItems(CheckoutState checkout) {
    final items = <Widget>[];

    // ── Menu dishes (grouped by mainCourse) ──────────────────────────
    final groups = <String, List<MenuCartEntry>>{};
    for (final entry in checkout.input.menuCart) {
      groups.putIfAbsent(entry.mainCourse.id, () => []).add(entry);
    }

    for (final entry in groups.entries) {
      final entries = entry.value;
      final dish = entries.first.mainCourse;
      final count = entries.length;
      final totalPrice = dish.price * count;

      items.add(
        _CartItemRow(
          title:
              '${dish.name} ${count > 1 ? '($count) ' : ''}${formatSolesPrice(totalPrice)}',
          subtitle: entries
              .map((e) => _formatExtras(e))
              .where((s) => s.isNotEmpty)
              .join('\n'),
          onDelete: () =>
              ref.read(checkoutProvider.notifier).removeMenuEntry(dish.id),
        ),
      );
    }

    // ── Executive dishes ──────────────────────────────────────────────────
    for (final execEntry in checkout.input.execCounts.entries) {
      DishItem? dish;
      for (final d in checkout.input.dishes.executiveDish) {
        if (d.id == execEntry.key) {
          dish = d;
          break;
        }
      }
      if (dish == null) continue;
      final count = execEntry.value;
      final totalPrice = dish.price * count;

      items.add(
        _CartItemRow(
          title:
              '${dish.name} ${count > 1 ? '($count) ' : ''}${formatSolesPrice(totalPrice)}',
          subtitle: '',
          onDelete: () =>
              ref.read(checkoutProvider.notifier).decrementExecDish(dish!.id),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }

  Widget _buildDeliveryOptions(CheckoutState checkout) {
    final info = checkout.input.storeInfo;
    return Column(
      children: [
        if (info.pickupEnabled)
          _DeliveryOption(
            label: 'Recojo en tienda',
            sublabel: '',
            isSelected: checkout.deliveryType == DeliveryType.pickup,
            onTap: () => ref
                .read(checkoutProvider.notifier)
                .setDeliveryType(DeliveryType.pickup),
          ),
        if (info.pickupEnabled && info.deliveryEnabled)
          const SizedBox(height: 8),
        if (info.deliveryEnabled)
          _DeliveryOption(
            label: 'Delivery',
            sublabel: info.deliveryCost > 0
                ? formatSolesPrice(info.deliveryCost)
                : 'Gratis',
            isSelected: checkout.deliveryType == DeliveryType.delivery,
            onTap: () => ref
                .read(checkoutProvider.notifier)
                .setDeliveryType(DeliveryType.delivery),
          ),
      ],
    );
  }

  // ── Step 2: Delivery information ─────────────────────────────────────────

  Widget _buildStep2(CheckoutState checkout) {
    final isDelivery = checkout.deliveryType == DeliveryType.delivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: 'Información de entrega', onBack: _handleBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isDelivery ? 'Delivery' : 'Recojo en tienda',
                    style: AppTextStyles.h5.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    label: 'Nombre completo:',
                    controller: _fullNameCtrl,
                    hint: 'Tu nombre completo',
                    maxLength: 100,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Campo requerido';
                      if (s.length > 100) return 'Máximo 100 caracteres';
                      return null;
                    },
                  ),
                  if (isDelivery) ...[
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Referencia:',
                      controller: _referenceCtrl,
                      hint: 'Dirección o referencia de entrega',
                      maxLength: 250,
                      inputFormatters: [LengthLimitingTextInputFormatter(250)],
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Campo requerido';
                        if (s.length > 250) return 'Máximo 250 caracteres';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Celular:',
                    controller: _phoneCtrl,
                    hint: '9XXXXXXXX',
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Campo requerido';
                      if (s.length != 9) return 'Debe tener 9 dígitos';
                      if (!s.startsWith('9')) return 'Debe empezar con 9';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Notas (opcional):',
                    controller: _notesCtrl,
                    hint: 'Alguna indicación extra...',
                    required: false,
                  ),
                  const SizedBox(height: 28),
                  if (isDelivery)
                    Text(
                      'El monto de delivery será agregado al precio total.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
        _BottomBar(
          label: 'Método de pago',
          total: checkout.total,
          enabled: _isStep2FormValid(checkout),
          onTap: () {
            if (!_isStep2FormValid(checkout)) return;
            if (_formKey.currentState?.validate() ?? false) {
              ref
                  .read(checkoutProvider.notifier)
                  .updateFormField(
                    fullName: _fullNameCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    reference: _referenceCtrl.text.trim(),
                    notes: _notesCtrl.text.trim(),
                  );
              _goTo(2);
            }
          },
        ),
      ],
    );
  }

  // ── Step 3: Payment method ─────────────────────────────────────────────────

  Widget _buildStep3(CheckoutState checkout) {
    final s = checkout.input.storeInfo;
    final showYape = s.prepaid;
    final showCash = s.cashOnDelivery;
    final hasAnyPayment = showYape || showCash;
    final isYape = checkout.paymentMethod == PaymentMethod.yapePlin;
    final isCash = checkout.paymentMethod == PaymentMethod.cash;
    final qrUrl = s.paymentQr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: 'Método de pago', onBack: _handleBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total destacado
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total ',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: formatSolesPrice(checkout.total),
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Methods according to `store.payments` (prepaid = Yape/Plin, cashOnDelivery = cash)
                if (!hasAnyPayment)
                  Text(
                    'Esta tienda no tiene métodos de pago habilitados. '
                    'Intenta más tarde o contacta al local.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFFC62828),
                    ),
                  )
                else
                  Row(
                    children: [
                      if (showYape) ...[
                        Expanded(
                          child: _PaymentTab(
                            label: 'Yape/Plin',
                            isSelected: isYape,
                            onTap: () => ref
                                .read(checkoutProvider.notifier)
                                .setPaymentMethod(PaymentMethod.yapePlin),
                          ),
                        ),
                      ],
                      if (showYape && showCash) const SizedBox(width: 10),
                      if (showCash) ...[
                        Expanded(
                          child: _PaymentTab(
                            label: 'Efectivo',
                            isSelected: isCash,
                            onTap: () => ref
                                .read(checkoutProvider.notifier)
                                .setPaymentMethod(PaymentMethod.cash),
                          ),
                        ),
                      ],
                    ],
                  ),
                if (hasAnyPayment) const SizedBox(height: 20),

                if (hasAnyPayment) ...[
                  if (isYape) ...[
                    _buildYapePlinContent(checkout, qrUrl),
                  ] else ...[
                    _buildCashContent(checkout),
                  ],
                ],
              ],
            ),
          ),
        ),
        _BottomBar(
          label: checkout.isSubmittingOrder
              ? 'Confirmando...'
              : 'Confirmar pedido',
          total: checkout.total,
          enabled:
              hasAnyPayment &&
              !checkout.isSubmittingOrder &&
              (!isYape ||
                  ((checkout.voucherUrl?.isNotEmpty ?? false) &&
                      !checkout.isUploadingVoucher)),
          isLoading: checkout.isSubmittingOrder,
          onTap: _confirmOrder,
        ),
      ],
    );
  }

  Widget _buildYapePlinContent(CheckoutState checkout, String qrUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '1. Escanea/captura el QR ubicado abajo\n'
          '2. Realiza el pago del monto en ',
          style: AppTextStyles.bodySmall,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '   total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          '3. Sube la captura del comprobante',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),

        // QR
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.textDark.withValues(alpha: 0.12),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: qrUrl.isNotEmpty
                  ? Image.network(
                      qrUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _QrPlaceholder(),
                    )
                  : _QrPlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Upload voucher
        Row(
          children: [
            Text(
              'Sube tu comprobante',
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: checkout.isUploadingVoucher ? null : _pickVoucher,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: checkout.isUploadingVoucher
                    ? const Padding(
                        padding: EdgeInsets.all(9),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.textDark,
                        ),
                      )
                    : const Icon(Icons.add_rounded, size: 22),
              ),
            ),
          ],
        ),
        if ((checkout.voucherUrl?.isNotEmpty ?? false) ||
            checkout.voucherBytes != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (checkout.voucherUrl?.isNotEmpty ?? false)
                ? Image.network(
                    checkout.voucherUrl!,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 160,
                      alignment: Alignment.center,
                      color: AppColors.accentLight,
                      child: Text(
                        'No se pudo cargar la imagen',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  )
                : Image.memory(
                    checkout.voucherBytes!,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            (checkout.voucherUrl?.isNotEmpty ?? false)
                ? 'Comprobante subido'
                : 'Comprobante seleccionado',
            style: AppTextStyles.small.copyWith(
              color: const Color(0xFF2D9D5C),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCashContent(CheckoutState checkout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '1. Paga el monto exacto ubicado en ',
                style: AppTextStyles.bodySmall,
              ),
              TextSpan(
                text: 'total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickVoucher() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final notifier = ref.read(checkoutProvider.notifier);
    final bytes = await picked.readAsBytes();
    notifier.setVoucherLocalBytes(bytes);
    notifier.setVoucherUploading(true);

    try {
      final res = await ServiceLocator.uploadService.uploadPaymentOrderImage(
        picked,
      );
      final url = (res['url'] as String?)?.trim() ?? '';
      if (url.isEmpty) {
        notifier.setVoucherUploading(false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la URL del servidor'),
          ),
        );
        return;
      }
      notifier.setVoucherUploadedUrl(url);
    } on ApiException catch (e) {
      notifier.setVoucherUploading(false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } catch (_) {
      notifier.setVoucherUploading(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir el comprobante')),
      );
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatExtras(MenuCartEntry entry) {
  final parts = <String>[];
  if (entry.appetizer != null) parts.add(entry.appetizer!.name);
  if (entry.beverage != null) parts.add(entry.beverage!.name);
  if (entry.dessert != null) parts.add(entry.dessert!.name);
  return parts.join(' · ');
}

// ── Reusable private widgets ──────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textDark,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: AppColors.textGray.withValues(alpha: 0.25),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.textGray.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textGray,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.textGray,
            iconSize: 20,
            style: IconButton.styleFrom(
              minimumSize: const Size(36, 36),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.textDark : Colors.transparent,
              border: Border.all(
                color: AppColors.textDark,
                width: isSelected ? 0 : 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sublabel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              sublabel,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    required this.isTotal,
  });

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: isTotal ? 1 : 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            formatSolesPrice(amount),
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.required = true,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool required;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          validator: validator,
          style: AppTextStyles.bodySmall,
          decoration: InputDecoration(
            counterText: maxLength != null ? '' : null,
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGray.withValues(alpha: 0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.textDark.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.textDark.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.textDark,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentTab extends StatelessWidget {
  const _PaymentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _kGreen = Color(0xFF2D9D5C);
  static const _kGreenBg = Color(0xFFDCF5E3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kGreenBg : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? _kGreen
                : AppColors.textDark.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? _kGreen : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.label,
    required this.total,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final double total;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.textGray.withValues(alpha: 0.2)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: enabled ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textDark,
                  disabledBackgroundColor: AppColors.textDark.withValues(
                    alpha: 0.35,
                  ),
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total', style: AppTextStyles.small),
              Text(
                formatSolesPrice(total),
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      color: AppColors.accentLight,
      child: Icon(
        Icons.qr_code_2_rounded,
        size: 80,
        color: AppColors.textDark.withValues(alpha: 0.3),
      ),
    );
  }
}
