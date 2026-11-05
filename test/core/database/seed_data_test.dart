import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/database/seed/seed_data.dart';
import 'package:podo/core/database/seed/seed_schedules.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('SeedData populates initial demo data idempotently', () async {
    final helper = DatabaseHelper.instance;
    final db = await helper.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );

    // Initial seeding
    await SeedData.seedInitialData(db);

    // Verify records exist with expected count
    final lecturers = await db.query('lecturers');
    expect(lecturers.length, greaterThanOrEqualTo(2));

    final students = await db.query('students');
    expect(students.length, greaterThanOrEqualTo(5));

    final courses = await db.query('courses');
    expect(courses.length, greaterThanOrEqualTo(2));

    final offerings = await db.query('course_offerings');
    expect(offerings.length, greaterThanOrEqualTo(2));

    final schedules = await db.query('teaching_schedules');
    expect(schedules.length, seedSchedules.length);

    final enrollments = await db.query('course_enrollments');
    expect(enrollments.length, greaterThanOrEqualTo(3));

    final metadata = await db.query('seed_metadata', where: 'key = ?', whereArgs: ['initial_seed']);
    expect(metadata.length, 1);
    expect(metadata.first['value'], '1.0.0');

    // Run seed again to verify idempotency (no duplicate key errors, exact same counts for all tables)
    await SeedData.seedInitialData(db);

    final lecturersSecondRun = await db.query('lecturers');
    expect(lecturersSecondRun.length, lecturers.length);

    final studentsSecondRun = await db.query('students');
    expect(studentsSecondRun.length, students.length);

    final coursesSecondRun = await db.query('courses');
    expect(coursesSecondRun.length, courses.length);

    final offeringsSecondRun = await db.query('course_offerings');
    expect(offeringsSecondRun.length, offerings.length);

    final schedulesSecondRun = await db.query('teaching_schedules');
    expect(schedulesSecondRun.length, seedSchedules.length);

    final enrollmentsSecondRun = await db.query('course_enrollments');
    expect(enrollmentsSecondRun.length, enrollments.length);

    await helper.close();
  });
}
