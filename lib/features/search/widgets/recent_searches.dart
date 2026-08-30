import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../controllers/product_search_controller.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({super.key});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<ProductSearchController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<ProductSearchController>();

    if (controller.recentSearches.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_rounded,
        title: "ابدأ بكتابة اسم المنتج",
        subtitle: "يمكنك البحث بالاسم أو الباركود أو القسم",
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                "عمليات البحث الأخيرة",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: const Text("مسح الكل"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: controller.recentSearches.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            itemBuilder: (_, index) {
              final item = controller.recentSearches[index];

              return ListTile(
                leading: const AppIcon(Icons.history, size: AppIconSize.medium),
                title: Text(item),
                trailing: IconButton(
                  icon: const AppIcon(Icons.close, size: AppIconSize.medium),
                  onPressed: () => controller.removeRecent(item),
                ),
                onTap: () {
                  controller.controller.text = item;

                  controller.controller.selection = TextSelection.collapsed(
                    offset: item.length,
                  );

                  controller.search(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
