import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/app_icon.dart';
import '../../../../core/design_system/components/feedback/app_loading.dart';
import '../../../../core/utils/launcher_utils.dart';
import '../../../../core/widgets/app_message.dart';
import '../../models/delivery_order_model.dart';
import '../../controllers/delivery_controller.dart';

class DeliveryOrderDetailsSheet extends StatefulWidget {
  final DeliveryOrderModel order;

  const DeliveryOrderDetailsSheet({
    super.key,
    required this.order,
  });

  static void show(
    BuildContext context,
    DeliveryOrderModel order,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryOrderDetailsSheet(
        order: order,
      ),
    );
  }

  @override
  State<DeliveryOrderDetailsSheet> createState() =>
      _DeliveryOrderDetailsSheetState();
}

class _DeliveryOrderDetailsSheetState extends State<DeliveryOrderDetailsSheet> {
  bool _isClaiming = false;
  bool _isDelivering = false;

  @override
  Widget build(BuildContext context) {
  return GetBuilder<DeliveryController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final colorScheme = Theme.of(context).colorScheme;

    final isAvailableOrder = controller.availableOrders.any(
      (order) => order.id == widget.order.id,
    );

    final currentOrder = controller.orders.firstWhere(
      (order) => order.id == widget.order.id,
      orElse: () => controller.selectedOrder?.id == widget.order.id
          ? controller.selectedOrder!
          : widget.order,
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(
                    currentOrder,
                    colorScheme,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle(
                    'العميل',
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    title: currentOrder.customerName,
                  ),
                  if (currentOrder.customerPhone.isNotEmpty)
                    _buildPhoneRow(
                      currentOrder.customerPhone,
                      colorScheme,
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildAddressSection(
                    currentOrder,
                    colorScheme,
                  ),
                  if (currentOrder.notes != null &&
                      currentOrder.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle(
                      'ملاحظات',
                    ),
                    _buildNotes(
                      currentOrder.notes!,
                      colorScheme,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _buildPaymentSection(
                    currentOrder,
                    colorScheme,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(
                    'المنتجات (${currentOrder.items.length})',
                  ),
                  ...currentOrder.items.map(
                    (item) => _buildOrderItem(item, colorScheme),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          _buildBottomAction(
            controller: controller,
            order: currentOrder,
            isAvailableOrder: isAvailableOrder,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Header
  // ===========================================================================

  Widget _buildOrderHeader(
    DeliveryOrderModel order,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'طلب #${order.orderNumber}',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _StatusBadge(
          status: order.status,
        ),
      ],
    );
  }

  // ===========================================================================
  // Phone
  // ===========================================================================

  Widget _buildPhoneRow(
    String phone,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _InfoRow(
            icon: Icons.phone_outlined,
            title: phone,
            isPhone: true,
          ),
        ),
        IconButton(
          tooltip: 'نسخ الرقم',
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: phone,
              ),
            );

            if (!mounted) return;

            AppMessage.success(
              context,
              'تم نسخ الرقم',
            );
          },
          icon: AppIcon(
            Icons.copy,
            size: AppIconSize.small,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          tooltip: 'اتصال',
          onPressed: () => _callCustomer(phone),
          icon: AppIcon(
            Icons.phone,
            size: AppIconSize.small,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Future<void> _callCustomer(
    String phone,
  ) async {
    final success = await LauncherUtils.callPhone(
      phone,
    );

    if (!mounted) return;

    if (!success) {
      AppMessage.error(
        context,
        'لا يمكن إجراء المكالمة',
      );
    }
  }

  // ===========================================================================
  // Address
  // ===========================================================================

  Widget _buildAddressSection(
    DeliveryOrderModel order,
    ColorScheme colorScheme,
  ) {
    final location = order.location;

    final hasCoordinates =
        location?.latitude != null && location?.longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          'عنوان التوصيل',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(
              Icons.location_on_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                order.address.isEmpty ? 'لا يوجد عنوان' : order.address,
                style: AppTypography.bodyMedium,
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'نسخ العنوان',
                  onPressed: order.address.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(
                            ClipboardData(
                              text: order.address,
                            ),
                          );

                          if (!mounted) {
                            return;
                          }

                          AppMessage.success(
                            context,
                            'تم نسخ العنوان',
                          );
                        },
                  icon: AppIcon(
                    Icons.copy,
                    size: AppIconSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                ),
                if (hasCoordinates)
                  IconButton(
                    tooltip: 'فتح الخرائط',
                    onPressed: () => _openMap(
                      location!.latitude!,
                      location.longitude!,
                    ),
                    icon: AppIcon(
                      Icons.map,
                      size: AppIconSize.small,
                      color: colorScheme.primary,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openMap(
    double latitude,
    double longitude,
  ) async {
    final success = await LauncherUtils.openMap(
      latitude,
      longitude,
    );

    if (!mounted) return;

    if (!success) {
      AppMessage.error(
        context,
        'تعذر فتح الخرائط',
      );
    }
  }

  // ===========================================================================
  // Notes
  // ===========================================================================

  Widget _buildNotes(
    String notes,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: AppIconSize.small,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              notes,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Payment
  // ===========================================================================

  Widget _buildPaymentSection(
    DeliveryOrderModel order,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          'الدفع (${order.paymentMethod})',
        ),
        _PriceRow(
          'المجموع الفرعي',
          order.subtotal,
        ),
        _PriceRow(
          'رسوم التوصيل',
          order.deliveryFee,
        ),
        if (order.discount > 0)
          _PriceRow(
            'الخصم',
            -order.discount,
            isDiscount: true,
          ),
        if (order.couponDiscount > 0)
          _PriceRow(
            'خصم الكوبون',
            -order.couponDiscount,
            isDiscount: true,
          ),
        const Divider(
          height: 24,
        ),
        _PriceRow(
          'الإجمالي',
          order.total,
          isTotal: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(
              'حالة الدفع: ',
              style: AppTypography.bodyMedium,
            ),
            Text(
              _paymentStatusLabel(
                order.paymentStatus,
              ),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: _paymentStatusColor(
                  order.paymentStatus,
                  colorScheme,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _paymentStatusLabel(
    String status,
  ) {
    switch (status) {
      case 'paid':
        return 'مدفوع';

      case 'pending':
        return 'غير مدفوع';

      case 'failed':
        return 'فشل الدفع';

      default:
        return status.isEmpty ? 'غير محدد' : status;
    }
  }

  Color _paymentStatusColor(
    String status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case 'paid':
        return Colors.green.shade700;

      case 'failed':
        return colorScheme.error;

      case 'pending':
      default:
        return Colors.orange.shade700;
    }
  }

  // ===========================================================================
  // Items
  // ===========================================================================

  Widget _buildOrderItem(
    DeliveryOrderItemModel item,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}x',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.displayName ?? 'منتج',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.unit != null)
                  Text(
                    item.unit!.displayName,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (item.isGift)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                'هدية',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.pink,
                ),
              ),
            )
          else
            Text(
              '${item.total.toStringAsFixed(2)} ر.س',
              style: AppTypography.bodyMedium,
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Bottom Action
  // ===========================================================================

  Widget _buildBottomAction({
    required DeliveryController controller,
    required DeliveryOrderModel order,
    required bool isAvailableOrder,
    required ColorScheme colorScheme,
  }) {
    // Available order → claim it.
    if (isAvailableOrder) {
      return _buildClaimAction(
        order: order,
        colorScheme: colorScheme,
      );
    }

    // Assigned order → deliver it.
    if (order.status == 'shipped') {
      return _buildDeliverAction(
        order: order,
        colorScheme: colorScheme,
      );
    }

    // Delivered / cancelled / other final states.
    return const SizedBox.shrink();
  }

  // ===========================================================================
  // Claim button
  // ===========================================================================

  Widget _buildClaimAction({
    required DeliveryOrderModel order,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _isClaiming
              ? null
              : () => _claimOrder(
                    order,
                  ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: _isClaiming
              ? AppLoading(
                  type: AppLoadingType.bars,
                  size: 24,
                  color: colorScheme.onPrimary,
                )
              : Text(
                  'استلام الطلب',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Deliver button
  // ===========================================================================

  Widget _buildDeliverAction({
    required DeliveryOrderModel order,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isDelivering
              ? null
              : () => _deliverOrder(
                    order,
                  ),
          icon: _isDelivering
              ? const SizedBox.shrink()
              : const AppIcon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          label: _isDelivering
              ? const AppLoading(
                  type: AppLoadingType.bars,
                  size: 24,
                  color: Colors.white,
                )
              : Text(
                  'تم التسليم',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Claim
  // ===========================================================================

  Future<void> _claimOrder(
    DeliveryOrderModel order,
  ) async {
    if (_isClaiming) return;

    setState(() {
      _isClaiming = true;
    });

    final controller = Get.find<DeliveryController>();

    final error = await controller.claimOrder(
      order.id,
    );

    if (!mounted) return;

    setState(() {
      _isClaiming = false;
    });

    if (error != null) {
      AppMessage.error(
        context,
        error,
      );

      return;
    }

    AppMessage.success(
      context,
      'تم استلام الطلب للتوصيل بنجاح',
    );

    Navigator.of(context).pop();
  }

  // ===========================================================================
  // Deliver
  // ===========================================================================

  Future<void> _deliverOrder(
    DeliveryOrderModel order,
  ) async {
    if (_isDelivering) return;

    setState(() {
      _isDelivering = true;
    });

    final controller = Get.find<DeliveryController>();

    final error = await controller.updateOrderStatus(
      order.id,
      status: 'delivered',
      paymentStatus: 'paid',
    );

    if (!mounted) return;

    setState(() {
      _isDelivering = false;
    });

    if (error != null) {
      AppMessage.error(
        context,
        error,
      );

      return;
    }

    AppMessage.success(
      context,
      'تم تسليم الطلب بنجاح',
    );

    Navigator.of(context).pop();
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(status, context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: AppTypography.labelSmall.copyWith(
          color: _foregroundColor(
            status,
            context,
          ),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _label(
    String value,
  ) {
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
        return value.isEmpty ? 'غير محدد' : value;
    }
  }

  Color _backgroundColor(
    String value,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (value) {
      case 'delivered':
        return Colors.green.shade50;

      case 'cancelled':
        return colorScheme.errorContainer;

      case 'shipped':
        return colorScheme.primaryContainer;

      case 'processing':
        return Colors.orange.shade50;

      case 'confirmed':
        return Colors.indigo.shade50;

      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _foregroundColor(
    String value,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (value) {
      case 'delivered':
        return Colors.green.shade700;

      case 'cancelled':
        return colorScheme.onErrorContainer;

      case 'shipped':
        return colorScheme.onPrimaryContainer;

      case 'processing':
        return Colors.orange.shade700;

      case 'confirmed':
        return Colors.indigo.shade700;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

// =============================================================================
// Section Title
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(
    this.title,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// =============================================================================
// Info Row
// =============================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isPhone;

  const _InfoRow({
    required this.icon,
    required this.title,
    this.isPhone = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AppIcon(
            icon,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              textDirection: isPhone ? TextDirection.ltr : null,
              textAlign: isPhone ? TextAlign.right : null,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Price Row
// =============================================================================

class _PriceRow extends StatelessWidget {
  final String title;
  final double amount;
  final bool isTotal;
  final bool isDiscount;

  const _PriceRow(
    this.title,
    this.amount, {
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium,
          ),
          Text(
            '${amount.toStringAsFixed(2)} ر.س',
            style: isTotal
                ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium.copyWith(
                    color: isDiscount ? colorScheme.error : null,
                  ),
          ),
        ],
      ),
    );
  }
}
