import 'package:flutter/material.dart';

/// Primitive Colors (Base Palette)
class AppPrimitiveColors {
  AppPrimitiveColors._();

  // Brand Palette
  static const brand = Color(0xffD4A017);
  static const brandDark = Color(0xffB8860B);
  static const brandLight = Color(0xffF8D568);
  static const brandExtraLight = Color(0xffFFF7DF);
  static const brandSoft = Color(0xFFFFF4D6);

  static const secondary = Color(0xffFFB300);
  static const accent = Color(0xffF59E0B);

  // Neutrals (Light Theme)
  static const white = Colors.white;
  static const background = Color(0xffF8F9FB);
  static const background2 = Color(0xffF4F6F8);
  static const surface2 = Color(0xffFCFCFD);
  static const surfaceVariant = Color(0xffF5F5F7);
  
  static const textPrimary = Color(0xff171717);
  static const textSecondary = Color(0xff666666);
  static const textLight = Color(0xff888888);
  static const textHint = Color(0xffA0A4AB);

  static const border = Color(0xffE7E8EC);
  static const borderLight = Color(0xffF1F2F4);
  static const divider = Color(0xffECECEC);
  static const outline = Color(0xffD8DCE2);

  // Neutrals (Dark Theme)
  static const backgroundDark = Color(0xff101317);
  static const surfaceDark = Color(0xff1A1D22);
  static const cardDark = Color(0xff22262C);
  
  static const textPrimaryDark = Color(0xffF9FAFB);
  static const textSecondaryDark = Color(0xff9CA3AF);
  static const textHintDark = Color(0xff6B7280);
  
  static const borderDark = Color(0xff374151);
  static const dividerDark = Color(0xff1F2937);

  // Status Colors
  static const success = Color(0xff16A34A);
  static const successLight = Color(0xffDCFCE7);
  static const successDark = Color(0xff059669);
  
  static const warning = Color(0xffF59E0B);
  static const warningLight = Color(0xffFEF3C7);
  static const warningDark = Color(0xffD97706);
  
  static const error = Color(0xffEF4444);
  static const errorLight = Color(0xffFEE2E2);
  static const errorDark = Color(0xffDC2626);
  
  static const info = Color(0xff2563EB);
  static const infoLight = Color(0xffDBEAFE);
  static const infoDark = Color(0xff1D4ED8);

  // Product Specific (Will be aliased)
  static const favorite = Color(0xffFF4D6D);
  static const rating = Color(0xffF5B301);

  // Effects
  static const overlay = Color(0x55000000);
  static const shimmerBase = Color(0xffECECEC);
  static const shimmerHighlight = Color(0xffF7F7F7);
  static const shimmerBaseDark = Color(0xff2A2E35);
  static const shimmerHighlightDark = Color(0xff3A3E45);
  static const shadow = Color(0x12000000);
  static const transparent = Colors.transparent;
  static const black = Colors.black;
}

/// Semantic Colors (Light Theme Defaults - also heavily used directly, preserved for backward compat)
class AppColors {
  AppColors._();

  // Primary mapping
  static const primary = AppPrimitiveColors.brand;
  static const primaryDark = AppPrimitiveColors.brandDark;
  static const primaryLight = AppPrimitiveColors.brandLight;
  static const primaryExtraLight = AppPrimitiveColors.brandExtraLight;
  static const primarySoft = AppPrimitiveColors.brandSoft;
  static const secondary = AppPrimitiveColors.secondary;
  static const accent = AppPrimitiveColors.accent;

  // Background mapping
  static const background = AppPrimitiveColors.background;
  static const background2 = AppPrimitiveColors.background2;
  static const backgroundDark = AppPrimitiveColors.backgroundDark;
  static const imageBackground = AppPrimitiveColors.background;

  // Surface mapping
  static const surface = AppPrimitiveColors.white;
  static const surface2 = AppPrimitiveColors.surface2;
  static const surfaceVariant = AppPrimitiveColors.surfaceVariant;
  static const surfaceDark = AppPrimitiveColors.surfaceDark;
  static const card = AppPrimitiveColors.white;
  static const cardDark = AppPrimitiveColors.cardDark;

