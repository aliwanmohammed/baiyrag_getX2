import 'package:flutter/material.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../models/payment_method.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // ignore: deprecated_member_use
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.cash,
            // ignore: deprecated_member_use
            groupValue: selectedMethod,
            activeColor: colorScheme.primary,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            title: Text(
              PaymentMethod.cash.label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: selectedMethod == PaymentMethod.cash
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          // ignore: deprecated_member_use
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.card,
            // ignore: deprecated_member_use
            groupValue: selectedMethod,
            activeColor: colorScheme.primary,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            title: Text(
              PaymentMethod.card.label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: selectedMethod == PaymentMethod.card
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
