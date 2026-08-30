import 'package:flutter/material.dart';

import '../../../app/widgets/app_cached_image.dart';
import '../../../app/widgets/app_card.dart';
import '../../../app/widgets/app_price.dart';

import '../../../core/models/product_model.dart';

class SearchResultCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const SearchResultCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            AppCachedImage(
              imageUrl: product.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              radius: 12,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),
                  AppPrice(price: product.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
