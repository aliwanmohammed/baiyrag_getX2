import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color color;

  const AppBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: AppTypography.badge,
        ),
      ),
    );
  }
}
