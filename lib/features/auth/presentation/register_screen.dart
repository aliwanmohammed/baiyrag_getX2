import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/app_text_field.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_message.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final nameError = Validators.required(name, lang.t('full_name'));
    if (nameError != null) {
      _showMessage(nameError);
      return;
    }

    final phoneError = Validators.phone(phone);
    if (phoneError != null) {
      _showMessage(phoneError);
      return;
    }

    final emailError = Validators.email(email);
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }

    if (password.isEmpty) {
      _showMessage(lang.t('password_required'));
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(lang.t('confirm_password_required'));
      return;
    }

    if (password != confirmPassword) {
      _showMessage(lang.t('passwords_mismatch'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final auth = Get.find<AuthController>();

    final error = await auth.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
      });
      _showMessage(error);
      return;
    }

    final role = auth.user?.role;

    if (role == UserRole.customer) {
      await Get.find<CartController>().mergeGuestCart();
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    switch (role) {
      case UserRole.admin:
        context.go(AppRoutes.adminReports);
        return;

      case UserRole.delivery:
        context.go(AppRoutes.deliveryHome);
        return;

      case UserRole.customer:
      default:
        context.go(auth.consumePendingRedirect());
        return;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    AppMessage.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // ─────────────────────────────────────────────────
          // Background Gradient (Identical to Login)
          // ─────────────────────────────────────────────────
          Container(
            height: 380,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),

          SafeArea(
            child: AppConstrainedContent(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Top Navigation Bar with Back Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: AppIcon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: AppIconSize.medium,
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.login);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // ─────────────────────────────────────────────────
                    // Logo (Identical to Login)
                    // ─────────────────────────────────────────────────
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          AppShadows.card.first,
                        ],
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 46,
                        color: colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      lang.t('app_name'),
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      lang.t('smart_shopping_tagline'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13.5,
                      ),
                    ),

                    SizedBox(height: 28),

                    // ─────────────────────────────────────────────────
                    // Register Form Card
                    // ─────────────────────────────────────────────────
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      margin: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: AppRadius.xlRadius,
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            lang.t('create_account_new'),
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            lang.t('register_subtitle'),
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl),

                          // Name
                          AppTextField(
                            hint: lang.t('full_name'),
                            controller: _nameController,
                            prefixIcon: AppIcon(Icons.person_outline),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Phone
                          AppTextField(
                            hint: lang.t('phone'),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: AppIcon(Icons.phone_outlined),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Email
                          AppTextField(
                            hint: lang.t('email'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: AppIcon(Icons.email_outlined),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Password with Visibility Toggle
                          AppTextField(
                            hint: lang.t('password'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: AppIcon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              constraints: BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              tooltip: _obscurePassword
                                  ? lang.t('show_password')
                                  : lang.t('hide_password'),
                              icon: AppIcon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),

                          // Confirm Password with Visibility Toggle
                          AppTextField(
                            hint: lang.t('confirm_password'),
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: AppIcon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              constraints: BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              tooltip: _obscureConfirmPassword
                                  ? lang.t('show_password')
                                  : lang.t('hide_password'),
                              icon: AppIcon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),

                          SizedBox(height: AppSpacing.xxl),

                          // Submit Button
                          SizedBox(
                            height: 52,
                            child: AppButton(
                              text: lang.t('register'),
                              onPressed: _submit,
                              state: _isLoading
                                  ? AppButtonState.loading
                                  : AppButtonState.defaultState,
                            ),
                          ),

                          SizedBox(height: AppSpacing.lg),

                          // Already have an account link
                          Center(
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go(AppRoutes.login);
                                      }
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: lang.t('already_have_account'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: lang.t('login'),
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
