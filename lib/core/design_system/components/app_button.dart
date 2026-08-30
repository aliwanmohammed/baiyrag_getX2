import 'package:flutter/material.dart';

import '../tokens/app_sizes.dart';

enum AppButtonVariant { primary, secondary, outlined, text }
enum AppButtonSize { small, medium, large }
enum AppButtonState { defaultState, loading, disabled }

/// A unified button component for the Design System.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final AppButtonState state;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.state = AppButtonState.defaultState,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = state == AppButtonState.disabled || onPressed == null;
    final bool isLoading = state == AppButtonState.loading;
    
    // Size Mapping
    double height;
    switch (size) {
      case AppButtonSize.small:
        height = AppSizes.buttonHeightSm;
        break;
      case AppButtonSize.medium:
        height = AppSizes.buttonHeightMd;
        break;
      case AppButtonSize.large:
        height = AppSizes.buttonHeightLg;
        break;
    }

    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;
    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(text),
            ],
          );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        // Relies on ElevatedButtonTheme defined in AppTheme
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          child: content,
        );
        break;
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          child: content,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          child: content,
        );
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: button,
    );
  }
}
