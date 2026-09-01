import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic Typography Tokens
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo';

  //══════════════════════════════════════
  // DISPLAY
  //══════════════════════════════════════

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  //══════════════════════════════════════
  // HEADLINES
  //══════════════════════════════════════

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  //══════════════════════════════════════
  // TITLES
  //══════════════════════════════════════

  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  //══════════════════════════════════════
  // BODY
  //══════════════════════════════════════

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  //══════════════════════════════════════
  // LABELS
  //══════════════════════════════════════

  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  //══════════════════════════════════════
  // DOMAIN TYPOGRAPHY (Backwards Compatibility)
  // These should ideally not be in the core tokens, but kept here for backward compatibility
  //══════════════════════════════════════

  static const productName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const productBrand = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const currentPrice = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const oldPrice = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    decoration: TextDecoration.lineThrough,
  );

  static const badge = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontSize: 10,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const discount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.discount,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
  );
}
