import 'package:flutter/material.dart';

import '../tokens/app_sizes.dart';
import '../patterns/app_rtl.dart';

enum AppIconSize { small, medium, large }

/// AppIcon: Unified Icon Component
/// 
/// Uses standard `IconData` (e.g. from `Icons.*`), ensuring only Material Icons are used
/// for generic UI components.
/// 
/// Automatically handles RTL flipping if `directionSensitive` is true.
class AppIcon extends StatelessWidget {
  final IconData icon;
  final AppIconSize size;
  final Color? color;
  final bool directionSensitive;
  final String? semanticLabel;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppIconSize.medium,
    this.color,
    this.directionSensitive = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve Size
    double iconSize;
    switch (size) {
      case AppIconSize.small:
        iconSize = AppSizes.iconSm;
        break;
      case AppIconSize.medium:
        iconSize = AppSizes.iconMd;
        break;
      case AppIconSize.large:
        iconSize = AppSizes.iconLg;
        break;
    }

    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: color, // Fallback to Theme icon color if null
      semanticLabel: semanticLabel,
    );

    // Apply semantics wrapper if decorative or semantic
    if (semanticLabel == null) {
      iconWidget = ExcludeSemantics(child: iconWidget);
    }

    // Apply RTL Flipping if needed (e.g. for Back, Forward, Chevron)
    if (directionSensitive) {
      iconWidget = AppRTL.flipForRTL(context: context, child: iconWidget);
    }

    return iconWidget;
  }
}
