// This file is a compatibility facade.
// The single source of truth is now `AppTextField` in the design system.

import 'package:flutter/material.dart';
import '../design_system/components/app_text_field.dart';

/// Legacy `CustomTextField` mapped to `AppTextField` to prevent breaking changes.
class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final Widget? prefixIcon;
  final TextAlign textAlign;

  const CustomTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.prefixIcon,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      textAlign: textAlign,
      state: AppTextFieldState.defaultState,
    );
  }
}
