import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../core/design_system/components/app_icon.dart';
import '../theme/app_radius.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;

  final double? width;

  final double? height;

  final BoxFit fit;

  final double radius;

  final Widget? placeholder;

  final Widget? errorWidget;

  final Color? backgroundColor;

  /// Optional decode-size cap passed to [CachedNetworkImage].
  /// Setting this limits how large the image is decoded in memory,
  /// which is useful when the display slot is much smaller than the source.
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = AppRadius.md,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  String get _url {
    if (imageUrl.isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    return 'https://backend-albarqy.onrender.com/storage/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    if (_url.isEmpty) {
      return _error();
    }

    final image = CachedNetworkImage(
      imageUrl: _url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) =>
          placeholder ??
          Container(
            color: backgroundColor ?? AppColors.background,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      errorWidget: (_, __, ___) => errorWidget ?? _error(),
    );

    // Only add ClipRRect when a non-zero radius is requested.
    if (radius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }
    return image;
  }

  Widget _error() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FB),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const AppIcon(
            Icons.shopping_bag_rounded,
            size: AppIconSize.large,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
