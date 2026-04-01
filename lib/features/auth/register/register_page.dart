import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:komi_fe/core/constants/route_names.dart';
import 'package:komi_fe/core/widgets/komi_brand_panel.dart';
import 'package:komi_fe/core/network/service_locator.dart';
import 'package:komi_fe/core/widgets/responsive_layout.dart';
import 'package:komi_fe/features/auth/models/auth_response.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';
import 'package:komi_fe/features/auth/register/register_controller.dart';
import 'package:komi_fe/features/auth/register/register_state.dart';
import 'package:komi_fe/features/auth/register/widgets/register_form.dart';
import 'package:komi_fe/providers/auth_session_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitEnabled = false;
  UserType _userType = UserType.buyer;

  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(ServiceLocator.registerService);
    _nameController.addListener(_updateSubmitEnabled);
    _phoneController.addListener(_updateSubmitEnabled);
    _emailController.addListener(_updateSubmitEnabled);
    _passwordController.addListener(_updateSubmitEnabled);
    _controller.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateSubmitEnabled);
    _phoneController.removeListener(_updateSubmitEnabled);
    _emailController.removeListener(_updateSubmitEnabled);
    _passwordController.removeListener(_updateSubmitEnabled);
    _controller.state.removeListener(_onStateChanged);
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateSubmitEnabled() {
    final enabled = _controller.validate(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (enabled != _isSubmitEnabled) {
      setState(() => _isSubmitEnabled = enabled);
    }
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});
    final state = _controller.state.value;
    if (state is RegisterSuccess) {
      _persistSessionAndNavigate(state.response);
    } else if (state is RegisterError) {
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
    context.go(_registerDestination(response));
  }

  static String _registerDestination(AuthResponse response) {
    if (response.type == UserType.buyer) {
      return RouteNames.home;
    }
    return RouteNames.creation;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _controller.submit(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      userType: _userType,
      email: _emailController.text,
    );
  }

  void _goToLogin() {
    context.go(RouteNames.login);
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
    final isLoading = _controller.state.value is RegisterLoading;

    return RegisterForm(
      formKey: _formKey,
      nameController: _nameController,
      phoneController: _phoneController,
      emailController: _emailController,
      passwordController: _passwordController,
      obscurePassword: _obscurePassword,
      onToggleObscure: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      userType: _userType,
      onUserTypeChanged: (v) => setState(() => _userType = v),
      isLoading: isLoading,
      isSubmitEnabled: _isSubmitEnabled,
      onSubmit: _submit,
      onGoToLogin: _goToLogin,
      onGoToHome: _goToHome,
    );
  }
}
