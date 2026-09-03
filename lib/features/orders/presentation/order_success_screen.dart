import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/patterns/app_responsive.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderNumber;
  const OrderSuccessScreen({super.key, required this.orderNumber});
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl, _slideCtrl;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _slide = Tween(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _scaleCtrl.forward().then((_) => _slideCtrl.forward());
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE8F8F0),
                Color(0xFFE3F4FB)
              ], // INTENTIONAL VISUAL EXCEPTION
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: AppConstrainedContent(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  children: [
                    Spacer(flex: 2),

                    // Success animation
                    ScaleTransition(
                      scale: _scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colorScheme.primary, AppColors.brand],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Text content
                    SlideTransition(
                      position: _slide,
                      child: Column(
                        children: [
                          Text(
                            lang.t('order_received'),
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border:
                                  Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  lang.t('order_number_widget'),
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            lang.t('order_contact_hint'),
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(flex: 2),

                    // Steps indicator
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Text(
                            lang.t('what_happens_now'),
                            style: AppTypography.titleMedium
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: AppSpacing.md),
                          _Step(
                            '1',
                            lang.t('store_receives_order'),
                            Icons.storefront_outlined,
                            colorScheme,
                          ),
                          _Step(
                            '2',
                            lang.t('preparing_products'),
                            Icons.inventory_2_outlined,
                            colorScheme,
                          ),
                          _Step(
                            '3',
                            lang.t('delivery_to_door'),
                            Icons.delivery_dining_outlined,
                            colorScheme,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    AppButton(
                      onPressed: () => context.go(AppRoutes.orders),
                      icon: AppIcon(Icons.location_on_outlined,
                          size: AppIconSize.medium),
                      text: lang.t('track_order'),
                      size: AppButtonSize.large,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppButton(
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.go(AppRoutes.home),
                      text: lang.t('back_home'),
                      size: AppButtonSize.large,
                    ),
                    SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number, label;
  final IconData icon;
  final ColorScheme colorScheme;
  const _Step(this.number, this.label, this.icon, this.colorScheme);
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            AppIcon(icon, color: colorScheme.primary, size: AppIconSize.small),
            SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.bodyMedium),
          ],
        ),
      );
}
