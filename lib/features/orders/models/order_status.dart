import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
  unknown,
}

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return lang.t('pending');
      case OrderStatus.confirmed:
        return lang.t('confirmed');
      case OrderStatus.preparing:
        return lang.t('processing');
      case OrderStatus.shipped:
        return lang.t('shipped');
      case OrderStatus.delivered:
        return lang.t('delivered');
      case OrderStatus.cancelled:
        return lang.t('cancelled');
      case OrderStatus.unknown:
        return lang.t('unknown');
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.receipt_long_outlined;
      case OrderStatus.confirmed:
        return Icons.thumb_up_alt_outlined;
      case OrderStatus.preparing:
        return Icons.restaurant_outlined;
      case OrderStatus.shipped:
        return Icons.delivery_dining_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.unknown:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.primaryDark;
      case OrderStatus.shipped:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.unknown:
        return AppColors.textHint;
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }
}
