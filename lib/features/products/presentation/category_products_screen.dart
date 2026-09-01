import 'package:bhm_supermarket/app/theme/app_colors.dart';
import 'package:bhm_supermarket/app/theme/app_radius.dart';
import 'package:bhm_supermarket/app/theme/app_spacing.dart';
import 'package:bhm_supermarket/core/design_system/components/app_icon.dart';
import 'package:bhm_supermarket/core/design_system/patterns/app_responsive.dart';import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../../../core/models/product_model.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../widgets/products_grid.dart';

/// Category products screen — loads from the product repository.
class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _sortBy = 'default';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.categoryId == 'special_offers') {
        Get.find<ProductController>().loadCategory('');
      } else {
        Get.find<ProductController>().loadCategory(widget.categoryId);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      final controller = Get.find<ProductController>();
      if (!controller.isLoading &&
          !controller.isFetchingMore &&
          controller.hasNextPage) {
        controller.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    var filtered = List<ProductModel>.from(products);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    switch (_sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<ProductController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<ProductController>();

    // final products = controller.products;
    // final isLoading = controller.isLoading;
    // final error = controller.error;
    final title = widget.categoryName ?? (widget.categoryId == 'special_offers' ? 'العروض' : 'المنتجات');

    return Scaffold(
      appBar: AppPageHeader(
        title: title,
        actions: [
          PopupMenuButton<String>(
            icon: const AppIcon(Icons.sort_rounded, size: AppIconSize.medium),
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'default', child: Text('الترتيب الافتراضي')),
              PopupMenuItem(value: 'price_asc', child: Text('السعر: من الأقل')),
              PopupMenuItem(
                value: 'price_desc',
                child: Text('السعر: من الأعلى'),
              ),
              PopupMenuItem(value: 'name', child: Text('الاسم')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث في $title...',
                prefixIcon: const AppIcon(Icons.search_rounded, size: AppIconSize.medium),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: AppConstrainedContent(
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(ProductController controller) {
    if (widget.categoryId == 'special_offers') {
      if (controller.isLoading && controller.products.isEmpty) {
        return const Center(child: AppLoading.fullPage(message: 'جاري تحميل المنتجات...'));
      }

      if (controller.error != null && controller.products.isEmpty) {
        return AppEmptyState(
          icon: Icons.warning_rounded,
          title: 'تعذر تحميل العروض',
          subtitle: controller.error,
          actionLabel: 'إعادة المحاولة',
          onAction: () => controller.loadCategory(''),
        );
      }

      final List<ProductModel> offerProducts = controller.products
          .map((product) {
            final offerUnits = product.units
                .where((unit) => unit.offer != null)
                .toList();
            return offerUnits.isEmpty
                ? null
                : product.copyWith(units: offerUnits);
          })
          .whereType<ProductModel>()
          .toList();

      final filtered = _applyFilters(offerProducts);
      if (filtered.isEmpty) {
        return Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height * 0.6,
                  ),
                  child: const AppEmptyState(
                    icon: Icons.local_offer_rounded,
                    title: 'لا توجد عروض',
                    subtitle: 'اسحب للأعلى للبحث عن المزيد من العروض',
                  ),
                ),
              ],
            ),
            if (controller.isFetchingMore)
              const PositionedDirectional(
                bottom: AppSpacing.lg,
                start: 0,
                end: 0,
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: AppLoading(size: 24),
                  ),
                ),
              ),
          ],
        );
      }

      return Column(
        children: [
          Expanded(
            child: ProductsGrid(
              products: filtered,
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: false,
            ),
          ),
          if (controller.isFetchingMore)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: AppLoading(size: 24),
                ),
              ),
            ),
        ],
      );
    }

    if (controller.isLoading && controller.products.isEmpty) {
      return const Center(child: AppLoading.fullPage(message: 'جاري تحميل المنتجات...'));
    }

    if (controller.error != null && controller.products.isEmpty) {
      return AppEmptyState(
        icon: Icons.warning_rounded,
        title: 'تعذر تحميل المنتجات',
        subtitle: controller.error,
        actionLabel: 'إعادة المحاولة',
        onAction: () => controller.loadCategory(widget.categoryId),
      );
    }

    final filtered = _applyFilters(
      controller.products
          .where((product) => product.categoryId == widget.categoryId)
          .toList(),
    );

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.loadCategory(widget.categoryId, refresh: true),
        color: Theme.of(context).colorScheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .55,
              child: const AppEmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'لا توجد منتجات',
                subtitle: 'لا توجد منتجات في هذا القسم حالياً',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadCategory(widget.categoryId, refresh: true),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
      children: [
        Expanded(
          child: ProductsGrid(
            products: filtered,
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: false,
          ),
        ),
        if (controller.isFetchingMore)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: AppLoading(size: 24),
              ),
            ),
          ),
      ],
      ),
    );
  }
}
