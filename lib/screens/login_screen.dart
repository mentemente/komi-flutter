import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/assets/app_assets.dart';
import 'package:komi_fe/services/api_exception.dart';
import 'package:komi_fe/services/service_locator.dart';
import 'package:komi_fe/theme/app_colors.dart';
import 'package:komi_fe/theme/app_text_styles.dart';
import 'package:komi_fe/widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isEnabledButtonLogin = false;
  final _authService = ServiceLocator.authService;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final enabled =
        _phoneController.text.length >= 7 &&
        _passwordController.text.length >= 6;
    if (enabled != _isEnabledButtonLogin) {
      setState(() => _isEnabledButtonLogin = enabled);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      // TODO: Guardar token y datos del usuario

      context.go('/');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión. Intenta de nuevo.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  // ── Mobile: columna simple centrada ──
  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  // ── Desktop: dos columnas (branding | formulario) ──
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Panel izquierdo - branding
        Expanded(
          child: Container(
            color: AppColors.primary,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'KOMI',
                      style: AppTextStyles.h1.copyWith(color: AppColors.white),
                    ),
                    Image.network(
                      AppAssets.loginImage,
                      width: 256,
                      height: 256,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Alimento casero más cerca de ti',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.accentLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Panel derecho - formulario
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Formulario reutilizable ──
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'KOMI',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Image.network(AppAssets.loginImage, width: 128, height: 128),
          const SizedBox(height: 8),
          const Text(
            'Inicia sesión con tu número de teléfono',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppColors.textDark, fontSize: 16),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Número de teléfono',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Ingresa tu número de teléfono';
              if (value.length < 7) return 'Número de teléfono inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppColors.textDark, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Ingresa tu contraseña';
              if (value.length < 6)
                return 'La contraseña debe tener al menos 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _isLoading || !_isEnabledButtonLogin ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Iniciar sesión'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No tienes una cuenta?'),
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text('Registrate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
