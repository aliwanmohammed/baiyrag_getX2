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
      appBar: const AppPageHeader(
        title: 'التقارير',
        showBack: false,
      ),
      body: controller.isLoading && controller.sales == null
          ? const Center(child: AppLoading())
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
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 180),
          AppIcon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: AppIconSize.large,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('تعذر تحميل التقارير'),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: controller.reload,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _DateFilter(controller: controller),
        const SizedBox(height: 18),
        const Text(
          'ملخص النظام',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 12),
        _SummaryGrid(
          sales: controller.sales,
          customers: controller.customers,
          products: controller.products,
          locations: controller.locations,
        ),
        const SizedBox(height: 24),
        if (controller.orders != null) _OrdersSection(report: controller.orders!),
        const SizedBox(height: 24),
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, true),
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  controller.from ?? 'من تاريخ',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, false),
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  controller.to ?? 'إلى تاريخ',
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
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _StatCard(
          icon: Icons.payments_outlined,
          title: 'المبيعات',
          value: '${_format(sales?.totalSales ?? 0)} ر.ي',
        ),
        _StatCard(
          icon: Icons.shopping_bag_outlined,
          title: 'الطلبات',
          value: '${sales?.totalOrders ?? 0}',
        ),
        _StatCard(
          icon: Icons.people_outline,
          title: 'العملاء',
          value: '${customers?.totalCustomers ?? 0}',
        ),
        _StatCard(
          icon: Icons.inventory_2_outlined,
          title: 'المنتجات',
          value: '${products?.totalProducts ?? 0}',
        ),
        _StatCard(
          icon: Icons.location_on_outlined,
          title: 'المواقع',
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon,
              color: AppColors.primary,
              size: AppIconSize.medium,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 4),
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
      ('قيد الانتظار', report.pending, Colors.orange),
      ('مؤكد', report.confirmed, Colors.blue),
      ('قيد التجهيز', report.processing, Colors.indigo),
      ('تم الشحن', report.shipped, Colors.purple),
      ('تم التسليم', report.delivered, Colors.green),
      ('ملغي', report.cancelled, Colors.red),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الطلبات',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('إجمالي الطلبات'),
                    ),
                    Text(
                      '${report.totalOrders}',
                      style: AppTypography.titleLarge,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text('قيمة الطلبات'),
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
        const SizedBox(height: 8),
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
        const Text(
          'أداء المندوبين',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 12),
        if (controller.drivers.isEmpty)
          const AppEmptyState(
            title: 'لا توجد بيانات للمندوبين',
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
                child: const AppIcon(
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
                '${driver.deliveredOrders} طلب تم تسليمه',
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
                  const Text(
                    'عرض التفاصيل',
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
        padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              Text(
                report.name,
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                report.email,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _DriverRow(
                title: 'إجمالي الطلبات',
                value: '${report.totalOrders}',
              ),
              _DriverRow(
                title: 'قيد الانتظار',
                value: '${report.pending}',
              ),
              _DriverRow(
                title: 'قيد التجهيز',
                value: '${report.processing}',
              ),
              _DriverRow(
                title: 'تم الشحن',
                value: '${report.shipped}',
              ),
              _DriverRow(
                title: 'تم التسليم',
                value: '${report.delivered}',
              ),
              _DriverRow(
                title: 'ملغي',
                value: '${report.cancelled}',
              ),
              const Divider(height: 28),
              _DriverRow(
                title: 'إجمالي المبيعات',
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
      padding: const EdgeInsets.symmetric(vertical: 7),
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
