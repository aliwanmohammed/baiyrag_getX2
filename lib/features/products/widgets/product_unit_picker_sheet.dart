import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/models/product_model.dart';
import '../domain/repositories/product_repository.dart';
import '../models/product_unit_model.dart';

/// Represents one selected product + unit combination.
///
/// This maps directly to the Offers API:
/// {
///   "product_id": 1,
///   "unit_id": 1
/// }
class ProductUnitSelection {
  final ProductModel product;
  final ProductUnitModel unit;

  ProductUnitSelection({required this.product, required this.unit});

  Map<String, dynamic> toOfferJson() {
    return {
      'product_id': int.tryParse(product.id) ?? product.id,
      'unit_id': int.tryParse(unit.id) ?? unit.id,
    };
  }

  String get key => '${product.id}_${unit.id}';
}

/// Reusable product + unit picker.
///
/// Opens as a modal bottom sheet and supports selecting
/// multiple product/unit combinations.
///
/// Example:
///
/// ```dart
/// final result = await showModalBottomSheet<List<ProductUnitSelection>>(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => ProductUnitPickerSheet(
///     repository: DependencyInjection.productRepository,
///   ),
/// );
/// ```
class ProductUnitPickerSheet extends StatefulWidget {
  final ProductRepository repository;

  /// Existing selections, useful when editing an offer.
  final List<ProductUnitSelection> initialSelections;

  const ProductUnitPickerSheet({
    super.key,
    required this.repository,
    this.initialSelections = const [],
  });

  @override
  State<ProductUnitPickerSheet> createState() => _ProductUnitPickerSheetState();
}

