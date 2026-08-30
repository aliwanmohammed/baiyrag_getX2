import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class NavigationHelper {
  NavigationHelper._();

  //────────────────────────────────────────────
  // Push
  //────────────────────────────────────────────

  static Future<T?> push<T>(
    BuildContext context,
    String route, {
    Object? extra,
  }) {
    return context.push<T>(route, extra: extra);
  }

  //────────────────────────────────────────────
  // Go (replace stack)
  //────────────────────────────────────────────

  static void go(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  //────────────────────────────────────────────
  // Replace one page
  //────────────────────────────────────────────

  static void replace(BuildContext context, String route, {Object? extra}) {
    context.replace(route, extra: extra);
  }

  //────────────────────────────────────────────
  // Back
  //────────────────────────────────────────────

  static void back(BuildContext context, {String? fallbackRoute}) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute ?? AppRoutes.home);
  }

  //────────────────────────────────────────────
  // Home
  //────────────────────────────────────────────

  static void home(BuildContext context) {
    context.go(AppRoutes.home);
  }

  //────────────────────────────────────────────
  // Login
  //────────────────────────────────────────────

  static void login(BuildContext context) {
    context.go(AppRoutes.login);
  }
}
