import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// AppRTL: Utilities for managing Right-To-Left directionality
class AppRTL {
  AppRTL._();

  /// Returns true if the current reading direction is RTL
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  /// Helper for flipping icons (like back arrows) in RTL
  static Widget flipForRTL({
    required BuildContext context,
    required Widget child,
  }) {
    if (isRTL(context)) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: child,
      );
    }
    return child;
  }

  /// Get directional padding (Start/End) safely
  static EdgeInsetsGeometry directionalPadding({
    double start = 0.0,
    double end = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsetsDirectional.only(
      start: start,
      end: end,
      top: top,
      bottom: bottom,
    );
  }
}
