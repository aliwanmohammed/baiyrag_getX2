import 'package:flutter/material.dart';

/// AppShadows: Centralized BoxShadow and Elevation utilities
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = <BoxShadow>[];

  //══════════════════════════════════════
  // Primitive Scale
  //══════════════════════════════════════
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 5)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(color: Color(0x26000000), blurRadius: 28, offset: Offset(0, 12)),
  ];

  //══════════════════════════════════════
  // Semantic / Domain Shadows (Backwards Compatibility)
  //══════════════════════════════════════
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x16000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> small = sm;
  static const List<BoxShadow> large = xl;

  static const List<BoxShadow> search = [
    BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> product = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> category = [
    BoxShadow(color: Color(0x10000000), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> banner = [
    BoxShadow(color: Color(0x18000000), blurRadius: 22, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> dialog = xxl;

  //══════════════════════════════════════
  // Dynamic Shadow Helpers
  //══════════════════════════════════════
  
  /// Returns a soft, colored glow often used for primary buttons
  static List<BoxShadow> getGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.25),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
