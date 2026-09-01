import '../../../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/design_system/components/app_button.dart';
import '../../../../core/design_system/components/app_icon.dart';
import '../../../../core/design_system/components/app_text_field.dart';

class ManualBarcodeSheet extends StatefulWidget {
  final Future<void> Function(String barcode) onSubmit;
  final bool isLoading;

  const ManualBarcodeSheet({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Future<void> Function(String barcode) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: ManualBarcodeSheet(onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<ManualBarcodeSheet> createState() => _ManualBarcodeSheetState();
}

class _ManualBarcodeSheetState extends State<ManualBarcodeSheet> {
  late final TextEditingController _controller;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onSubmit(code);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: AppIcon(
                    Icons.keyboard_alt_outlined,
                    color: AppColors.primary,
                    size: AppIconSize.medium,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('enter_barcode_manual'),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'اكتب الرقم المطبوع أسفل الباركود على المنتج',
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Input field (LTR for numeric barcode)
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppTextField(
              controller: _controller,
              hint: 'e.g. 6281003301234',
              keyboardType: TextInputType.number,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: AppIcon(
                  Icons.qr_code_2_rounded,
                  size: AppIconSize.small,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Submit button
          AppButton(
            text: lang.t('search_product'),
            icon: AppIcon(
              Icons.search_rounded,
              size: AppIconSize.small,
              color: Colors.white,
            ),
            size: AppButtonSize.large,
            state: (_submitting || widget.isLoading)
                ? AppButtonState.loading
                : AppButtonState.defaultState,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
