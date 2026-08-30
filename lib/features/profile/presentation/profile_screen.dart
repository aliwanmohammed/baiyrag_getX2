import 'package:bhm_supermarket/features/address/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../orders/controllers/orders_controller.dart';

import '../../favorites/controllers/favorites_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ordersController = Get.find<OrdersController>();
      final addressController = Get.find<AddressController>();

      if (ordersController.orders.isEmpty) {
        ordersController.loadOrders();
      }

      if (addressController.addresses.isEmpty) {
        addressController.loadAddresses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<AuthController>(
    builder: (_) => GetBuilder<OrdersController>(
    builder: (_) => GetBuilder<AddressController>(
    builder: (_) => GetBuilder<FavoritesController>(
    builder: (_) => _buildGetX0(context)))));
  }

  Widget _buildGetX0(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final ordersController = Get.find<OrdersController>();
    final addressController = Get.find<AddressController>();
    final favoritesController = Get.find<FavoritesController>();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: AppConstrainedContent(
          child: Column(
            children: [
              // Header gradient
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20, // Content dimension
                  bottom: AppSpacing.xxl,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryDark], // Intentional visual identity exception
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.xxl),
                    bottomRight: Radius.circular(AppRadius.xxl),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80, // Component dimension
                      height: 80, // Component dimension
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: Center(
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name.substring(0, 1)
                              : '👤',
                          style: AppTypography.displaySmall.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      user?.name ?? 'المستخدم',
                      style: AppTypography.titleLarge.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user?.phone ?? user?.email ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge('${ordersController.orders.length}', 'طلب'),
                        const SizedBox(width: AppSpacing.md),
                        _StatBadge(
                          '${addressController.addresses.length}',
                          'عناوين',
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _StatBadge('${favoritesController.ids.length}', 'مفضلة'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    _MenuSection('حسابي', [
                      _MenuItem(
                        Icons.receipt_long_outlined,
                        'طلباتي',
                        AppColors.info, // Semantic colors that match specific info roles
                        () => context.push(AppRoutes.orders),
                      ),
                      _MenuItem(
                        Icons.favorite_border_rounded,
                        'المفضلة',
                        colorScheme.error,
                        () => context.push(AppRoutes.favorites),
                      ),
                      _MenuItem(
                        Icons.location_on_outlined,
                        'عناوين التوصيل',
                        AppColors.success, // Semantic success
                        () => context.push(AppRoutes.addresses),
                      ),
                      _MenuItem(
                        Icons.notifications_outlined,
                        'الإشعارات',
                        AppColors.accent, // Semantic accent
                        () => context.push(AppRoutes.notifications),
                      ),
                      _MenuItem(
                        Icons.settings_outlined,
                        'الإعدادات',
                        colorScheme.onSurfaceVariant,
                        () => context.push(AppRoutes.settings),
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.md),

                    _MenuSection('الدعم والمعلومات', [
                      _MenuItem(
                        Icons.info_outline,
                        'من نحن',
                        colorScheme.primary,
                        () => context.push(AppRoutes.aboutUs),
                      ),
                      _MenuItem(
                        Icons.phone_outlined,
                        'اتصل بنا',
                        AppColors.info,
                        () => context.push(AppRoutes.contactUs),
                      ),
                      _MenuItem(
                        Icons.help_outline_rounded,
                        'الأسئلة الشائعة',
                        AppColors.accent,
                        () => context.push(AppRoutes.faq),
                      ),
                      _MenuItem(
                        Icons.privacy_tip_outlined,
                        'سياسة الخصوصية',
                        colorScheme.onSurfaceVariant,
                        () => context.push(AppRoutes.privacyPolicy),
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.md),

                    // Logout
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xlRadius,
                          ),
                          title: const Text('تسجيل الخروج'),
                          content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await Get.find<AuthController>().logout();

                                if (!ctx.mounted) return;

                                Navigator.pop(ctx);
                                context.go(AppRoutes.login);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                minimumSize: const Size(80, 40),
                              ),
                              child: const Text('خروج'),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.06),
                          borderRadius: AppRadius.lgRadius,
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            AppIcon(Icons.logout_rounded, color: colorScheme.error, size: AppIconSize.medium),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'تسجيل الخروج',
                              style: AppTypography.titleSmall.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'البيرق هايبر ماركت v1.0.0',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  const _StatBadge(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.2),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _MenuItem(this.icon, this.label, this.color, this.onTap);
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection(this.title, this.items);
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // CRITICAL FIX: Replaced `only(right: 4)` with directional start padding
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Material(
          color: colorScheme.surface,
          borderRadius: AppRadius.xlRadius,
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xlRadius,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Column(
                  children: [
                    ListTile(
                      onTap: item.onTap,
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: AppRadius.smRadius, // Slightly rounded for inner items
                        ),
                        child: AppIcon(item.icon, color: item.color, size: AppIconSize.small),
                      ),
                      title: Text(
                        item.label,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: AppIcon(
                        Icons.chevron_left,
                        color: colorScheme.outline,
                        size: AppIconSize.small,
                        directionSensitive: true,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    if (i < items.length - 1)
                      Divider(height: 1, indent: 72, endIndent: AppSpacing.md),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
