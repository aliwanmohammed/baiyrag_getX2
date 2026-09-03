import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bhm_supermarket/features/ads/controllers/ads_controller.dart';
import 'package:bhm_supermarket/features/ads/controllers/offers_controller.dart';
import 'package:bhm_supermarket/features/categories/controllers/category_controller.dart';
import 'package:bhm_supermarket/features/categories/widgets/categories_pinned.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../../products/widgets/products_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshHome() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    assert(() {
      debugPrint('========== HOME REFRESH START ==========');
      return true;
    }());

    try {
      await Future.wait([
        Get.find<HomeController>().reload(),
        Get.find<CategoryController>().reload(),
        Get.find<AdsController>().reload(),
        Get.find<OffersController>().reload(),
      ]);

      assert(() {
        debugPrint('========== HOME REFRESH DONE ==========');
        return true;
      }());
    } catch (e, stackTrace) {
      assert(() {
        debugPrint('========== HOME REFRESH ERROR: $e ==========');
        debugPrintStack(stackTrace: stackTrace);
        return true;
      }());
    } finally {
      if (mounted) {
        _isRefreshing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdsController>(builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    return Scaffold(
      body: AppConstrainedContent(
        addHorizontalPadding: false,
        child: SafeArea(
          child: NestedScrollView(
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              final hasAds = Get.find<AdsController>().ads.isNotEmpty;

              return [
                SliverToBoxAdapter(
                  child: hasAds
                      ? HomeBanner()
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            8,
                            AppSpacing.lg,
                            8,
                          ),
                          child: HomeHeader(isOverlay: false),
                        ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchDelegate(),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoriesDelegate(),
                ),
              ];
            },
            body: RefreshIndicator(
              displacement: 50,
              onRefresh: _refreshHome,
              child: _HomeBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) => _buildBody(context, controller),
    );
  }

  Widget _buildBody(BuildContext context, HomeController controller) {
    if (controller.state == HomeLoadState.loading ||
        controller.state == HomeLoadState.initial) {
      return CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppLoading.fullPage(message: lang.t('loading_products')),
          ),
        ],
      );
    }

    if (controller.state == HomeLoadState.error &&
        controller.products.isEmpty) {
      return CustomScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: lang.t('products_load_error_title'),
              message: controller.error ?? lang.t('network_retry'),
              onRetry: () => controller.loadProducts(),
            ),
          ),
        ],
      );
    }

    if (controller.state == HomeLoadState.empty) {
      return CustomScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: lang.t('no_products'),
              subtitle: lang.t('products_coming_soon'),
            ),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 500 &&
            controller.hasNextPage &&
            !controller.isFetchingMore) {
          controller.loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (controller.state == HomeLoadState.error)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.orange.shade50,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AppIcon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: AppIconSize.small,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lang.t('products_refresh_stale'),
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.small,
                        text: lang.t('refresh'),
                        onPressed: controller.reload,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(6, 4, 6, AppSpacing.xxl),
            sliver: SliverToBoxAdapter(
              child: ProductsGrid(
                products: controller.products,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ),
          if (controller.isFetchingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: AppLoading(size: 28),
                  ),
                ),
              ),
            ),
          if (!controller.hasNextPage && controller.products.isNotEmpty)
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _SearchDelegate extends SliverPersistentHeaderDelegate {
  _SearchDelegate();

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 5,
          ),
          child: HomeSearchBar(enableHero: true),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchDelegate oldDelegate) => false;
}

class _CategoriesDelegate extends SliverPersistentHeaderDelegate {
  _CategoriesDelegate();

  @override
  double get minExtent => 82;

  @override
  double get maxExtent => 82;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: overlapsContent ? 2 : 0,
      child: SafeArea(bottom: false, child: CategoriesPinned()),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoriesDelegate oldDelegate) {
    return false;
  }
}
