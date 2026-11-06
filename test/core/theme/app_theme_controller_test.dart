import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final helper = DatabaseHelper.instance;
    await helper.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    AppThemeController.instance.value = ThemeMode.system;
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    AppThemeController.instance.value = ThemeMode.system;
  });

  test('setThemeMode updates controller value and persists to SQLite', () async {
    final controller = AppThemeController.instance;

    await controller.setThemeMode(ThemeMode.dark);
    expect(controller.value, ThemeMode.dark);

    final db = await DatabaseHelper.instance.database;
    var rows = await db.query(
      'seed_metadata',
      where: 'key = ?',
      whereArgs: ['app_theme_mode'],
    );
    expect(rows.length, 1);
    expect(rows.first['value'], 'dark');

    await controller.setThemeMode(ThemeMode.light);
    expect(controller.value, ThemeMode.light);

    rows = await db.query(
      'seed_metadata',
      where: 'key = ?',
      whereArgs: ['app_theme_mode'],
    );
    expect(rows.length, 1);
    expect(rows.first['value'], 'light');
  });

  test('toggleTheme switches between dark and light', () async {
    final controller = AppThemeController.instance;

    controller.toggleTheme(true);
    expect(controller.value, ThemeMode.dark);

    controller.toggleTheme(false);
    expect(controller.value, ThemeMode.light);
  });

  test('loadThemeMode restores saved theme mode from SQLite', () async {
    final controller = AppThemeController.instance;
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'seed_metadata',
      {'key': 'app_theme_mode', 'value': 'dark'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    controller.value = ThemeMode.system;
    await controller.loadThemeMode();
    expect(controller.value, ThemeMode.dark);
  });
}
