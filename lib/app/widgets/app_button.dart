import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart' as ds;

/// Backward-compatible facade for the Design System AppButton.
///
/// New code should import:
/// `core/design_system/components/app_button.dart`.
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

  ds.AppButtonVariant get _variant {
    switch (style) {
      case AppButtonStyle.primary:
        return ds.AppButtonVariant.primary;
      case AppButtonStyle.secondary:
        return ds.AppButtonVariant.secondary;
      case AppButtonStyle.outlined:
        return ds.AppButtonVariant.outlined;
      case AppButtonStyle.ghost:
        return ds.AppButtonVariant.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = isLoading
        ? ds.AppButtonState.loading
        : (!enabled || onPressed == null)
            ? ds.AppButtonState.disabled
            : ds.AppButtonState.defaultState;

    return SizedBox(
      width: width,
      height: height,
      child: ds.AppButton(
        text: text,
        onPressed: onPressed,
        variant: _variant,
        state: state,
        icon: icon == null ? null : Icon(icon, size: 18),
        size: ds.AppButtonSize.medium,
      ),
    );
  }
}
