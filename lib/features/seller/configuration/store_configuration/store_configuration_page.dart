import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/features/seller/configuration/edit_store/edit_store_page.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/store_configuration_controller.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/store_configuration_state.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/widgets/store_configuration_error_view.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/widgets/store_configuration_loading_view.dart';
import 'package:komi_fe/features/seller/configuration/store_configuration/widgets/store_configuration_page_header.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final s = _controller.state.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StoreConfigurationPageHeader(),
            Expanded(child: _buildBody(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StoreConfigurationState s) {
    if (s is StoreConfigurationLoading) {
      return const StoreConfigurationLoadingView();
    }
    if (s is StoreConfigurationError) {
      return StoreConfigurationErrorView(
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
    if (s is StoreConfigurationReady) {
      final session = ref.read(authSessionProvider);
      final id = session?.stores.isNotEmpty == true
          ? session!.stores.first.id
          : '';
      return EditStorePage(
        embedded: true,
        store: s.store,
        onSaved: id.isEmpty ? null : () => _controller.load(id),
      );
    }
    return const SizedBox.shrink();
  }
}
