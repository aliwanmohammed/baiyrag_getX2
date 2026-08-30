import 'package:flutter/material.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';

class ProductCardContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ProductCardContainer({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.product,
          ),
          child: child,
        ),
      ),
    );
  }
}
