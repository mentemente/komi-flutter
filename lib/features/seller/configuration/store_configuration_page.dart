import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/formatting/currency_format.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/core/widgets/profile_menu_button.dart';
import 'package:komi_fe/features/seller/configuration/configuration_controller.dart';
import 'package:komi_fe/features/seller/configuration/configuration_state.dart';
import 'package:komi_fe/features/seller/configuration/seller_store_model.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class _Ui {
  static const radiusL = 16.0;
  static const radiusM = 12.0;
  static const radiusXl = 20.0;
  static const cardShadow = <BoxShadow>[
    BoxShadow(color: Color(0x1A2C2C2C), blurRadius: 16, offset: Offset(0, 6)),
  ];
  static const groupShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 20, offset: Offset(0, 4)),
  ];
}

class StoreConfigurationPage extends ConsumerStatefulWidget {
  const StoreConfigurationPage({super.key});

  @override
  ConsumerState<StoreConfigurationPage> createState() =>
      _StoreConfigurationPageState();
}

class _StoreConfigurationPageState
    extends ConsumerState<StoreConfigurationPage> {
  late final StoreConfigurationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StoreConfigurationController(ServiceLocator.storeService);
    _controller.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authSessionProvider);
      final id = session?.stores.isNotEmpty == true
          ? session!.stores.first.id
          : '';
      _controller.load(id);
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.state.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onEdit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Ui.radiusM),
        ),
        content: const Text('Edición de tienda disponible pronto.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _controller.state.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ConfigPageHeader(),
            Expanded(child: _buildBody(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ConfigurationState s) {
    if (s is ConfigurationLoading) {
      return const _LoadingView();
    }
    if (s is ConfigurationError) {
      return _ErrorView(
        message: s.message,
        onRetry: () {
          final session = ref.read(authSessionProvider);
          final id = session?.stores.isNotEmpty == true
              ? session!.stores.first.id
              : '';
          _controller.load(id);
        },
      );
    }
    if (s is ConfigurationReady) {
      return _StoreDetailContent(store: s.store, onEdit: _onEdit);
    }
    return const SizedBox.shrink();
  }
}

class _ConfigPageHeader extends ConsumerWidget {
  const _ConfigPageHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ProfileMenuButton.size,
            child: Material(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('${RouteNames.seller}${RouteNames.overview}');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Volver',
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Configuración de tienda',
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const ProfileMenuButton(),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando datos de la tienda…',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_Ui.radiusL),
            boxShadow: _Ui.cardShadow,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.store_mall_directory_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No se pudo cargar',
                style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_Ui.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reintentar',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreDetailContent extends StatelessWidget {
  const _StoreDetailContent({required this.store, required this.onEdit});

  final SellerStore store;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _StoreProfileHeader(
              name: store.name,
              description: store.description,
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(child: _ConfigGroupedPanel(store: store)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverToBoxAdapter(
            child: _PrimaryCtaButton(onPressed: onEdit),
          ),
        ),
      ],
    );
  }
}

class _StoreProfileHeader extends StatelessWidget {
  const _StoreProfileHeader({required this.name, required this.description});

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    final t = name.trim();
    final letter = t.isEmpty ? '?' : t.substring(0, 1).toUpperCase();
    final desc = description.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentLight,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x142C2C2C),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  desc,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfigGroupedPanel extends StatelessWidget {
  const _ConfigGroupedPanel({required this.store});

  final SellerStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_Ui.radiusXl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: _Ui.groupShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConfigSectionLabel(
            text: 'Entrega y recojo',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 4),
          _ConfigBoolRow('Recojo en tienda', store.pickupEnabled),
          _configDivider,
          _ConfigBoolRow('Delivery', store.deliveryEnabled),
          if (store.deliveryEnabled) ...[
            _configDivider,
            _ConfigValueRow(
              leading: Icons.payments_outlined,
              label: 'Costo de envío',
              value: formatSolesPrice(store.deliveryCost),
            ),
          ],
          _configDivider,
          _ConfigSectionLabel(text: 'Pagos', icon: Icons.credit_card),
          const SizedBox(height: 4),
          _ConfigBoolRow(
            'Contra entrega (efectivo)',
            store.payments.cashOnDelivery,
          ),
          _configDivider,
          _ConfigBoolRow('Pago previo (QR / Yape)', store.payments.prepaid),
          if (store.location != null) ...[
            _configDivider,
            _ConfigSectionLabel(text: 'Ubicación', icon: Icons.place),
            const SizedBox(height: 2),
            _LocationMapTile(location: store.location!),
          ],
          _configDivider,
          _ConfigSectionLabel(text: 'Horarios', icon: Icons.schedule),
          const SizedBox(height: 6),
          _ScheduleTable(schedules: store.schedules),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static const _configDivider = Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Divider(
      height: 1,
      indent: 12,
      endIndent: 12,
      color: Color(0x337C7C7C),
    ),
  );
}

class _ConfigSectionLabel extends StatelessWidget {
  const _ConfigSectionLabel({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppTextStyles.subtitle1
                .copyWith(color: AppColors.primary)
                .fontSize,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textGray,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigBoolRow extends StatelessWidget {
  const _ConfigBoolRow(this.label, this.value);

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 22,
            color: value
                ? AppColors.primary
                : AppColors.textGray.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigValueRow extends StatelessWidget {
  const _ConfigValueRow({
    required this.leading,
    required this.label,
    required this.value,
  });

  final IconData leading;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(leading, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMapTile extends StatelessWidget {
  const _LocationMapTile({required this.location});

  final StoreGeoLocation location;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(location.mapsUrl);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('No se pudo abrir Google Maps.'),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              'Abrir en Google Maps',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Text(
              'Ver o compartir la ubicación de la tienda',
              style: AppTextStyles.small.copyWith(
                color: AppColors.textGray,
                height: 1.2,
              ),
            ),
            trailing: Icon(
              Icons.open_in_new_rounded,
              size: 20,
              color: AppColors.textGray,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable({required this.schedules});

  final List<StoreSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          for (int i = 0; i < schedules.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _ScheduleRowSlim(schedule: schedules[i]),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRowSlim extends StatelessWidget {
  const _ScheduleRowSlim({required this.schedule});

  final StoreSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final name = scheduleDayLabelEs(schedule.day);
    if (schedule.isClosed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(
                name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Cerrado',
                textAlign: TextAlign.end,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final open = schedule.open ?? '—';
    final close = schedule.close ?? '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$open ‑ $close',
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: Text(
          'Editar tienda',
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
