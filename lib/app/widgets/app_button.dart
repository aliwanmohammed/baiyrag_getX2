import 'package:flutter/material.dart';
import '../../core/widgets/loading_widget.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonStyle { primary, secondary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String text;

  final VoidCallback? onPressed;

  final bool isLoading;

  final bool enabled;

  final IconData? icon;

  final double height;

  final double? width;

  final AppButtonStyle style;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.height = 54,
    this.width,
    this.style = AppButtonStyle.primary,
  });

  bool get _disabled => !enabled || isLoading;

  @override
  Widget build(BuildContext context) {
    final background = _background();

    final foreground = _foreground();

    final border = _border();

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: border,
              boxShadow: style == AppButtonStyle.primary
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? AppLoading(
                      type: AppLoadingType.bars,
                      size: 22,
                      color: foreground,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: foreground),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          text,
                          style: AppTypography.button.copyWith(
                            color: foreground,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Color _background() {
    if (_disabled) {
      return Colors.grey.shade300;
    }

    switch (style) {
      case AppButtonStyle.primary:
        return AppColors.primary;

      case AppButtonStyle.secondary:
        return AppColors.secondary;

      case AppButtonStyle.outlined:
        return Colors.transparent;

      case AppButtonStyle.ghost:
        return AppColors.primary.withValues(alpha: .08);
    }
  }

  Color _foreground() {
    if (_disabled) {
      return Colors.grey.shade600;
    }

    switch (style) {
      case AppButtonStyle.primary:
      case AppButtonStyle.secondary:
        return Colors.white;

      case AppButtonStyle.outlined:
      case AppButtonStyle.ghost:
        return AppColors.primary;
    }
  }

  Border? _border() {
    switch (style) {
      case AppButtonStyle.outlined:
        return Border.all(color: AppColors.primary, width: 1.4);

      default:
        return null;
    }
  }
}
