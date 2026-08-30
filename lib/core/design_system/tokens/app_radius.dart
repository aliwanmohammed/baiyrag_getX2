import 'package:flutter/material.dart';

/// AppRadius: Semantic and primitive border radius scales
class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double pill = 100.0;

  //══════════════════════════════════════
  // Component Radii Mapping
  //══════════════════════════════════════
  static const double button = md;
  static const double input = md;
  static const double card = lg;
  static const double sheet = xl;
  static const double dialog = xl;
  static const double chip = pill;
  static const double image = lg;

  //══════════════════════════════════════
  // Helpers
  //══════════════════════════════════════
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
