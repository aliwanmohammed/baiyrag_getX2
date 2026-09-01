import '../../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../models/admin_reports_model.dart';
import '../controllers/admin_reports_controller.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AdminReportsController>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<AdminReportsController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<AdminReportsController>();

    return Scaffold(
      appBar: AppPageHeader(
        title: lang.t('reports'),
        showBack: false,
      ),
      body: controller.isLoading && controller.sales == null
          ? Center(child: AppLoading())
          : RefreshIndicator(
              onRefresh: controller.reload,
              child: _ReportsBody(controller: controller),
            ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  final AdminReportsController controller;

  const _ReportsBody({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.error != null && controller.sales == null) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180),
          AppIcon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: AppIconSize.large,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(lang.t('reports_load_error')),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: controller.reload,
              icon: Icon(Icons.refresh),
              label: Text(lang.t('retry')),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      children: [
        _DateFilter(controller: controller),
        SizedBox(height: 18),
        Text(
          lang.t('system_summary'),
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: 12),
        _SummaryGrid(
          sales: controller.sales,
          customers: controller.customers,
          products: controller.products,
          locations: controller.locations,
        ),
        SizedBox(height: 24),
        if (controller.orders != null) _OrdersSection(report: controller.orders!),
        SizedBox(height: 24),
        _DriversSection(
          controller: controller,
        ),
      ],
    );
  }
}

class _DateFilter extends StatelessWidget {
  final AdminReportsController controller;

  const _DateFilter({
    required this.controller,
  });

  Future<void> _pickDate(
    BuildContext context,
    bool isFrom,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    final date = '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';

    if (isFrom) {
      controller.from = date;
    } else {
      controller.to = date;
    }

    await controller.loadReports(
      fromDate: controller.from,
      toDate: controller.to,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, true),
                icon: Icon(Icons.calendar_today_outlined),
                label: Text(
                  controller.from ?? lang.t('from_date'),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, false),
                icon: Icon(Icons.calendar_today_outlined),
                label: Text(
                  controller.to ?? lang.t('to_date'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final SalesReport? sales;
  final CustomersReport? customers;
  final ProductsReport? products;
  final LocationsReport? locations;

  const _SummaryGrid({
    required this.sales,
    required this.customers,
    required this.products,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _StatCard(
          icon: Icons.payments_outlined,
          title: lang.t('sales'),
          value: '${_format(sales?.totalSales ?? 0)} ر.ي',
        ),
        _StatCard(
          icon: Icons.shopping_bag_outlined,
          title: lang.t('orders'),
          value: '${sales?.totalOrders ?? 0}',
        ),
        _StatCard(
          icon: Icons.people_outline,
          title: lang.t('customers'),
          value: '${customers?.totalCustomers ?? 0}',
        ),
        _StatCard(
          icon: Icons.inventory_2_outlined,
          title: lang.t('products'),
          value: '${products?.totalProducts ?? 0}',
        ),
        _StatCard(
          icon: Icons.location_on_outlined,
          title: lang.t('locations'),
          value: '${locations?.totalLocations ?? 0}',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon,
              color: AppColors.primary,
              size: AppIconSize.medium,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodySmall,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersSection extends StatelessWidget {
  final OrdersReport report;

  const _OrdersSection({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      (lang.t('pending'), report.pending, Colors.orange),
      (lang.t('confirmed'), report.confirmed, Colors.blue),
      (lang.t('processing'), report.processing, Colors.indigo),
      (lang.t('shipped'), report.shipped, Colors.purple),
      (lang.t('delivered'), report.delivered, Colors.green),
      (lang.t('cancelled'), report.cancelled, Colors.red),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('orders'),
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(lang.t('total_orders')),
                    ),
                    Text(
                      '${report.totalOrders}',
                      style: AppTypography.titleLarge,
                    ),
                  ],
                ),
                Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(lang.t('orders_value')),
                    ),
                    Text(
                      '${_format(report.totalAmount)} ر.ي',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        ...statuses.map(
          (item) => Card(
            child: ListTile(
              leading: AppIcon(
                Icons.circle,
                size: AppIconSize.small,
                color: item.$3,
              ),
              title: Text(item.$1),
              trailing: Text(
                '${item.$2}',
                style: AppTypography.titleSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DriversSection extends StatelessWidget {
  final AdminReportsController controller;

  const _DriversSection({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('drivers_performance'),
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: 12),
        if (controller.drivers.isEmpty)
          AppEmptyState(
            title: lang.t('no_driver_data'),
          ),
        ...controller.drivers.map(
          (driver) => Card(
            child: ListTile(
              onTap: () async {
                final details = await controller.loadDriverDetails(driver.id);

                if (!context.mounted || details == null) {
                  return;
                }

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _DriverDetails(
                    report: details,
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: AppIcon(
                  Icons.delivery_dining,
                  color: AppColors.primary,
                  size: AppIconSize.medium,
                ),
              ),
              title: Text(
                driver.name,
                style: AppTypography.titleSmall,
              ),
              subtitle: Text(
                lang.t('delivered_orders_count', {'count': driver.deliveredOrders}),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_format(driver.totalSales)} ر.ي',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    lang.t('view_details'),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DriverDetails extends StatelessWidget {
  final DeliveryDriverDetailsReport report;

  const _DriverDetails({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                report.name,
                style: AppTypography.headlineSmall,
              ),
              SizedBox(height: 4),
              Text(
                report.email,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20),
              _DriverRow(
                title: lang.t('total_orders'),
                value: '${report.totalOrders}',
              ),
              _DriverRow(
                title: lang.t('pending'),
                value: '${report.pending}',
              ),
              _DriverRow(
                title: lang.t('processing'),
                value: '${report.processing}',
              ),
              _DriverRow(
                title: lang.t('shipped'),
                value: '${report.shipped}',
              ),
              _DriverRow(
                title: lang.t('delivered'),
                value: '${report.delivered}',
              ),
              _DriverRow(
                title: lang.t('cancelled'),
                value: '${report.cancelled}',
              ),
              Divider(height: 28),
              _DriverRow(
                title: lang.t('total_sales'),
                value: '${_format(report.totalSales)} ر.ي',
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _DriverRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _format(num value) {
  return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
}
