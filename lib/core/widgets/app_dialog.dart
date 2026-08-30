import 'package:flutter/material.dart';

import '../design_system/components/app_icon.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

// ════════════════════════════════════════════════════════════
// AppDialog — مكوّن الـ Dialog الموحّد للتطبيق
// ════════════════════════════════════════════════════════════

/// استخدم Dialog فقط عندما تحتاج قراراً من المستخدم:
/// - تأكيد حذف
/// - تسجيل خروج
/// - إلغاء طلب
/// - عمليات لا يمكن التراجع عنها
///
/// لا تستخدمه لأخطاء API العادية — استخدم [AppMessage] بدلاً منه.
class AppDialog {
  AppDialog._();

  // ── confirm ────────────────────────────────────────────────────────────────

  /// Dialog تأكيد مع زرين: إلغاء + تأكيد.
  ///
  /// [isDanger] يُلوّن زر التأكيد باللون الأحمر ويُغيّر الأيقونة.
  /// يُعيد `true` عند التأكيد، `false` أو `null` عند الإلغاء.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDanger = false,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) => _ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
      ),
    );
  }

  // ── info ───────────────────────────────────────────────────────────────────

  /// Dialog معلومات بدون خيار تأكيد/إلغاء — زر إغلاق واحد فقط.
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String closeText = 'حسناً',
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _InfoDialog(
        title: title,
        message: message,
        closeText: closeText,
      ),
    );
  }

  // ── loginRequired ──────────────────────────────────────────────────────────

  /// Dialog تسجيل الدخول المطلوب.
  static Future<bool?> loginRequired(
    BuildContext context, {
    String message = 'يجب تسجيل الدخول لاستخدام هذه الميزة.',
  }) {
    return confirm(
      context,
      title: 'تسجيل الدخول مطلوب',
      message: message,
      confirmText: 'تسجيل الدخول',
      cancelText: 'لاحقاً',
      isDanger: false,
    );
  }
}

// ════════════════════════════════════════════════════════════
// _ConfirmDialog
// ════════════════════════════════════════════════════════════

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDanger,
  });

  Color get _accentColor => isDanger ? AppColors.error : AppColors.primary;
  Color get _accentLight =>
      isDanger ? AppColors.errorLight : AppColors.primaryExtraLight;
  IconData get _icon =>
      isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AppIcon(_icon, color: _accentColor, size: AppIconSize.medium),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleLarge.copyWith(
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ── Actions ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(cancelText),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _InfoDialog
// ════════════════════════════════════════════════════════════

class _InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String closeText;

  const _InfoDialog({
    required this.title,
    required this.message,
    required this.closeText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const AppIcon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                    size: AppIconSize.medium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleLarge.copyWith(
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                child: Text(closeText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
