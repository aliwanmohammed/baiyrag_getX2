import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/delivery_order_model.dart';
import '../controllers/delivery_controller.dart';
import 'widgets/delivery_order_details_sheet.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen>
    with WidgetsBindingObserver {
  static const Duration _autoRefreshInterval = Duration(seconds: 60);

  Timer? _refreshTimer;

  bool _isRefreshing = false;
  bool _initialSnapshotReady = false;

  Set<String> _knownAvailableOrderIds = <String>{};
  Map<String, String> _knownOrderStatuses = <String, String>{};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _initialLoad();

      _refreshTimer = Timer.periodic(
        _autoRefreshInterval,
        (_) => _autoRefresh(),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // App lifecycle
  // ===========================================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOnResume();
    }
  }

  // ===========================================================================
  // Initial load
  // ===========================================================================

  Future<void> _initialLoad() async {
    if (!mounted) return;

    final controller = Get.find<DeliveryController>();

    await controller.reload();

    if (!mounted) return;

    _createInitialSnapshot(controller);
  }

  // ===========================================================================
  // Automatic refresh
  // ===========================================================================

  Future<void> _autoRefresh() async {
    if (!mounted || _isRefreshing) return;

    await _refreshAndDetectChanges(
      showRefreshIndicator: false,
    );
  }

  // ===========================================================================
  // Refresh when returning to app
  // ===========================================================================

  Future<void> _refreshOnResume() async {
    if (!mounted || _isRefreshing) return;

    await _refreshAndDetectChanges(
      showRefreshIndicator: false,
    );
  }

  // ===========================================================================
  // Pull to refresh
  // ===========================================================================

  Future<void> _manualRefresh() async {
    await _refreshAndDetectChanges(
      showRefreshIndicator: true,
    );
  }

  // ===========================================================================
  // Central refresh
  // ===========================================================================

  Future<void> _refreshAndDetectChanges({
    required bool showRefreshIndicator,
  }) async {
    if (!mounted || _isRefreshing) return;

    _isRefreshing = true;

    try {
      final controller = Get.find<DeliveryController>();

      final oldAvailableIds = Set<String>.from(
        _knownAvailableOrderIds,
      );

      final oldStatuses = Map<String, String>.from(
        _knownOrderStatuses,
      );

      await controller.reload();

      if (!mounted) return;

      final newAvailableOrders = controller.availableOrders;

      final newAvailableIds = newAvailableOrders
          .map((order) => order.id)
          .where((id) => id.isNotEmpty)
          .toSet();

      final newOrders = newAvailableOrders.where(
        (order) => order.id.isNotEmpty && !oldAvailableIds.contains(order.id),
      );

      final statusChanges = <DeliveryOrderModel>[];

      for (final order in controller.orders) {
        final previousStatus = oldStatuses[order.id];

        if (previousStatus != null && previousStatus != order.status) {
          statusChanges.add(order);
        }
      }

      _knownAvailableOrderIds = newAvailableIds;

      _knownOrderStatuses = {
        for (final order in controller.orders)
          if (order.id.isNotEmpty) order.id: order.status,
      };

      if (!_initialSnapshotReady) {
        _initialSnapshotReady = true;
        return;
      }

      // -----------------------------------------------------------------------
      // New available orders
      // -----------------------------------------------------------------------

      final newOrdersList = newOrders.toList();

      if (newOrdersList.isNotEmpty) {
        _showNotification(
          title: 'طلب جديد',
          message: newOrdersList.length == 1
              ? 'وصل طلب جديد متاح للتوصيل'
              : 'وصل ${newOrdersList.length} طلبات جديدة متاحة للتوصيل',
          icon: Icons.delivery_dining,
        );
      }

      // -----------------------------------------------------------------------
      // Existing order status changed
      // -----------------------------------------------------------------------

      if (statusChanges.isNotEmpty && newOrdersList.isEmpty) {
        final changedOrder = statusChanges.first;

        _showNotification(
          title: 'تحديث الطلب',
          message:
              'تم تحديث حالة الطلب #${changedOrder.orderNumber} إلى ${_statusLabel(changedOrder.status)}',
          icon: Icons.sync,
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  // ===========================================================================
  // Initial snapshot
  // ===========================================================================

  void _createInitialSnapshot(DeliveryController controller) {
    _knownAvailableOrderIds = controller.availableOrders
        .map((order) => order.id)
        .where((id) => id.isNotEmpty)
        .toSet();

    _knownOrderStatuses = {
      for (final order in controller.orders)
        if (order.id.isNotEmpty) order.id: order.status,
    };

    _initialSnapshotReady = true;
  }

  // ===========================================================================
  // Notification
  // ===========================================================================

  void _showNotification({
    required String title,
    required String message,
    required IconData icon,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(AppSpacing.lg),
        content: Row(
          children: [
            AppIcon(
              icon,
              color: colorScheme.onInverseSurface,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onInverseSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onInverseSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';

      case 'confirmed':
        return 'تم التأكيد';

      case 'processing':
        return 'قيد التجهيز';

      case 'shipped':
        return 'خرج للتوصيل';

      case 'delivered':
        return 'تم التسليم';

      case 'cancelled':
        return 'ملغي';

      default:
        return status.isEmpty ? 'غير محددة' : status;
    }
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
  return GetBuilder<AuthController>(
    builder: (_) => GetBuilder<DeliveryController>(
    builder: (_) => _buildGetX0(context)));
  }

  Widget _buildGetX0(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final controller = Get.find<DeliveryController>();
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                userName: user?.name ?? 'السائق',
                activeOrdersCount: controller.activeOrders.length,
              ),
              Material(
                color: colorScheme.surface,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'طلبات متاحة'),
                    Tab(text: 'طلباتي'),
                  ],
                ),
              ),
              Expanded(
                child: AppConstrainedContent(
                  child: controller.isLoading &&
                          controller.availableOrders.isEmpty &&
                          controller.orders.isEmpty
                      ? const Center(child: AppLoading())
                      : TabBarView(
                          children: [
                            _buildAvailableOrders(
                              controller,
                            ),
                            _buildMyOrders(
                              controller,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Available orders
  // ===========================================================================

  Widget _buildAvailableOrders(
    DeliveryController controller,
  ) {
    if (controller.error != null && controller.availableOrders.isEmpty) {
      return AppErrorState(
        message: controller.error!,
        onRetry: _manualRefresh,
      );
    }

    if (controller.availableOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _manualRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            AppEmptyState(
              title: 'لا توجد طلبات متاحة حالياً',
              icon: Icons.list_alt,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _manualRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: controller.availableOrders.length,
        itemBuilder: (context, index) {
          return _AvailableOrderCard(
            order: controller.availableOrders[index],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // My active orders
  // ===========================================================================

  Widget _buildMyOrders(
    DeliveryController controller,
  ) {
    if (controller.error != null && controller.activeOrders.isEmpty) {
      return AppErrorState(
        message: controller.error!,
        onRetry: _manualRefresh,
      );
    }

    if (controller.activeOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _manualRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            AppEmptyState(
              title: 'ليس لديك طلبات قيد التوصيل',
              icon: Icons.delivery_dining,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _manualRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: controller.activeOrders.length,
        itemBuilder: (context, index) {
          return _MyOrderCard(
            order: controller.activeOrders[index],
          );
        },
      ),
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _Header extends StatelessWidget {
  final String userName;
  final int activeOrdersCount;

  const _Header({
    required this.userName,
    required this.activeOrdersCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.24),
            child: AppIcon(
              Icons.delivery_dining,
              color: colorScheme.onPrimary,
              size: AppIconSize.large,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، $userName',
                  style: AppTypography.titleMedium.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'سائق التوصيل',
                  style: AppTypography.labelMedium.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (activeOrdersCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activeOrdersCount طلب',
                style: AppTypography.labelMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Available Order Card
// =============================================================================

class _AvailableOrderCard extends StatelessWidget {
  final DeliveryOrderModel order;

  const _AvailableOrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          DeliveryOrderDetailsSheet.show(
            context,
            order,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.orderNumber}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(0)} ر.ي',
                    style: AppTypography.titleMedium.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  AppIcon(
                    Icons.person_outline,
                    size: AppIconSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    order.customerName,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  AppIcon(
                    Icons.location_on_outlined,
                    size: AppIconSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      order.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  AppIcon(
                    Icons.shopping_bag_outlined,
                    size: AppIconSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${order.items.length} منتجات',
                    style: AppTypography.bodyMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.paymentMethod,
                      style: AppTypography.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    DeliveryOrderDetailsSheet.show(
                      context,
                      order,
                    );
                  },
                  text: 'عرض التفاصيل والاستلام',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// My Order Card
// =============================================================================

class _MyOrderCard extends StatelessWidget {
  final DeliveryOrderModel order;

  const _MyOrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          DeliveryOrderDetailsSheet.show(
            context,
            order,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.orderNumber}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _StatusBadge(
                    status: order.status,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  AppIcon(
                    Icons.person_outline,
                    size: AppIconSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    order.customerName,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  AppIcon(
                    Icons.location_on_outlined,
                    size: AppIconSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      order.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Status Badge
// =============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(status, context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(status),
        style: AppTypography.labelSmall.copyWith(
          color: _foregroundColor(status, context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _label(String value) {
    switch (value) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'processing':
        return 'قيد التجهيز';
      case 'shipped':
        return 'خرج للتوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغي';
      default:
        return value.isEmpty ? 'غير محددة' : value;
    }
  }

  Color _backgroundColor(String value, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (value) {
      case 'pending':
      case 'confirmed':
      case 'processing':
        return Colors.orange.withValues(alpha: 0.1);
      case 'shipped':
        return colorScheme.primary.withValues(alpha: 0.1);
      case 'delivered':
        return Colors.green.withValues(alpha: 0.1);
      case 'cancelled':
        return colorScheme.error.withValues(alpha: 0.1);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _foregroundColor(String value, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (value) {
      case 'pending':
      case 'confirmed':
      case 'processing':
        return Colors.orange.shade700;
      case 'shipped':
        return colorScheme.primary;
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
