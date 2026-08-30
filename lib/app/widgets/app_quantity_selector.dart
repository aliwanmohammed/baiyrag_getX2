import 'package:flutter/material.dart';
import '../../core/design_system/components/app_icon.dart';
import '../theme/app_typography.dart';

class AppQuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const AppQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onDecrease, icon: const AppIcon(Icons.remove, size: AppIconSize.small)),
          Text(
            quantity.toString(),
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(onPressed: onIncrease, icon: const AppIcon(Icons.add, size: AppIconSize.small)),
        ],
      ),
    );
  }
}
