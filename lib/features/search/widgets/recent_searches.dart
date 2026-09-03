import 'package:bhm_supermarket/app/localization/lang.dart';
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
      return AppEmptyState(
        icon: Icons.search_rounded,
        title: lang.t('start_search'),
        subtitle: lang.t('search_by_name_barcode_category'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                lang.t('recent_searches'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Spacer(),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: Text(lang.t('clear_all')),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            itemCount: controller.recentSearches.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            itemBuilder: (_, index) {
              final item = controller.recentSearches[index];

              return ListTile(
                leading: AppIcon(Icons.history, size: AppIconSize.medium),
                title: Text(item),
                trailing: IconButton(
                  icon: AppIcon(Icons.close, size: AppIconSize.medium),
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
