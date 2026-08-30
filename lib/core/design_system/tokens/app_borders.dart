import 'package:flutter/material.dart';

/// AppBorders: Defines standard border widths and semantic border styles.
class AppBorders {
  AppBorders._();

  //══════════════════════════════════════
  // Primitive Border Widths
  //══════════════════════════════════════
  static const double hairline = 0.5;
  static const double thin = 1.0;
  static const double medium = 2.0;
  static const double thick = 3.0;

  //══════════════════════════════════════
  // Semantic BorderSides
  // (Using BuildContext to ensure Light/Dark theme compatibility)
  //══════════════════════════════════════

  static BorderSide defaultSide(BuildContext context) {
    return BorderSide(
      color: Theme.of(context).colorScheme.outlineVariant,
      width: thin,
    );
  }

  static BorderSide subtleSide(BuildContext context) {
    return BorderSide(
      color: Theme.of(context).dividerColor,
      width: hairline,
    );
  }

  static BorderSide focusedSide(BuildContext context) {
    return BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: medium,
    );
  }

  static BorderSide errorSide(BuildContext context) {
    return BorderSide(
      color: Theme.of(context).colorScheme.error,
      width: thin,
    );
  }

  static BorderSide disabledSide(BuildContext context) {
    return BorderSide(
      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
      width: thin,
    );
  }

  static BorderSide selectedSide(BuildContext context) {
    return BorderSide(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      width: medium,
    );
  }

  //══════════════════════════════════════
  // Semantic Border.all Helpers
  //══════════════════════════════════════

  static Border defaultAll(BuildContext context) => Border.fromBorderSide(defaultSide(context));
  static Border subtleAll(BuildContext context) => Border.fromBorderSide(subtleSide(context));
  static Border focusedAll(BuildContext context) => Border.fromBorderSide(focusedSide(context));
  static Border errorAll(BuildContext context) => Border.fromBorderSide(errorSide(context));
  static Border disabledAll(BuildContext context) => Border.fromBorderSide(disabledSide(context));
  static Border selectedAll(BuildContext context) => Border.fromBorderSide(selectedSide(context));
}
