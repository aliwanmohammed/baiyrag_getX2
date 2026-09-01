import '../../../../app/localization/lang.dart';
import 'package:bhm_supermarket/features/orders/controllers/orders_controller.dart';
import 'package:flutter/material.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../app/theme/app_spacing.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Get.find<OrdersController>().loadOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<OrdersController>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<OrdersController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppPageHeader(
        title: lang.t('orders'),
        fallbackRoute: AppRoutes.home,
      ),
      body: SafeArea(
        child: GetBuilder<OrdersController>(builder: (controller) {
            if (controller.loading) {
              return AppLoading.fullPage(message: lang.t('loading_orders'));
            }

            if (controller.error != null && controller.orders.isEmpty) {
              return Center(
                child: AppErrorState(
                  message: controller.error!,
                  onRetry: controller.reload,
                ),
              );
            }

            if (controller.orders.isEmpty) {
              return Center(
                child: AppEmptyState(
                  title: lang.t('no_orders'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.reload,
              color: colorScheme.primary,
              child: AppConstrainedContent(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: controller.orders.length + (controller.loadingMore ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index == controller.orders.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(child: AppLoading(size: 24)),
                      );
                    }
                    return OrderCard(controller.orders[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
