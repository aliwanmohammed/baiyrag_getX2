import 'dart:async';

import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../models/delivery_order_model.dart';
import '../controllers/delivery_controller.dart';
import 'widgets/delivery_order_details_sheet.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen>
    with WidgetsBindingObserver {
  static const Duration _autoRefreshInterval = Duration(seconds: 60);

  Timer? _refreshTimer;

  bool _isRefreshing = false;
  bool _initialSnapshotReady = false;

  Map<String, String> _knownStatuses = <String, String>{};

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
  // Lifecycle
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

    if (controller.orders.isEmpty && !controller.isLoading) {
      await controller.loadOrders();
    }

    if (!mounted) return;

    _createSnapshot(controller);
  }

  // ===========================================================================
  // Automatic refresh
  // ===========================================================================

  Future<void> _autoRefresh() async {
    if (!mounted || _isRefreshing) return;

    await _refresh();
  }

  // ===========================================================================
  // Resume
  // ===========================================================================

  Future<void> _refreshOnResume() async {
    if (!mounted || _isRefreshing) return;

    await _refresh();
  }

  // ===========================================================================
  // Pull to refresh
  // ===========================================================================

  Future<void> _manualRefresh() async {
    await _refresh();
  }

  // ===========================================================================
  // Refresh
  // ===========================================================================

  Future<void> _refresh() async {
    if (!mounted || _isRefreshing) return;

    _isRefreshing = true;

    try {
      final controller = Get.find<DeliveryController>();

      final oldStatuses = Map<String, String>.from(
        _knownStatuses,
      );

      await controller.reload();

      if (!mounted) return;

      final changedOrders = <DeliveryOrderModel>[];

      for (final order in controller.orders) {
        final oldStatus = oldStatuses[order.id];

        if (oldStatus != null && oldStatus != order.status) {
          changedOrders.add(order);
        }
      }

      _createSnapshot(controller);

      if (!_initialSnapshotReady) {
        _initialSnapshotReady = true;
        return;
      }

      if (changedOrders.isNotEmpty) {
        final order = changedOrders.first;

        _showNotification(
          'تحديث الطلب',
          'تم تحديث حالة الطلب #${order.orderNumber} إلى ${_statusLabel(order.status)}',
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  // ===========================================================================
  // Snapshot
  // ===========================================================================

  void _createSnapshot(DeliveryController controller) {
    _knownStatuses = {
      for (final order in controller.orders)
        if (order.id.isNotEmpty) order.id: order.status,
    };

    _initialSnapshotReady = true;
  }

  // ===========================================================================
  // Notification
  // ===========================================================================

  void _showNotification(
    String title,
    String message,
  ) {
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
              Icons.notifications_active_outlined,
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
  return GetBuilder<DeliveryController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final colorScheme = Theme.of(context).colorScheme;

    final history = controller.orders
        .where(
          (o) => o.status == 'delivered' || o.status == 'cancelled',
        )
        .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppPageHeader(
        title: 'سجل التوصيل',
        showBack: false,
      ),
      body: AppConstrainedContent(
        child: controller.isLoading && controller.orders.isEmpty
            ? const Center(child: AppLoading())
            : controller.error != null && controller.orders.isEmpty
                ? AppErrorState(
                    message: controller.error!,
                    onRetry: _manualRefresh,
                  )
                : RefreshIndicator(
                    onRefresh: _manualRefresh,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryItem(
                                'إجمالي الطلبات',
                                '${history.length}',
                              ),
                              _SummaryItem(
                                'مُسلَّمة',
                                '${history.where((o) => o.status == 'delivered').length}',
                              ),
                              _SummaryItem(
                                'ملغاة',
                                '${history.where((o) => o.status == 'cancelled').length}',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: history.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 160),
                                    AppEmptyState(
                                      title: 'لا يوجد سجل توصيل',
                                      icon: Icons.history,
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  itemCount: history.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSpacing.sm),
                                  itemBuilder: (_, i) {
                                    return _HistoryTile(
                                      order: history[i],
                                    );
                                  },
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
// Summary
// =============================================================================

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem(
    this.label,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// History Tile
// =============================================================================

class _HistoryTile extends StatelessWidget {
  final DeliveryOrderModel order;

  const _HistoryTile({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == 'delivered';
    final colorScheme = Theme.of(context).colorScheme;

    final badgeColor = isDelivered ? Colors.green.shade700 : colorScheme.error;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderDetails(
          context,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.orderNumber}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          isDelivered
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: AppIconSize.small,
                          color: badgeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDelivered ? 'تم التسليم' : 'ملغي',
                          style: AppTypography.labelSmall.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (order.customerName.isNotEmpty)
                Row(
                  children: [
                    AppIcon(
                      Icons.person_outline,
                      size: AppIconSize.medium,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        order.customerName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              if (order.customerName.isNotEmpty) const SizedBox(height: AppSpacing.sm),
              if (order.address.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIcon(
                      Icons.location_on_outlined,
                      size: AppIconSize.medium,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        order.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AppIcon(
                          Icons.access_time_rounded,
                          size: AppIconSize.small,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            order.createdAt ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(0)} ر.ي',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
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

  void _showOrderDetails(BuildContext context) {
    DeliveryOrderDetailsSheet.show(
      context,
      order,
    );
  }
}
