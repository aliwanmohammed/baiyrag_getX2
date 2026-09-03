import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/category_controller.dart';
import '../../../core/models/category_model.dart';
import 'category_chip.dart';

class CategoriesPinned extends StatelessWidget {
  const CategoriesPinned({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
        builder: (_) =>
            GetBuilder<HomeController>(builder: (_) => _buildGetX0(context)));
  }

  Widget _buildGetX0(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final homeController = Get.find<HomeController>();

    final categories = [
      CategoryModel(
        id: 'special_offers',
        nameAr: lang.t('offers'),
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
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: 8),
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
              onTap: () => homeController.selectCategory(category.id),
            );
          },
        ),
      ),
    );
  }
}
