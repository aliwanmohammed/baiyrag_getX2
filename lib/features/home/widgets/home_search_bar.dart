import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';

class HomeSearchBar extends StatelessWidget {
  final bool enableHero;

  /// عند readOnly=true يعمل مثل الصفحة الرئيسية
  final bool readOnly;

  /// عند false يصبح TextField حقيقي
  final TextEditingController? controller;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onTap;

  final String hint;

  final bool autofocus;

  const HomeSearchBar({
    super.key,
    this.enableHero = true,
    this.readOnly = true,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hint = "ابحث عن أي منتج...",
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        readOnly: readOnly,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        onTap: readOnly
            ? (onTap ??
                () {
                  context.push(AppRoutes.search);
                })
            : null,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF9E9E9E),
            fontSize: 14,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: AppIcon(
                Icons.search_rounded,
                size: AppIconSize.small,
                color: Color(0xFFD97706),
              ),
            ),
          ),
        ),
      ),
    );

    if (!enableHero) return child;

    return Hero(
      tag: "home_search",
      child: Material(color: Colors.transparent, child: child),
    );
  }
}
