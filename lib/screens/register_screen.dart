import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:komi_fe/models/user_type.dart';
import 'package:komi_fe/theme/app_colors.dart';
import 'package:komi_fe/services/service_locator.dart';
import 'package:komi_fe/theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isEnabledButtonRegister = false;
  final _authService = ServiceLocator.authService;
  UserType _userType = UserType.buyer;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_updateButtonState);
    _nameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateButtonState);
    _nameController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final enabled =
        _phoneController.text.length >= 7 &&
        _nameController.text.length >= 3 &&
        _emailController.text.length >= 3 &&
        _passwordController.text.length >= 6;
    if (enabled != _isEnabledButtonRegister) {
      setState(() => _isEnabledButtonRegister = enabled);
    }
  }
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        phone: _phoneController.text,
        password: _passwordController.text,
        name: _nameController.text,
        type: _userType,
        email: _emailController.text,
      );
      if (!mounted) return;
      // TODO: Guardar token y datos del usuario

      context.go('/');
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Crea tu cuenta', style: AppTextStyles.h1),
                const SizedBox(height: 24),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: 420), child: Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email(*)',
                          suffixIcon: Tooltip(
                            message: 'Campo opcional',
                            child: Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Crear cuenta como:', textAlign: TextAlign.left),
                      RadioGroup<UserType>(
                        groupValue: _userType,
                        onChanged: (v) => setState(() => _userType = v!),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<UserType>(
                                value: UserType.buyer,
                                title: const Text('Comprador/a'),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<UserType>(
                                value: UserType.seller,
                                title: const Text('Vendedor/a'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Crear cuenta'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Ya tengo una cuenta', textAlign: TextAlign.left),
                          TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: const Text('Iniciar sesión'),
                          ),
                        ],
                      ),
                    ]),
                  )),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
