import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/models/category_model.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../controllers/category_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _open(BuildContext context, CategoryModel category) {
    context.push(
      '${AppRoutes.categories}/${category.id}?name=${Uri.encodeComponent(category.name)}',
    );
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<CategoryController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<CategoryController>();

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: AppLoading()));
    }

    if (controller.error != null) {
      return Scaffold(
        appBar: const AppPageHeader(title: "الأقسام", showBack: false),
        body: AppEmptyState(
          icon: Icons.warning_rounded,
          title: "تعذر تحميل الأقسام",
          subtitle: controller.error,
          actionLabel: "إعادة المحاولة",
          onAction: controller.reload,
        ),
      );
    }

    final categories = [
      const CategoryModel(
        id: 'special_offers',
        nameAr: 'العروض',
        nameEn: 'Offers',
        image: '',
        parentId: null,
        sortOrder: 0,
      ),
      ...controller.mainCategories,
    ];

    if (categories.isEmpty) {
      return const Scaffold(
        body: AppEmptyState(
          icon: Icons.inventory_2_rounded,
          title: "لا توجد أقسام",
          subtitle: "سيتم إضافة الأقسام قريباً",
        ),
      );
    }

    return Scaffold(
      appBar: const AppPageHeader(title: "الأقسام", showBack: false),
      body: AppConstrainedContent(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = (constraints.maxWidth / 160).floor();
            if (crossAxisCount < 2) crossAxisCount = 2;

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: .92,
              ),
              itemBuilder: (_, index) {
                final category = categories[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    onTap: () => _open(context, category),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: AppShadows.card,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Expanded(
                              child: Hero(
                                tag: 'cat_${category.id}',
                                child: category.imageUrl.isNotEmpty
                                    ? AppCachedImage(
                                        imageUrl: category.imageUrl,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        Icons.category_rounded,
                                        size: 42,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
