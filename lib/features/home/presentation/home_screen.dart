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
import '../widgets/product_section.dart';

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
  return GetBuilder<AdsController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    return Scaffold(
      body: AppConstrainedContent(
        addHorizontalPadding: false,
        child: SafeArea(
          child: NestedScrollView(
          physics: const BouncingScrollPhysics(
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
                    ? const HomeBanner()
                    : const Padding(
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
                delegate: const _SearchDelegate(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: const _CategoriesDelegate(),
              ),
            ];
          },
          body: RefreshIndicator(
            displacement: 50,
            onRefresh: _refreshHome,
            child: const _HomeBody(),
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
    builder: (_) => _buildGetX1(context));
  }

  Widget _buildGetX1(BuildContext context) {
    final controller = Get.find<HomeController>();

    // ── أول تحميل — spinner ─────────────────────────────────────────────────
    if (controller.state == HomeLoadState.loading ||
        controller.state == HomeLoadState.initial) {
      return const CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: AppLoading()),
          ),
        ],
      );
    }

    // ── فشل التحميل ويجب ألا تكون هناك بيانات قديمة (أول محاولة) ──────────
    if (controller.state == HomeLoadState.error && controller.products.isEmpty) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: 'تعذر تحميل المنتجات',
              message: controller.error ?? 'تحقق من اتصالك بالإنترنت وأعد المحاولة',
              onRetry: () => Get.find<HomeController>().loadProducts(),
            ),
          ),
        ],
      );
    }

    // ── نجاح التحميل + لا يوجد منتجات (حقاً فارغ من الـ Backend) ──────────
    if (controller.state == HomeLoadState.empty) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد منتجات حالياً',
              subtitle: 'سيتم إضافة منتجات قريباً',
            ),
          ),
        ],
      );
    }

    // ── success أو refreshing (نعرض البيانات الموجودة) ─────────────────────
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // banner خطأ صغير عند فشل refresh (البيانات القديمة ما زالت ظاهرة)
        if (controller.state == HomeLoadState.error)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const AppIcon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: AppIconSize.small),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تعذر تحديث المنتجات — تعرض بيانات قديمة',
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
                      text: 'إعادة',
                      onPressed: () => Get.find<HomeController>().reload(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            6.0, // small outer padding to maximize product card width
            4,
            6.0,
            AppSpacing.xxl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ============================================================
              // HOME MODE
              // لا يوجد قسم محدد ولا بحث
              // ============================================================
              if (controller.selectedCategory.isEmpty) ...[
                if (controller.flashDeals.isNotEmpty) ...[
                  ProductSection(
                    title: 'العروض 🔥',
                    products: controller.flashDeals,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (controller.bestSellerProducts.isNotEmpty) ...[
                  ProductSection(
                    title: 'الأكثر مبيعاً 🔥',
                    products: controller.bestSellerProducts,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (controller.recommendedProducts.isNotEmpty) ...[
                  ProductSection(
                    title: 'خصيصاً لك 🔥',
                    products: controller.recommendedProducts,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],

              // ============================================================
              // PRODUCTS / CATEGORY / SEARCH MODE
              // ============================================================
              if (controller.products.isNotEmpty)
                ProductSection(
                  title: controller.selectedCategory.isNotEmpty
                      ? 'منتجات القسم'
                      : 'جميع المنتجات',
                  products: controller.products,
                ),

              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SearchDelegate extends SliverPersistentHeaderDelegate {
  const _SearchDelegate();

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 5,
          ),
          child: const HomeSearchBar(enableHero: true),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchDelegate oldDelegate) => false;
}

class _CategoriesDelegate extends SliverPersistentHeaderDelegate {
  const _CategoriesDelegate();

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
      child: const SafeArea(bottom: false, child: CategoriesPinned()),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoriesDelegate oldDelegate) {
    return false;
  }
}
