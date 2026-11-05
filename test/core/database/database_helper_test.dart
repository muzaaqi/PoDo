import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseHelper initializes with foreign keys and all 8 tables', () async {
    final helper = DatabaseHelper.instance;
    final db = await helper.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );

    // Verify foreign keys pragma is ON
    final pragma = await db.rawQuery('PRAGMA foreign_keys');
    expect(pragma.first.values.first, 1);

    // Verify all 8 tables exist
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    final tableNames = tables.map((row) => row['name'] as String).toSet();

    expect(tableNames, containsAll([
      'lecturers',
      'students',
      'courses',
      'course_offerings',
      'teaching_schedules',
      'course_enrollments',
      'grades',
      'seed_metadata',
    ]));

    await helper.close();
  });
}
