import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  test('DatabaseHelper uses global databaseFactory without explicit factory parameter', () async {
    final db = await DatabaseHelper.instance.initDatabase(
      path: inMemoryDatabasePath,
    );

    expect(db.isOpen, isTrue);

    // Verify seed data was inserted
    final lecturers = await db.query('lecturers');
    expect(lecturers.length, 2);
  });
}