  // Text mapping
  static const textPrimary = AppPrimitiveColors.textPrimary;
  static const textSecondary = AppPrimitiveColors.textSecondary;
  static const textLight = AppPrimitiveColors.textLight;
  static const textHint = AppPrimitiveColors.textHint;
  static const textWhite = AppPrimitiveColors.white;
  static const textOnPrimary = AppPrimitiveColors.white;
  static const price = AppPrimitiveColors.textPrimary;
  static const oldPrice = AppPrimitiveColors.textHint;

  // Border mapping
  static const border = AppPrimitiveColors.border;
  static const borderLight = AppPrimitiveColors.borderLight;
  static const divider = AppPrimitiveColors.divider;
  static const outline = AppPrimitiveColors.outline;

  // Status mapping
  static const success = AppPrimitiveColors.success;
  static const successLight = AppPrimitiveColors.successLight;
  static const warning = AppPrimitiveColors.warning;
  static const warningLight = AppPrimitiveColors.warningLight;
  static const error = AppPrimitiveColors.error;
  static const errorLight = AppPrimitiveColors.errorLight;
  static const info = AppPrimitiveColors.info;
  static const infoLight = AppPrimitiveColors.infoLight;

  // Legacy mappings for backwards compatibility (Domain Colors)
  static const badgeSale = AppPrimitiveColors.error;
  static const badgeBest = AppPrimitiveColors.warning;
  static const gradientStart = Color(0xFFFFC107);
  static const gradientEnd = Color(0xFFE2A600);
  static const discount = AppPrimitiveColors.error;
  static const rating = AppPrimitiveColors.rating;
  static const favorite = AppPrimitiveColors.favorite;
  static const newBadge = AppPrimitiveColors.success;
  static const saleBadge = AppPrimitiveColors.error;
  static const outOfStock = AppPrimitiveColors.textHint;

  // Delivery states
  static const preparing = AppPrimitiveColors.warning;
  static const shipping = AppPrimitiveColors.info;
  static const delivered = AppPrimitiveColors.success;
  static const cancelled = AppPrimitiveColors.error;

  // Effects
  static const overlay = AppPrimitiveColors.overlay;
  static const shimmerBase = AppPrimitiveColors.shimmerBase;
  static const shimmerHighlight = AppPrimitiveColors.shimmerHighlight;
  static const shadow = AppPrimitiveColors.shadow;

  // Common
  static const white = AppPrimitiveColors.white;
  static const black = AppPrimitiveColors.black;
  static const transparent = AppPrimitiveColors.transparent;
  static const brand = AppPrimitiveColors.brand;

  // Gradients
  static const mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xffF4C430), Color(0xffC69214)],
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xffFFFFFF), Color(0xffFBFBFB)],
  );

  static const offerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPrimitiveColors.warning, Color(0xffD97706)],
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xff22C55E), AppPrimitiveColors.success],
  );

  static const errorGradient = LinearGradient(
    colors: [Color(0xffF87171), Color(0xffDC2626)],
  );
}

/// Dark Theme Semantic Colors
/// Use these exclusively to map dark theme properties in app_theme.dart
class AppDarkColors {
  AppDarkColors._();

  static const primary = AppPrimitiveColors.brand;
  static const primaryDark = AppPrimitiveColors.brandDark;
  
  static const background = AppPrimitiveColors.backgroundDark;
  static const surface = AppPrimitiveColors.surfaceDark;
  static const card = AppPrimitiveColors.cardDark;

  static const textPrimary = AppPrimitiveColors.textPrimaryDark;
  static const textSecondary = AppPrimitiveColors.textSecondaryDark;
  static const textHint = AppPrimitiveColors.textHintDark;

  static const border = AppPrimitiveColors.borderDark;
  static const divider = AppPrimitiveColors.dividerDark;
  static const outline = AppPrimitiveColors.borderDark;

  static const success = AppPrimitiveColors.successDark;
  static const warning = AppPrimitiveColors.warningDark;
  static const error = AppPrimitiveColors.errorDark;
  static const info = AppPrimitiveColors.infoDark;
  
  static const shimmerBase = AppPrimitiveColors.shimmerBaseDark;
  static const shimmerHighlight = AppPrimitiveColors.shimmerHighlightDark;
}
