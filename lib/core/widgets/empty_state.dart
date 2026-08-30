import 'package:flutter/material.dart';

import '../design_system/components/feedback/app_empty_state.dart';
import '../design_system/components/feedback/app_error_state.dart';

/// Legacy EmptyState Facade
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Legacy ErrorState Facade
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      message: message,
      onRetry: onRetry,
      title: title,
    );
  }
}

/// Legacy NetworkErrorState Facade
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorState({super.key, this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: 'لا يوجد اتصال بالإنترنت',
      message: message ?? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      onRetry: onRetry,
    );
  }
}
