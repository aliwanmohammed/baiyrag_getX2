// This file is a compatibility facade.
// The single source of truth is now `AppButton` in the design system.

import 'package:flutter/material.dart';
import '../design_system/components/app_button.dart';

/// Legacy `CustomButton` mapped to `AppButton` to prevent breaking changes.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      // Default mappings preserve the legacy visual expectations
      variant: AppButtonVariant.primary,
      size: AppButtonSize.large, // Legacy button was 55 height
    );
  }
}
