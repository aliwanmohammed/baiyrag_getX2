import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../auth/utils/auth_gate.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../scanner/presentation/barcode_scanner_screen.dart';
import '../controllers/navigation_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  final int? initialTab;

  const MainNavigationScreen({
    super.key,
    this.initialTab,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 0 = Home
  // 1 = Categories
  // 2 = Barcode Scanner (Center)
  // 3 = Cart
  // 4 = Profile
  static const int _tabCount = 5;

  late final List<Widget?> _tabs;

  @override
  void initState() {
    super.initState();

    // Create only the initial tab.
    // Other tabs are created lazily when opened.
    _tabs = List<Widget?>.filled(
      _tabCount,
      null,
      growable: false,
    );

    _ensureTabCreated(0);

    final initialTab = widget.initialTab;

    if (initialTab != null && initialTab >= 0 && initialTab < _tabCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _ensureTabCreated(initialTab);

        Get.find<NavigationController>().changeTab(
              initialTab,
            );
      });
    }
  }

  Widget _createTab(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();

      case 1:
        return const CategoriesScreen();

      case 2:
        return const BarcodeScannerScreen();

      case 3:
        return const CartScreen();

      case 4:
        return const ProfileScreen();

      default:
        return const SizedBox.shrink();
    }
  }

  void _ensureTabCreated(int index) {
    if (index < 0 || index >= _tabCount) return;

    if (_tabs[index] == null) {
      _tabs[index] = _createTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationController>(
      builder: (navigation) => _build(context, navigation),
    );
  }

  Widget _build(BuildContext context, NavigationController navigation) {
    final colorScheme = Theme.of(context).colorScheme;

    // Create only the currently requested tab.
    _ensureTabCreated(navigation.index);

    return Scaffold(
      body: IndexedStack(
        index: navigation.index,
        children: [
          for (var i = 0; i < _tabCount; i++)
            HeroMode(
              enabled: i == navigation.index,
              child: _tabs[i] ?? const SizedBox.shrink(),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            14,
          ),
          child: Container(
            height: 76,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: .16),
                  blurRadius: 45,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'الرئيسية',
                    index: 0,
                    current: navigation.index,
                    onTap: (i) => _go(context, i),
                  ),
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'الأقسام',
                    index: 1,
                    current: navigation.index,
                    onTap: (i) => _go(context, i),
                  ),
                  _ScannerCenterBtn(
                    current: navigation.index,
                    onTap: (i) => _go(context, i),
                  ),
                  Obx(() {
                    final cart = Get.find<CartController>();
                    cart.revision.value;
                    // The read above is intentional: subscribe only this item
                    // to cart mutations instead of rebuilding the whole shell.
                    return _CartNavItem(
                      count: cart.itemsCount,
                      index: 3,
                      current: navigation.index,
                      onTap: (i) => _go(context, i),
                    );
                  }),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'حسابي',
                    index: 4,
                    current: navigation.index,
                    onTap: (i) => _go(context, i),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, int index) {
    // Only Profile requires authentication.
    if (index == 4) {
      AuthGate.check(
        context,
        destination: '${AppRoutes.home}?tab=$index',
        onAuthenticated: () {
          _ensureTabCreated(index);

          Get.find<NavigationController>().changeTab(
                index,
              );
        },
      );

      return;
    }

    // Public tabs.
    _ensureTabCreated(index);

    Get.find<NavigationController>().changeTab(
          index,
        );
  }
}

// ────────────────────────────────────────────────────────────────
// Regular navigation item
// ────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: AppRadius.mdRadius,
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 180),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary.withValues(alpha: .08)
                  : Colors.transparent,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: AppIcon(
                    icon,
                    key: ValueKey(selected),
                    size: AppIconSize.medium,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Center Barcode Scanner button
// ────────────────────────────────────────────────────────────────

class _ScannerCenterBtn extends StatelessWidget {
  final int current;
  final void Function(int) onTap;

  const _ScannerCenterBtn({
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == 2;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onTap(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1,
              duration: const Duration(milliseconds: 180),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.tertiary,
                          ],
                        )
                      : null,
                  color: selected
                      ? null
                      : colorScheme.primary.withValues(
                          alpha: .08,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AppIcon(
                    Icons.qr_code_scanner_rounded,
                    color: selected ? colorScheme.onPrimary : colorScheme.primary,
                    size: AppIconSize.medium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'مسح باركود',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Cart navigation item (with live badge)
// ────────────────────────────────────────────────────────────────

class _CartNavItem extends StatelessWidget {
  final int count;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _CartNavItem({
    required this.count,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: AppRadius.mdRadius,
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 180),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary.withValues(alpha: .08)
                  : Colors.transparent,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: AppIcon(
                        Icons.shopping_cart_rounded,
                        key: ValueKey(selected),
                        size: AppIconSize.medium,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (count > 0)
                      PositionedDirectional(
                        top: -4,
                        end: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Center(
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.onError,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'السلة',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
