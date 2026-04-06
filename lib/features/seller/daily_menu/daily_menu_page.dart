import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/widgets/title_profile_header.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_controller.dart';
import 'package:komi_fe/features/seller/daily_menu/widgets/daily_menu_body.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class DailyMenuPage extends ConsumerStatefulWidget {
  const DailyMenuPage({super.key});

  @override
  ConsumerState<DailyMenuPage> createState() => _DailyMenuPageState();
}

class _DailyMenuPageState extends ConsumerState<DailyMenuPage> {
  late final DailyMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DailyMenuController(
      ServiceLocator.dailyMenuService,
      ServiceLocator.foodService,
    );
    _controller.state.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoad());
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _startLoad() {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId =
        (stores != null && stores.isNotEmpty) ? stores.first.id : null;
    _controller.loadFoods(storeId: storeId);
  }

  Future<void> _onRefresh() async {
    final session = ref.read(authSessionProvider);
    final stores = session?.stores;
    final storeId =
        (stores != null && stores.isNotEmpty) ? stores.first.id : null;
    await _controller.loadFoods(storeId: storeId);
  }

  @override
  void dispose() {
    _controller.state.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleProfileHeader(title: 'Carta del día'),
                const SizedBox(height: 24),
                DailyMenuBody(
                  state: _controller.state.value,
                  onRetry: _startLoad,
                  onActiveChanged: _controller.setItemActive,
                  onSave: _controller.saveItem,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
