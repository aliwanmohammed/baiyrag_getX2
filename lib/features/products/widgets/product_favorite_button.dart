import '../../../app/localization/lang.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/design_system/components/app_icon.dart';

class ProductFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const ProductFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? lang.t('remove_from_favorites') : lang.t('add_to_favorites'),
      child: IconButton(
        onPressed: onTap,
        iconSize: 18,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shadowColor: AppShadows.xs.first.color,
          elevation: 2,
        ),
        icon: AppIcon(
          isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
          size: AppIconSize.small,
          color: isFavorite
              ? AppColors.favorite
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
