import 'package:flutter/material.dart';

import '../../core/design_system/components/app_icon.dart';
import '../router/navigation_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  final bool showBack;

  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        title,
        style: AppTypography.titleLarge,
      ),
      leading: showBack
          ? IconButton(
              onPressed: () {
                NavigationHelper.back(context);
              },
              icon: const AppIcon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: AppIconSize.medium,
                directionSensitive: true,
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
