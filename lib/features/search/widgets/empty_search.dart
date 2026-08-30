import 'package:flutter/material.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';

class EmptySearch extends StatelessWidget {
  final String query;

  const EmptySearch({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: "لا توجد نتائج",
      subtitle: 'لم نعثر على "$query"\nجرّب البحث باسم آخر أو بالباركود أو باسم القسم.',
    );
  }
}
