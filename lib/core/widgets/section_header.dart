// import 'package:flutter/material.dart';

// import '../../app/theme/app_colors.dart';
// import '../../app/theme/app_spacing.dart';
// import '../../app/theme/app_typography.dart';

// class SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback? onSeeAll;

//   const SectionHeader({super.key, required this.title, this.onSeeAll});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 34,
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: AppTypography.titleLarge.copyWith(
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           if (onSeeAll != null)
//             InkWell(
//               borderRadius: BorderRadius.circular(100),
//               onTap: onSeeAll,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSpacing.sm,
//                   vertical: AppSpacing.xs,
//                 ),
//                 // child: Row(
//                 //   mainAxisSize: MainAxisSize.min,
//                 //   children: [
//                 //     // Text(
//                 //     //   'عرض الكل',
//                 //     //   style: AppTypography.labelSmall.copyWith(
//                 //     //     fontSize: 12,
//                 //     //     color: AppColors.primary,
//                 //     //     fontWeight: FontWeight.w700,
//                 //     //   ),
//                 //     // ),
//                 //     const SizedBox(width: AppSpacing.xs),
//                 //     const Icon(
//                 //       Icons.arrow_forward_ios_rounded,
//                 //       size: 14,
//                 //       color: AppColors.primary,
//                 //     ),
//                 //   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
