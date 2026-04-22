import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/widgets/komi_brand_panel.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/widgets/responsive_layout.dart';
import 'package:komi_fe/features/auth/login/login_controller.dart';
import 'package:komi_fe/features/auth/login/login_state.dart';
import 'package:komi_fe/features/auth/login/widgets/login_form.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitEnabled = false;

  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(ServiceLocator.loginService);
    _phoneController.addListener(_updateSubmitEnabled);
    _passwordController.addListener(_updateSubmitEnabled);
    _controller.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateSubmitEnabled);
    _passwordController.removeListener(_updateSubmitEnabled);
    _controller.state.removeListener(_onStateChanged);
    _controller.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateSubmitEnabled() {
    final enabled = _controller.validate(
      _phoneController.text,
      _passwordController.text,
    );
    if (enabled != _isSubmitEnabled) {
      setState(() => _isSubmitEnabled = enabled);
    }
  }

  void _onStateChanged() {
    final state = _controller.state.value;
    if (!mounted) return;

    setState(() {});

    if (state is LoginSuccess) {
      _persistSessionAndNavigate(state.response);
    } else if (state is LoginError) {
      _controller.reset();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Future<void> _persistSessionAndNavigate(AuthResponse response) async {
    await ref.read(authSessionProvider.notifier).signIn(response);
    if (!mounted) return;
    _controller.reset();
    setState(() {});
    context.go(_loginDestination(response));
  }

  static String _loginDestination(AuthResponse response) {
    if (response.type == UserType.buyer) {
      return RouteNames.home;
    }
    if (response.stores.isEmpty) {
      return RouteNames.creation;
    }
    return '${RouteNames.seller}${RouteNames.overview}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _controller.submit(_phoneController.text, _passwordController.text);
  }

  void _goToRegister() {
    context.go(RouteNames.register);
  }

  void _goToHome() {
    context.go(RouteNames.home);
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildForm(),
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
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final isLoading = _controller.state.value is LoginLoading;

    return LoginForm(
      formKey: _formKey,
      phoneController: _phoneController,
      passwordController: _passwordController,
      obscurePassword: _obscurePassword,
      onToggleObscure: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      isLoading: isLoading,
      isSubmitEnabled: _isSubmitEnabled,
      onSubmit: _submit,
      onGoToRegister: _goToRegister,
      onGoToHome: _goToHome,
    );
  }
}
