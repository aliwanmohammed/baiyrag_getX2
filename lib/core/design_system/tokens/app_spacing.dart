import 'package:flutter/widgets.dart';

/// AppSpacing: Semantic and global layout spacing
class AppSpacing {
  AppSpacing._();

  static const double none = 0;
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  
  static const double huge = 40.0;
  static const double giant = 48.0;
  static const double massive = 64.0;

  //══════════════════════════════════════
  // Box Layout Helpers
  //══════════════════════════════════════
  static const SizedBox v2 = SizedBox(height: xxs);
  static const SizedBox v4 = SizedBox(height: xs);
  static const SizedBox v8 = SizedBox(height: sm);
  static const SizedBox v12 = SizedBox(height: md);
  static const SizedBox v16 = SizedBox(height: lg);
  static const SizedBox v20 = SizedBox(height: 20); // Legacy preserved
  static const SizedBox v24 = SizedBox(height: xl);
  static const SizedBox v32 = SizedBox(height: xxl);
  static const SizedBox v40 = SizedBox(height: xxxl);

  static const SizedBox h2 = SizedBox(width: xxs);
  static const SizedBox h4 = SizedBox(width: xs);
  static const SizedBox h8 = SizedBox(width: sm);
  static const SizedBox h12 = SizedBox(width: md);
  static const SizedBox h16 = SizedBox(width: lg);
  static const SizedBox h20 = SizedBox(width: 20); // Legacy preserved
  static const SizedBox h24 = SizedBox(width: xl);
  static const SizedBox h32 = SizedBox(width: xxl);

  //══════════════════════════════════════
  // Adaptive Padding (Semantic)
  //══════════════════════════════════════
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: 16);

  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets cardSmall = EdgeInsets.all(12);
  static const EdgeInsets cardLarge = EdgeInsets.all(20);

  static const EdgeInsets listItem = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}
