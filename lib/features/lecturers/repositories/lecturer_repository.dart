import 'package:sqflite/sqflite.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/models/lecturer_stats.dart';

class LecturerRepository {
  static final LecturerRepository instance = LecturerRepository();

  DatabaseHelper get _databaseHelper => DatabaseHelper.instance;

  Future<Lecturer?> getLecturerById(String lecturerId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'lecturers',
      where: 'lecturer_id = ?',
      whereArgs: [lecturerId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Lecturer.fromMap(results.first);
  }

  Future<LecturerStats> getLecturerStats(String lecturerId) async {
    final db = await _databaseHelper.database;

    // 1. Offerings count
    final offeringsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM course_offerings WHERE lecturer_id = ?',
      [lecturerId],
    );
    final courseCount = Sqflite.firstIntValue(offeringsResult) ?? 0;

    // 2. Total credits
    final creditsResult = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(c.credits), 0) as total_credits
      FROM course_offerings o
      JOIN courses c ON o.course_code = c.course_code
      WHERE o.lecturer_id = ?
      ''',
      [lecturerId],
    );
    final totalCredits = Sqflite.firstIntValue(creditsResult) ?? 0;

    // 3. Unique enrolled students count
    final studentsResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT e.student_nim) as count
      FROM course_enrollments e
      JOIN course_offerings o ON e.offering_id = o.offering_id
      WHERE o.lecturer_id = ?
      ''',
      [lecturerId],
    );
    final studentCount = Sqflite.firstIntValue(studentsResult) ?? 0;

    return LecturerStats(
      courseCount: courseCount,
      totalCredits: totalCredits,
      studentCount: studentCount,
    );
  }
}
