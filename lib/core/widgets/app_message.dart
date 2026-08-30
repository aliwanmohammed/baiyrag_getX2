// import 'package:flutter/material.dart';
// import '../../app/theme/app_colors.dart';

// // ══════════════════════════════════════════════════════════════════════════════
// // نوع الرسالة
// // ══════════════════════════════════════════════════════════════════════════════

// enum AppMessageType {
//   success,
//   error,
//   warning,
//   info,
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // AppMessage
// // ══════════════════════════════════════════════════════════════════════════════

// /// نظام الرسائل المركزي في التطبيق.
// ///
// /// التصميم:
// /// - Toast عائم ومضغوط.
// /// - سطر واحد.
// /// - أيقونة دائرية.
// /// - خط جانبي حسب نوع الرسالة.
// /// - خلفية بيضاء.
// /// - ظل ناعم.
// /// - Animation دخول من الأسفل.
// /// - يدعم RTL / LTR.
// /// - يحافظ على نفس طريقة الاستدعاء الحالية.
// class AppMessage {
//   AppMessage._();

//   // ────────────────────────────────────────────────────────────────────────────
//   // Success
//   // ────────────────────────────────────────────────────────────────────────────

//   static void success(
//     BuildContext context,
//     String message, {
//     String? title,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     _show(
//       context,
//       message,
//       title: title ?? 'تم بنجاح',
//       type: AppMessageType.success,
//       actionLabel: actionLabel,
//       onAction: onAction,
//       duration: duration,
//     );
//   }

//   // ────────────────────────────────────────────────────────────────────────────
//   // Error
//   // ────────────────────────────────────────────────────────────────────────────

//   static void error(
//     BuildContext context,
//     String message, {
//     String? title,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 4),
//   }) {
//     _show(
//       context,
//       message,
//       title: title ?? 'حدث خطأ',
//       type: AppMessageType.error,
//       actionLabel: actionLabel,
//       onAction: onAction,
//       duration: duration,
//     );
//   }

//   // ────────────────────────────────────────────────────────────────────────────
//   // Warning
//   // ────────────────────────────────────────────────────────────────────────────

//   static void warning(
//     BuildContext context,
//     String message, {
//     String? title,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     _show(
//       context,
//       message,
//       title: title ?? 'تنبيه',
//       type: AppMessageType.warning,
//       actionLabel: actionLabel,
//       onAction: onAction,
//       duration: duration,
//     );
//   }

//   // ────────────────────────────────────────────────────────────────────────────
//   // Info
//   // ────────────────────────────────────────────────────────────────────────────

//   static void info(
//     BuildContext context,
//     String message, {
//     String? title,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     _show(
//       context,
//       message,
//       title: title ?? 'معلومة',
//       type: AppMessageType.info,
//       actionLabel: actionLabel,
//       onAction: onAction,
//       duration: duration,
//     );
//   }

//   // ════════════════════════════════════════════════════════════════════════════
//   // Core
//   // ════════════════════════════════════════════════════════════════════════════

//   static void _show(
//     BuildContext context,
//     String message, {
//     required String title,
//     required AppMessageType type,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     if (!context.mounted) {
//       return;
//     }

//     final messenger = ScaffoldMessenger.of(context);

//     messenger
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           behavior: SnackBarBehavior.floating,
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           padding: EdgeInsets.zero,
//           margin: const EdgeInsetsDirectional.fromSTEB(
//             22,
//             0,
//             22,
//             22,
//           ),
//           duration: duration,
//           content: _MessageToast(
//             message: message,
//             type: type,
//             actionLabel: actionLabel,
//             onAction: () {
//               messenger.hideCurrentSnackBar();
//               onAction?.call();
//             },
//           ),
//         ),
//       );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // Message Toast
// // ══════════════════════════════════════════════════════════════════════════════

// class _MessageToast extends StatefulWidget {
//   final String message;
//   final AppMessageType type;
//   final String? actionLabel;
//   final VoidCallback? onAction;

