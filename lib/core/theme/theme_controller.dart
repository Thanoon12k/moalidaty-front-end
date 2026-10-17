import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light / dark / system theme choice, remembered across launches.
class ThemeController extends GetxService {
  static const _key = 'theme_mode';

  final mode = ThemeMode.system.obs;

  Future<ThemeController> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      mode.value = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      // Preferences unavailable: keep following the system theme.
    }
    return this;
  }

  Future<void> setMode(ThemeMode value) async {
    mode.value = value;
    Get.changeThemeMode(value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, value.name);
    } catch (_) {}
  }
}
