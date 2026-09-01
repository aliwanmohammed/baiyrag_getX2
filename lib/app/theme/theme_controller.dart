import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/secure_storage_service.dart';

/// Owns the application theme and persists the user's choice.
class ThemeController extends GetxController {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final dark = await SecureStorageService.instance.readTheme();
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    update();
  }

  Future<void> toggleTheme() async {
    await setDark(!isDark);
  }

  Future<void> setDark(bool value) async {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    await SecureStorageService.instance.saveTheme(value);
    update();
  }
}
