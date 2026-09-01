import '../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import '../../../core/design_system/components/feedback/app_empty_state.dart';

class EmptySearch extends StatelessWidget {
  final String query;

  const EmptySearch({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: lang.t('no_results'),
      subtitle: lang.t('no_search_results_query', {'query': query}),
    );
  }
}
