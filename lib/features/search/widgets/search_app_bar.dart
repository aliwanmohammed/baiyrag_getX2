import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../controllers/product_search_controller.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductSearchController>(
      builder: (_) => _buildWithSearch(context),
    );
  }

  Widget _buildWithSearch(BuildContext context) {
    final controller = Get.find<ProductSearchController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller.controller,
        autofocus: true,

        onChanged: controller.updateQuery,

        // onChanged: (value) {
        //   controller.search(value);
        // },
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج',
          prefixIcon: const AppIcon(Icons.search, size: AppIconSize.medium),
          suffixIcon: controller.controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const AppIcon(Icons.clear, size: AppIconSize.medium),
                  onPressed: () {
                    controller.controller.clear();
                    controller.clear();
                  },
                ),
        ),
      ),
    );
  }
}
