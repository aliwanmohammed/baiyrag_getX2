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

    final nameError = Validators.required(name, 'الاسم الكامل');
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
      _showMessage('كلمة المرور مطلوبة');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage('تأكيد كلمة المرور مطلوب');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('كلمتا المرور غير متطابقتين');
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
            decoration: const BoxDecoration(
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
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Top Navigation Bar with Back Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const AppIcon(
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

                    const SizedBox(height: 12),

                    Text(
                      'البيرق هايبر ماركت',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'تسوق ذكي • توصيل سريع',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─────────────────────────────────────────────────
                    // Register Form Card
                    // ─────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      margin: const EdgeInsets.symmetric(
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
                            'إنشاء حساب جديد',
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'أدخل بياناتك لإنشاء حساب والبدء في التسوق',
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Name
                          AppTextField(
                            hint: 'الاسم الكامل',
                            controller: _nameController,
                            prefixIcon: const AppIcon(Icons.person_outline),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Phone
                          AppTextField(
                            hint: 'رقم الهاتف',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const AppIcon(Icons.phone_outlined),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Email
                          AppTextField(
                            hint: 'البريد الإلكتروني',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const AppIcon(Icons.email_outlined),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password with Visibility Toggle
                          AppTextField(
                            hint: 'كلمة المرور',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: const AppIcon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              tooltip: _obscurePassword
                                  ? 'إظهار كلمة المرور'
                                  : 'إخفاء كلمة المرور',
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
                          const SizedBox(height: AppSpacing.md),

                          // Confirm Password with Visibility Toggle
                          AppTextField(
                            hint: 'تأكيد كلمة المرور',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: const AppIcon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              tooltip: _obscureConfirmPassword
                                  ? 'إظهار كلمة المرور'
                                  : 'إخفاء كلمة المرور',
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

                          const SizedBox(height: AppSpacing.xxl),

                          // Submit Button
                          SizedBox(
                            height: 52,
                            child: AppButton(
                              text: 'إنشاء حساب',
                              onPressed: _submit,
                              state: _isLoading
                                  ? AppButtonState.loading
                                  : AppButtonState.defaultState,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'لديك حساب بالفعل؟  ',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'تسجيل الدخول',
                                        style: AppTypography.bodyMedium.copyWith(
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

                    const SizedBox(height: AppSpacing.xxl),
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