class _ProductUnitPickerSheetState extends State<ProductUnitPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ProductModel> _products = [];

  final Map<String, ProductUnitSelection> _selected = {};

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  String? _error;

  int _page = 1;

  String _search = '';

  @override
  void initState() {
    super.initState();

    for (final selection in widget.initialSelections) {
      _selected[selection.key] = selection;
    }

    _scrollController.addListener(_handleScroll);

    _loadProducts(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Data
  // ─────────────────────────────────────────────

  Future<void> _loadProducts({bool reset = false}) async {
    if (_loading || _loadingMore) return;

    if (reset) {
      _page = 1;
      _hasMore = true;
      _error = null;

      setState(() {
        _loading = true;
        _products.clear();
      });
    } else {
      if (!_hasMore) return;

      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final response = await widget.repository.getProducts(
        search: _search.isEmpty ? null : _search,
        page: _page,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final newProducts = response.data?.items ?? [];

        setState(() {
          _products.addAll(newProducts);

          // If the API returns less than a normal page,
          // we consider it the last page.
          _hasMore = newProducts.isNotEmpty;

          if (newProducts.isNotEmpty) {
            _page++;
          }

          _loading = false;
          _loadingMore = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = lang.t('products_load_error');
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadProducts();
    }
  }

  Future<void> _searchProducts(String value) async {
    final query = value.trim();

    if (query == _search) return;

    _search = query;

    await _loadProducts(reset: true);
  }

  // ─────────────────────────────────────────────
  // Selection
  // ─────────────────────────────────────────────

  void _toggleUnit(ProductModel product, ProductUnitModel unit) {
    final selection = ProductUnitSelection(product: product, unit: unit);

    setState(() {
      if (_selected.containsKey(selection.key)) {
        _selected.remove(selection.key);
      } else {
        _selected[selection.key] = selection;
      }
    });
  }

  bool _isSelected(ProductModel product, ProductUnitModel unit) {
    return _selected.containsKey('${product.id}_${unit.id}');
  }

  void _confirm() {
    Navigator.of(context).pop(_selected.values.toList());
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      child: Material(
        color: cs.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .9),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildSearch(),
              if (_selected.isNotEmpty) _buildSelectedBar(),
              Expanded(child: _buildProducts()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.outline,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              lang.t('select_products'),
              style: AppTypography.headlineSmall,
            ),
          ),
          if (_selected.isNotEmpty)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                lang.t('selected_count', {'count': _selected.length}),
                style:
                    AppTypography.badge.copyWith(color: AppColors.primaryDark),
              ),
            ),
          SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: lang.t('close'),
            onPressed: () => Navigator.of(context).pop(),
            icon: AppIcon(Icons.close_rounded, size: AppIconSize.medium),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _searchProducts,
        decoration: InputDecoration(
          hintText: lang.t('search_product_hint_short'),
          prefixIcon: AppIcon(Icons.search_rounded, size: AppIconSize.medium),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchProducts('');
                    setState(() {});
                  },
                  icon: AppIcon(Icons.clear_rounded, size: AppIconSize.medium),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSelectedBar() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        scrollDirection: Axis.horizontal,
        itemCount: _selected.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.xs),
        itemBuilder: (_, index) {
          final selection = _selected.values.elementAt(index);

          return InputChip(
            avatar:
                AppIcon(Icons.inventory_2_outlined, size: AppIconSize.small),
            label: Text(
              '${selection.product.name} • ${selection.unit.unitName}',
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () {
              setState(() {
                _selected.remove(selection.key);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildProducts() {
    if (_loading) {
      return Center(child: AppLoading(type: AppLoadingType.pulse));
    }

    if (_error != null && _products.isEmpty) {
      return _buildError();
    }

    if (_products.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
        itemCount: _products.length + (_loadingMore ? 1 : 0),
        itemBuilder: (_, index) {
          if (index >= _products.length) {
            return Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                  child: AppLoading(type: AppLoadingType.ring, size: 24)),
            );
          }

          return _ProductPickerCard(
            product: _products[index],
            isSelected: _isProductPartiallySelected(_products[index]),
            selectedUnits: _selectedUnitsFor(_products[index]),
            onToggleUnit: (unit) {
              _toggleUnit(_products[index], unit);
            },
          );
        },
      ),
    );
  }

  bool _isProductPartiallySelected(ProductModel product) {
    final units = product.units.cast<ProductUnitModel>();

    return units.any((unit) => _isSelected(product, unit));
  }

  List<ProductUnitModel> _selectedUnitsFor(ProductModel product) {
    final units = product.units.cast<ProductUnitModel>();

    return units.where((unit) => _isSelected(product, unit)).toList();
  }

  Widget _buildEmpty() {
    return Center(
      child: AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: lang.t('no_products'),
        subtitle: lang.t('search_product_or_barcode'),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: AppErrorState(
        message: _error ?? lang.t('generic_error'),
        onRetry: () => _loadProducts(reset: true),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 18,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _selected.isEmpty ? null : _confirm,
          icon: AppIcon(Icons.check_rounded, size: AppIconSize.medium),
          label: Text(
            _selected.isEmpty
                ? lang.t('select_at_least_one_unit')
                : lang
                    .t('confirm_selection_count', {'count': _selected.length}),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Product Card
// ═══════════════════════════════════════════════════════

class _ProductPickerCard extends StatefulWidget {
  final ProductModel product;
  final bool isSelected;
  final List<ProductUnitModel> selectedUnits;
  final ValueChanged<ProductUnitModel> onToggleUnit;

  const _ProductPickerCard({
    required this.product,
    required this.isSelected,
    required this.selectedUnits,
    required this.onToggleUnit,
  });

  @override
  State<_ProductPickerCard> createState() => _ProductPickerCardState();
}

class _ProductPickerCardState extends State<_ProductPickerCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    // If one of its units is already selected,
    // open it automatically.
    _expanded = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final units = product.units.cast<ProductUnitModel>();

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: .5)
              : Colors.grey.withValues(alpha: .15),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  _ProductImage(image: product.image),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge,
                        ),
                        SizedBox(height: 6),
                        Text(
                          lang.t(
                              'available_units_count', {'count': units.length}),
                          style: AppTypography.labelSmall.copyWith(
                            color: widget.isSelected
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? .5 : 0,
                    duration: Duration(milliseconds: 200),
                    child: AppIcon(Icons.keyboard_arrow_down_rounded,
                        size: AppIconSize.medium),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  Divider(height: 1),
                  SizedBox(height: 8),
                  ...units.map(
                    (unit) => _UnitOption(
                      unit: unit,
                      selected: widget.selectedUnits.any(
                        (selected) => selected.id == unit.id,
                      ),
                      onTap: () {
                        widget.onToggleUnit(unit);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            secondChild: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Unit Option
// ═══════════════════════════════════════════════════════

class _UnitOption extends StatelessWidget {
  final ProductUnitModel unit;
  final bool selected;
  final VoidCallback onTap;

  const _UnitOption({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .07)
              : Colors.grey.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: selected
                  ? AppIcon(Icons.check_rounded,
                      size: AppIconSize.small, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.unitName,
                    style: AppTypography.titleSmall.copyWith(
                      color: selected ? AppColors.primary : null,
                    ),
                  ),
                  if (unit.quantity > 0)
                    Text(
                      lang.t('quantity_value', {'quantity': unit.quantity}),
                      style: AppTypography.bodySmall,
                    ),
                ],
              ),
            ),
            Text(
              '${unit.price.toStringAsFixed(0)} ر.ي',
              style: AppTypography.titleSmall.copyWith(
                color: selected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Product Image
// ═══════════════════════════════════════════════════════

class _ProductImage extends StatelessWidget {
  final String image;

  const _ProductImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: image.isEmpty
          ? AppIcon(Icons.inventory_2_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: AppIconSize.large)
          : AppCachedImage(imageUrl: image, fit: BoxFit.contain),
    );
  }
}
