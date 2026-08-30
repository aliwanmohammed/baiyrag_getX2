import 'package:bhm_supermarket/app/theme/app_colors.dart';
import 'package:bhm_supermarket/app/theme/app_typography.dart';
import 'package:bhm_supermarket/app/widgets/app_back_button.dart';
import 'package:flutter/material.dart';

class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// نص صغير أسفل العنوان (اختياري)
  final String? subtitle;

  /// أزرار اليمين
  final List<Widget>? actions;

  /// إظهار زر الرجوع
  final bool showBack;

  /// مسار احتياطي إذا لم يوجد pop
  final String? fallbackRoute;

  /// لون الخلفية
  final Color? backgroundColor;

  /// لون العنوان
  final Color? titleColor;

  /// إظهار الخط السفلي
  final bool showBottomBorder;

  final VoidCallback? onBack;

  final PreferredSizeWidget? bottom;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.fallbackRoute,
    this.backgroundColor,
    this.titleColor,
    this.showBottomBorder = true,
    this.onBack,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surface;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      leading: showBack
          ? AppBackButton(fallbackRoute: fallbackRoute, onPressed: onBack)
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: titleColor ?? AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypography.caption,
            ),
        ],
      ),
      actions: actions,
      bottom: bottom ??
          (showBottomBorder
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Divider(
                    height: 1,
                    color: Colors.black.withValues(alpha: .05),
                  ),
                )
              : null),
    );
  }

  @override
  Size get preferredSize {
    final toolbarHeight = subtitle == null ? kToolbarHeight + 1 : 72;
    final bottomHeight = bottom?.preferredSize.height ?? 0;

    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}
