import 'package:sqflite/sqflite.dart';
import 'seed_courses.dart';
import 'seed_enrollments.dart';
import 'seed_lecturers.dart';
import 'seed_offerings.dart';
import 'seed_schedules.dart';
import 'seed_students.dart';

class SeedData {
  const SeedData._();

  static const String initialSeedVersion = '1.0.0';

  static Future<bool> isInitialSeedApplied(DatabaseExecutor db) async {
    final result = await db.query(
      'seed_metadata',
      where: 'key = ?',
      whereArgs: ['initial_seed'],
    );
    return result.isNotEmpty;
  }

  static Future<void> seedInitialData(Database db) async {
    // Check if initial seed is already applied
    if (await isInitialSeedApplied(db)) {
      return;
    }

    await db.transaction((txn) async {
      // Re-check within transaction to prevent race conditions
      if (await isInitialSeedApplied(txn)) {
        return;
      }

      final batch = txn.batch();

      // 1. Lecturers
      for (final lecturer in seedLecturers) {
        batch.insert(
          'lecturers',
          lecturer,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 2. Students
      for (final student in seedStudents) {
        batch.insert(
          'students',
          student,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 3. Courses
      for (final course in seedCourses) {
        batch.insert(
          'courses',
          course,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 4. Offerings
      for (final offering in seedOfferings) {
        batch.insert(
          'course_offerings',
          offering,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 5. Enrollments
      for (final enrollment in seedEnrollments) {
        batch.insert(
          'course_enrollments',
          enrollment,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 6. Schedules
      for (final schedule in seedSchedules) {
        batch.insert(
          'teaching_schedules',
          schedule,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 7. Seed metadata record
      batch.insert(
        'seed_metadata',
        {
          'key': 'initial_seed',
          'value': initialSeedVersion,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      await batch.commit(noResult: true);
    });
  }

  static Future<void> checkAndApplySeeds(Database db) async {
    if (!await isInitialSeedApplied(db)) {
      await seedInitialData(db);
      return;
    }
    await syncNewSeedData(db);
  }

  static Future<void> syncNewSeedData(Database db) async {
    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final lecturer in seedLecturers) {
        batch.insert(
          'lecturers',
          lecturer,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (final student in seedStudents) {
        batch.insert(
          'students',
          student,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (final course in seedCourses) {
        batch.insert(
          'courses',
          course,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (final offering in seedOfferings) {
        batch.insert(
          'course_offerings',
          offering,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (final enrollment in seedEnrollments) {
        batch.insert(
          'course_enrollments',
          enrollment,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (final schedule in seedSchedules) {
        batch.insert(
          'teaching_schedules',
          schedule,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await batch.commit(noResult: true);
    });
  }
}
