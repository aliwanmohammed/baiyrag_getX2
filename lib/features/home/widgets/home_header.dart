import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeHeader extends StatelessWidget {
  final bool isOverlay;

  const HomeHeader({super.key, this.isOverlay = true});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<AuthController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final textColor = isOverlay ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final hintColor = isOverlay ? Colors.white.withValues(alpha: 0.90) : Theme.of(context).colorScheme.onSurfaceVariant;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مرحبًا',
                      style: AppTypography.labelMedium.copyWith(
                        color: hintColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        shadows: isOverlay
                            ? [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  user?.name.isNotEmpty == true ? user!.name : 'زائر',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: textColor,
                    height: 1.15,
                    shadows: isOverlay
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.50),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            hasBadge: true,
            onTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool hasBadge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const AppIcon(
                Icons.notifications_none_rounded,
                size: AppIconSize.small,
                color: Color(0xFF1E1E1E),
              ),
              if (hasBadge)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
