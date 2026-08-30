// import 'package:flutter/material.dart';

// import '../../../app/theme/app_spacing.dart';
// import '../../../core/models/product_model.dart';
// import 'product_card.dart';

// class ProductsList extends StatelessWidget {
//   final List<ProductModel> products;

//   const ProductsList({
//     super.key,
//     required this.products,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       shrinkWrap: true,
//       padding: EdgeInsets.zero,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: products.length,
//       separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
//       itemBuilder: (_, index) {
//         return SizedBox(
//           height: 170,
//           child: ProductCard(
//             product: products[index],
//           ),
//         );
//       },
//     );
//   }
// }
