import 'package:flutter/material.dart';

import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/widgets/logo.dart';
import 'package:komi_fe/features/auth/login/widgets/password_input.dart';
import 'package:komi_fe/features/auth/login/widgets/phone_input.dart';
import 'package:komi_fe/features/auth/models/user_type.dart';
import 'package:komi_fe/features/auth/register/widgets/email_input.dart';
import 'package:komi_fe/features/auth/register/widgets/name_input.dart';
import 'package:komi_fe/features/auth/register/widgets/user_type_selector.dart';

import 'package:komi_fe/core/theme/app_text_styles.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.userType,
    required this.onUserTypeChanged,
    required this.isLoading,
    required this.isSubmitEnabled,
    required this.onSubmit,
    required this.onGoToLogin,
    required this.onGoToHome,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final UserType userType;
  final ValueChanged<UserType> onUserTypeChanged;
  final bool isLoading;
  final bool isSubmitEnabled;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
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
                'Crear cuenta',
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
              SizedBox(height: 16),
              NameInput(controller: nameController),
              SizedBox(height: 16),
              PhoneInput(controller: phoneController),
              SizedBox(height: 16),
              EmailInput(controller: emailController),
              SizedBox(height: 16),
              PasswordInput(
                controller: passwordController,
                obscureText: obscurePassword,
                onToggleObscure: onToggleObscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.contains(' ')) {
                    return 'La contraseña no puede contener espacios';
                  }
                  if (value.length < 9) {
                    return 'La contraseña debe tener al menos 9 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              UserTypeSelector(value: userType, onChanged: onUserTypeChanged),
              SizedBox(height: 16),
              Text(
                'Luego podrás cambiar todo esto cuando quieras',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Image.asset(
                'assets/images/ollin_señalando_izquierda.webp',
                width: 100,
                height: 100,
              ),
              SizedBox(height: 16),
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
                      : Text('Crear cuenta'),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Ya tienes una cuenta?'),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: AppTextStyles.caption,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: onGoToLogin,
                child: Text('Iniciar sesión'),
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
