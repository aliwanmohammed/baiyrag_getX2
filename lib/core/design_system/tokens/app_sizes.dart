

/// AppSizes: Shared dimensions and constraints for components
class AppSizes {
  AppSizes._();

  // Touch Target (Accessibility)
  static const double minimumTouchTarget = 48.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0; // Meets min touch target
  static const double buttonHeightLg = 56.0;

  // Input Heights
  static const double inputHeightMd = 48.0;

  // Layout Constraints
  static const double maxContentWidth = 1200.0;
}
