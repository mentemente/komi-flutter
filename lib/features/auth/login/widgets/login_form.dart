import 'package:flutter/material.dart';

import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/widgets/logo.dart';
import 'package:komi_fe/features/auth/login/widgets/password_input.dart';
import 'package:komi_fe/features/auth/login/widgets/phone_input.dart';

import 'package:komi_fe/core/theme/app_text_styles.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isLoading,
    required this.isSubmitEnabled,
    required this.onSubmit,
    required this.onGoToRegister,
    required this.onGoToHome,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final bool isSubmitEnabled;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;
  final VoidCallback onGoToHome;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Logo(fontSize: 72),
              Text(
                'Iniciar sesión',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              Divider(),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/ollin.webp', width: 144, height: 144),
              SizedBox(height: 40),
              PhoneInput(controller: phoneController),
              SizedBox(height: 16),
              PasswordInput(
                controller: passwordController,
                obscureText: obscurePassword,
                onToggleObscure: onToggleObscure,
              ),
              SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isLoading || !isSubmitEnabled ? null : onSubmit,
                  child: isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text('Iniciar sesión'),
                ),
              ),
              SizedBox(height: 28),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿No tienes una cuenta?', style: AppTextStyles.subtitle1),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: AppTextStyles.caption,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: onGoToRegister,
                child: Text('Regístrate'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: AppTextStyles.caption,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: onGoToHome,
                child: Text('Continuar como invitado'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
