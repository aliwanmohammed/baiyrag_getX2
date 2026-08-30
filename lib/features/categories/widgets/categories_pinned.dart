import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/category_controller.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/models/category_model.dart';
import 'category_chip.dart';

class CategoriesPinned extends StatelessWidget {
  const CategoriesPinned({super.key});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<CategoryController>(
    builder: (_) => GetBuilder<HomeController>(
    builder: (_) => _buildGetX0(context)));
  }

  Widget _buildGetX0(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final homeController = Get.find<HomeController>();

    final categories = [
      const CategoryModel(
        id: 'special_offers',
        nameAr: 'العروض',
        nameEn: 'Offers',
        image: '',
        parentId: null,
        sortOrder: 0,
      ),
      ...categoryController.mainCategories,
    ];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.center,
      child: SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            if (index == 0) {
              return CategoryChip(
                category: null,
                selected: homeController.selectedCategory.isEmpty,
                onTap: homeController.clearCategory,
              );
            }

            final category = categories[index - 1];

            return CategoryChip(
              category: category,
              selected: homeController.selectedCategory == category.id,
              onTap: () {
                if (category.id == 'special_offers') {
                  context.push('${AppRoutes.categories}/special_offers?name=${Uri.encodeComponent('العروض')}');
                } else {
                  homeController.selectCategory(category.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
