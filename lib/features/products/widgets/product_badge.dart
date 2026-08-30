import 'package:flutter/material.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';

class ProductBadge extends StatelessWidget {
  final String title;
  final Color color;

  const ProductBadge({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(title, style: AppTypography.badge.copyWith(fontSize: 9)),
    );
  }
}
