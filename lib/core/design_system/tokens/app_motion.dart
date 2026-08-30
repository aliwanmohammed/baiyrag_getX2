import 'package:flutter/material.dart';

/// AppMotion: Standardized animation durations and curves based on Material 3 conventions.
class AppMotion {
  AppMotion._();

  //══════════════════════════════════════
  // Durations
  //══════════════════════════════════════
  
  /// Fast (e.g., hover states, simple toggles, micro-interactions)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Normal (e.g., dialog expansions, sheet presentations, moderate transitions)
  static const Duration normal = Duration(milliseconds: 250);
  
  /// Slow (e.g., full page transitions, complex choreographed animations)
  static const Duration slow = Duration(milliseconds: 350);

  //══════════════════════════════════════
  // Curves
  //══════════════════════════════════════
  
  /// Standard curve (Starts quickly, eases into resting)
  static const Curve standard = Curves.easeInOut;
  
  /// Emphasized curve (Dramatic entrance, useful for major modal elements)
  static const Curve emphasized = Curves.fastOutSlowIn;
  
  /// Decelerate (Entering the screen)
  static const Curve decelerate = Curves.easeOut;
  
  /// Accelerate (Exiting the screen)
  static const Curve accelerate = Curves.easeIn;
}
