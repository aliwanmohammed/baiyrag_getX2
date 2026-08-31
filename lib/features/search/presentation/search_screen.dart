import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../home/widgets/home_search_bar.dart';
import '../../products/widgets/product_card.dart';
import '../controllers/product_search_controller.dart';
import '../widgets/empty_search.dart';
import '../widgets/recent_searches.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return GetBuilder<ProductSearchController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final ProductSearchController controller = Get.find<ProductSearchController>();

    return Scaffold(
      appBar: const AppPageHeader(title: "البحث"),
      body: AppConstrainedContent(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: HomeSearchBar(
                enableHero: false,
                readOnly: false,
                autofocus: true,
                controller: controller.controller,
                onChanged: controller.updateQuery,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: controller.isLoading
                  ? const LinearProgressIndicator(minHeight: 2)
                  : const SizedBox(height: 2),
            ),
            Expanded(child: _SearchBody(controller: controller)),
          ],
        ),
      ),
    );
  }

}

class _SearchBody extends StatelessWidget {
  final ProductSearchController controller;

  const _SearchBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.query.isEmpty) {
      return const RecentSearches();
    }

    // Do not hide API failures behind the generic "no results" state.
    // This is especially important for diagnosing authentication/backend
    // issues while the search endpoint is being integrated.
    if (!controller.isLoading && controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: AppIconSize.large,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => controller.search(controller.query),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.isLoading && controller.results.isEmpty) {
      return EmptySearch(query: controller.query);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              AppIcon(
                Icons.inventory_2_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: AppIconSize.medium,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "${controller.results.length} منتج",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth / 160).floor();
              if (crossAxisCount < 2) crossAxisCount = 2;

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.results.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: .63,
                ),
                itemBuilder: (_, index) {
                  return ProductCard(product: controller.results[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
