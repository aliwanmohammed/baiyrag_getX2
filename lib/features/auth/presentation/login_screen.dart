import '../../../app/localization/lang.dart';
import 'package:bhm_supermarket/core/widgets/app_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';

import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_shadows.dart';

import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.redirectTo,
  });

  final String? redirectTo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // منع الضغط المتكرر أثناء الطلب.
    if (_loading) {
      return;
    }

    final email = _emailController.text.trim();

    // مهم:
    // لا نستخدم trim() مع كلمة المرور.
    // كلمة المرور يجب إرسالها كما كتبها المستخدم بالضبط.
    final password = _passwordController.text;

    // ─────────────────────────────────────────────────────────────
    // التحقق من البريد الإلكتروني
    // ─────────────────────────────────────────────────────────────

    final emailError = Validators.email(email);

    if (emailError != null) {
      AppMessage.error(
        context,
        emailError,
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // التحقق من كلمة المرور
    // ─────────────────────────────────────────────────────────────

    if (password.isEmpty) {
      AppMessage.error(
        context,
        lang.t('password_required'),
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // بدء تسجيل الدخول
    // ─────────────────────────────────────────────────────────────

    setState(() {
      _loading = true;
    });

    final auth = Get.find<AuthController>();

    final error = await auth.login(
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // فشل تسجيل الدخول
    // ─────────────────────────────────────────────────────────────

    if (error != null) {
      setState(() {
        _loading = false;
      });

      AppMessage.error(
        context,
        error,
      );

      return;
    }

    // ─────────────────────────────────────────────────────────────
    // نجاح تسجيل الدخول
    // ─────────────────────────────────────────────────────────────

    final role = auth.user?.role;

    // إذا كان Customer:
    // ندمج سلة Guest المحلية مع سلة الحساب.
    if (role == UserRole.customer) {
      await Get.find<CartController>().mergeGuestCart();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    // ─────────────────────────────────────────────────────────────
    // التوجيه حسب Role
    // ─────────────────────────────────────────────────────────────

    switch (role) {
      case UserRole.admin:
        context.go(AppRoutes.adminReports);
        return;

      case UserRole.delivery:
        context.go(AppRoutes.deliveryHome);
        return;

      case UserRole.customer:
      default:
        final target = widget.redirectTo ?? auth.consumePendingRedirect();

        context.go(target);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 380, // INTENTIONAL COMPONENT DIMENSION
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
                    SizedBox(height: 28), // INTENTIONAL COMPONENT DIMENSION

                    // ─────────────────────────────────────────────────
                    // Logo
                    // ─────────────────────────────────────────────────

                    Container(
                      width: 82, // INTENTIONAL COMPONENT DIMENSION
                      height: 82, // INTENTIONAL COMPONENT DIMENSION
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
                        color: Colors.white.withValues(
                          alpha: 0.92,
                        ),
                        fontSize: 13.5,
                      ),
                    ),

                    SizedBox(height: 28),

                    // ─────────────────────────────────────────────────
                    // Login Card
                    // ─────────────────────────────────────────────────

                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              AppSpacing.md), // Added for responsive safe area
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: AppRadius.xlRadius,
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            lang.t('login'),
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: AppSpacing.xs),

                          Text(
                            lang.t('welcome_login'),
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),

                          SizedBox(height: AppSpacing.xl),

                          // ───────────────────────────────────────────
                          // Email
                          // ───────────────────────────────────────────

                          // INTENTIONAL EXCEPTION: Standard TextField used instead of AppTextField
                          // to support autofillHints and textDirection which AppTextField currently lacks.
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            enabled: !_loading,
                            autofillHints: [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            style: AppTypography.bodyLarge,
                            decoration: InputDecoration(
                              labelText: lang.t('email'),
                              prefixIcon: AppIcon(
                                Icons.email_outlined,
                              ),
                            ),
                          ),

                          SizedBox(height: AppSpacing.md),

                          // ───────────────────────────────────────────
                          // Password
                          // ───────────────────────────────────────────

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_loading,
                            textDirection: TextDirection.ltr,
                            autofillHints: [
                              AutofillHints.password,
                            ],
                            style: AppTypography.bodyLarge,
                            decoration: InputDecoration(
                              labelText: lang.t('password'),
                              prefixIcon: AppIcon(
                                Icons.lock_outline,
                              ),
                              suffixIcon: IconButton(
                                constraints: BoxConstraints(
                                    minWidth: 48,
                                    minHeight:
                                        48), // ACCESSIBILITY TOUCH TARGET
                                tooltip: _obscurePassword
                                    ? lang.t('show_password')
                                    : lang.t('hide_password'),
                                onPressed: _loading
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                icon: AppIcon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppSpacing.xl),

                          // ───────────────────────────────────────────
                          // Submit
                          // ───────────────────────────────────────────

                          SizedBox(
                            height: 52, // INTENTIONAL COMPONENT DIMENSION
                            child: AppButton(
                              text: lang.t('login'),
                              onPressed: _submit,
                              state: _loading
                                  ? AppButtonState.loading
                                  : AppButtonState.defaultState,
                            ),
                          ),

                          SizedBox(height: AppSpacing.md),

                          // ───────────────────────────────────────────
                          // Register
                          // ───────────────────────────────────────────

                          Center(
                            child: GestureDetector(
                              onTap: _loading
                                  ? null
                                  : () {
                                      context.push(
                                        AppRoutes.register,
                                      );
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing
                                        .sm), // ACCESSIBILITY TOUCH TARGET
                                child: RichText(
                                  text: TextSpan(
                                    text: lang.t('no_account'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: lang.t('register'),
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

                    SizedBox(height: AppSpacing.xl),
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
