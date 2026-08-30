import 'package:flutter/material.dart';

enum AppTextFieldState { defaultState, focused, error, disabled, readOnly }

/// A unified text field component for the Design System.
class AppTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign textAlign;
  final AppTextFieldState state;

  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    this.state = AppTextFieldState.defaultState,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = state != AppTextFieldState.disabled;
    final bool isReadOnly = state == AppTextFieldState.readOnly;
    // Error state and Focus states are primarily handled by the Theme and focus nodes, 
    // but the `state` enum allows for forced styling if necessary.

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textAlign: textAlign,
      enabled: isEnabled,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
        // The decoration theme relies on `AppTheme.lightTheme.inputDecorationTheme`
        // which has been mapped directly to semantic tokens.
      ),
    );
  }
}
