// import 'package:flutter/material.dart';
//
// import '../../../app/theme/app_colors.dart';
// import '../../../app/theme/app_radius.dart';
// import '../../../app/theme/app_spacing.dart';
// import '../../../app/theme/app_typography.dart';
// import '../../../core/design_system/components/app_icon.dart';
//
// class ProductQuantitySelector extends StatefulWidget {
//   const ProductQuantitySelector({super.key});
//
//   @override
//   State<ProductQuantitySelector> createState() =>
//       _ProductQuantitySelectorState();
// }
//
// class _ProductQuantitySelectorState extends State<ProductQuantitySelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(AppRadius.pill),
//         border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             onTap: () {
//               setState(() {
//                 quantity++;
//               });
//             },
//             child: Semantics(
//               button: true,
//               label: 'زيادة الكمية',
//               child: SizedBox(
//                 width: 22,
//                 child: AppIcon(Icons.add, size: AppIconSize.small, color: Theme.of(context).colorScheme.primary),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 22,
//             child: Center(
//               child: Text(
//                 quantity.toString(),
//                 style: AppTypography.bodyMedium.copyWith(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               if (quantity == 1) return;
//
//               setState(() {
//                 quantity--;
//               });
//             },
//             child: Semantics(
//               button: true,
//               label: 'إنقاص الكمية',
//               child: SizedBox(
//                 width: 22,
//                 child: AppIcon(Icons.remove, size: AppIconSize.small, color: Theme.of(context).colorScheme.primary),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