//   const _MessageToast({
//     required this.message,
//     required this.type,
//     this.actionLabel,
//     this.onAction,
//   });

//   @override
//   State<_MessageToast> createState() => _MessageToastState();
// }

// class _MessageToastState extends State<_MessageToast>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _opacity;
//   late final Animation<Offset> _slide;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 280),
//     );

//     _opacity = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOut,
//     );

//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.18),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _scale = Tween<double>(
//       begin: 0.97,
//       end: 1.0,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   // ════════════════════════════════════════════════════════════════════════════
//   // Colors
//   // ════════════════════════════════════════════════════════════════════════════

//   Color get _color {
//     switch (widget.type) {
//       case AppMessageType.success:
//         return AppColors.success;

//       case AppMessageType.error:
//         return AppColors.error;

//       case AppMessageType.warning:
//         return AppColors.warning;

//       case AppMessageType.info:
//         return AppColors.info;
//     }
//   }

//   // ════════════════════════════════════════════════════════════════════════════
//   // Icons
//   // ════════════════════════════════════════════════════════════════════════════

//   IconData get _icon {
//     switch (widget.type) {
//       case AppMessageType.success:
//         return Icons.check_rounded;

//       case AppMessageType.error:
//         return Icons.close_rounded;

//       case AppMessageType.warning:
//         return Icons.warning_amber_rounded;

//       case AppMessageType.info:
//         return Icons.info_outline_rounded;
//     }
//   }

//   // ════════════════════════════════════════════════════════════════════════════
//   // Build
//   // ════════════════════════════════════════════════════════════════════════════

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _opacity,
//       child: SlideTransition(
//         position: _slide,
//         child: ScaleTransition(
//           scale: _scale,
//           alignment: Alignment.bottomCenter,
//           child: _buildCard(context),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(BuildContext context) {
//     final hasAction = widget.actionLabel != null && widget.onAction != null;

