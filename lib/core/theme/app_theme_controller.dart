import 'package:flutter/material.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AppThemeController extends ValueNotifier<ThemeMode> {
  AppThemeController._() : super(ThemeMode.system);
  static final AppThemeController instance = AppThemeController._();

  bool isDarkMode(BuildContext context) {
    if (value == ThemeMode.dark) return true;
    if (value == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  Future<void> loadThemeMode() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'seed_metadata',
        where: 'key = ?',
        whereArgs: ['app_theme_mode'],
      );
      if (result.isNotEmpty) {
        final mode = result.first['value'] as String?;
        if (mode == 'dark') {
          value = ThemeMode.dark;
        } else if (mode == 'light') {
          value = ThemeMode.light;
        } else {
          value = ThemeMode.system;
        }
      }
    } catch (_) {
      // Safe fallback if database is unavailable or during headless tests
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'seed_metadata',
        {
          'key': 'app_theme_mode',
          'value': mode == ThemeMode.dark
              ? 'dark'
              : (mode == ThemeMode.light ? 'light' : 'system'),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Safe fallback if database is unavailable
    }
  }

  void toggleTheme(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
