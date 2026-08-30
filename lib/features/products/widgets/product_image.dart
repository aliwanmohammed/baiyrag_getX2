import 'package:flutter/material.dart';

import '../../../app/widgets/app_cached_image.dart';

class ProductImage extends StatelessWidget {
  final String image;
  final Object heroTag;

  const ProductImage({super.key, required this.image, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: AppCachedImage(
        imageUrl: image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        backgroundColor: Colors.transparent,
        // Cap decode at 2× the display slot (180 px) for HiDPI screens.
        memCacheWidth: 360,
      ),
    );
  }
}