//     return Container(
//       height: 64,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: AppColors.border.withValues(alpha: 0.55),
//           width: 0.8,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.10),
//             blurRadius: 18,
//             offset: const Offset(0, 7),
//           ),
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.035),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Stack(
//         children: [
//           // ──────────────────────────────────────────────────────────────────
//           // الخط الجانبي
//           //
//           // RTL → يظهر على اليمين مثل التصميم المعتمد.
//           // ──────────────────────────────────────────────────────────────────

//           PositionedDirectional(
//             top: 0,
//             bottom: 0,
//             end: 0,
//             child: Container(
//               width: 3,
//               color: _color,
//             ),
//           ),

//           // ──────────────────────────────────────────────────────────────────
//           // المحتوى
//           // ──────────────────────────────────────────────────────────────────

//           Padding(
//             padding: const EdgeInsetsDirectional.only(
//               start: 14,
//               end: 16,
//             ),
//             child: Directionality(
//               textDirection: TextDirection.ltr,
//               child: Row(
//                 children: [
//                   // ───────────────────────────────────────────────────────────
//                   // Icon
//                   // ───────────────────────────────────────────────────────────

//                   Container(
//                     width: 38,
//                     height: 38,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: _color,
//                     ),
//                     child: Icon(
//                       _icon,
//                       color: Colors.white,
//                       size: 21,
//                     ),
//                   ),

//                   const SizedBox(width: 14),

//                   // ───────────────────────────────────────────────────────────
//                   // Message
//                   // ───────────────────────────────────────────────────────────

//                   Expanded(
//                     child: Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: Text(
//                         widget.message,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.right,
//                         style: const TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 13.5,
//                           fontWeight: FontWeight.w500,
//                           height: 1.3,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ───────────────────────────────────────────────────────────
//                   // Action اختياري
//                   // ───────────────────────────────────────────────────────────

//                   if (hasAction) ...[
//                     const SizedBox(width: 10),
//                     Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: GestureDetector(
//                         onTap: widget.onAction,
//                         child: Text(
//                           widget.actionLabel!,
//                           style: TextStyle(
//                             color: _color,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// نوع الرسالة
// ══════════════════════════════════════════════════════════════════════════════

enum AppMessageType {
  success,
  error,
  warning,
  info,
}

// ══════════════════════════════════════════════════════════════════════════════
// AppMessage
// ══════════════════════════════════════════════════════════════════════════════

/// نظام الرسائل المركزي في التطبيق.
///
/// التصميم:
/// - Toast عائم احترافي.
/// - خلفية بيضاء.
/// - أيقونة دائرية ملونة.
/// - خط جانبي ملون.
/// - سطر واحد للرسالة.
/// - ظل ناعم.
/// - Animation دخول من الأسفل.
/// - دعم RTL / LTR.
/// - يحافظ على نفس طريقة الاستدعاء الحالية.
class AppMessage {
  AppMessage._();

  // ────────────────────────────────────────────────────────────────────────────
  // Success
  // ────────────────────────────────────────────────────────────────────────────

  static void success(
    BuildContext context,
    String message, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      type: AppMessageType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Error
  // ────────────────────────────────────────────────────────────────────────────

  static void error(
    BuildContext context,
    String message, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      type: AppMessageType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Warning
  // ────────────────────────────────────────────────────────────────────────────

  static void warning(
    BuildContext context,
    String message, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      type: AppMessageType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Info
  // ────────────────────────────────────────────────────────────────────────────

  static void info(
    BuildContext context,
    String message, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      type: AppMessageType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Core
  // ════════════════════════════════════════════════════════════════════════════

  static void _show(
    BuildContext context,
    String message, {
    required AppMessageType type,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    // نخفي أي رسالة سابقة قبل عرض الجديدة.
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,

        // المسافة عن أطراف الشاشة.
        margin: const EdgeInsetsDirectional.fromSTEB(
          20,
          0,
          20,
          20,
        ),

        duration: duration,

        content: _MessageToast(
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: () {
            messenger.hideCurrentSnackBar();
            onAction?.call();
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Message Toast
// ══════════════════════════════════════════════════════════════════════════════

class _MessageToast extends StatefulWidget {
  final String message;
  final AppMessageType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageToast({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_MessageToast> createState() => _MessageToastState();
}

class _MessageToastState extends State<_MessageToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Color
  // ════════════════════════════════════════════════════════════════════════════

  Color get _color {
    switch (widget.type) {
      case AppMessageType.success:
        return AppColors.success;

      case AppMessageType.error:
        return AppColors.error;

      case AppMessageType.warning:
        return AppColors.warning;

      case AppMessageType.info:
        return AppColors.info;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Icon
  // ════════════════════════════════════════════════════════════════════════════

  IconData get _icon {
    switch (widget.type) {
      case AppMessageType.success:
        return Icons.check_rounded;

      case AppMessageType.error:
        return Icons.close_rounded;

      case AppMessageType.warning:
        return Icons.warning_amber_rounded;

      case AppMessageType.info:
        return Icons.info_outline_rounded;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.bottomCenter,
          child: _buildCard(context),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final hasAction = widget.actionLabel != null && widget.onAction != null;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 68,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ════════════════════════════════════════════════════════════════
          // الخط الجانبي
          // ════════════════════════════════════════════════════════════════

          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════════════════
          // المحتوى
          // ════════════════════════════════════════════════════════════════

          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              14,
              10,
              14,
              10,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ═══════════════════════════════════════════════════════
                  // الأيقونة
                  // ═══════════════════════════════════════════════════════

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _color,
                    ),
                    child: Icon(
                      _icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ═══════════════════════════════════════════════════════
                  // الرسالة
                  // ═══════════════════════════════════════════════════════

                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),

                  // ═══════════════════════════════════════════════════════
                  // Action اختياري
                  // ═══════════════════════════════════════════════════════

                  if (hasAction) ...[
                    const SizedBox(width: 10),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: GestureDetector(
                        onTap: widget.onAction,
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            color: _color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
