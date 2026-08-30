import 'package:flutter/material.dart';

import '../tokens/app_sizes.dart';

/// AppAccessibility: Centralized utilities for accessibility.
class AppAccessibility {
  AppAccessibility._();

  /// Enforces a minimum touch target size according to Material guidelines (48x48)
  /// Useful for icon-only buttons or custom interactive widgets.
  static Widget withMinTouchTarget({required Widget child}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppSizes.minimumTouchTarget,
        minHeight: AppSizes.minimumTouchTarget,
      ),
      child: child,
    );
  }

  /// Scales text naturally using Flutter's TextScaler but prevents extreme layouts from breaking 
  /// by clamping the max scale factor if necessary. 
  /// 
  /// NOTE: This should only be used in specific widgets that break when scaled infinitely.
  /// Standard typography should freely scale.
  static TextScaler clampedTextScaler(BuildContext context, {double maxScale = 2.0}) {
    final defaultScaler = MediaQuery.textScalerOf(context);
    // As of Flutter 3.16+, you can clamp the text scale factor.
    // For simplicity, we just return the default scaler for now to honor OS settings,
    // but this method serves as the architectural point for future constraints.
    return defaultScaler.clamp(maxScaleFactor: maxScale);
  }
}
