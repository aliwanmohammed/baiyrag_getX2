import 'package:flutter/widgets.dart';

/// AppBreakpoints: Width-based layout logic
class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compact;
  }

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= medium;
  }

  /// Returns true if orientation is landscape (Note: width-based layout is preferred)
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }
}

/// AppLayout: Structural constraints for pages
class AppLayout {
  AppLayout._();

  /// Center content and constrain max width on large screens
  static const double maxPageWidth = 1200.0;

  /// Get adaptive horizontal padding based on screen size
  static EdgeInsetsGeometry getHorizontalPadding(BuildContext context) {
    if (AppBreakpoints.isExpanded(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else if (AppBreakpoints.isMedium(context)) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    }
    return const EdgeInsets.symmetric(horizontal: 16.0); // Compact
  }
}
