import 'package:sqflite/sqflite.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/grades/models/grade.dart';

class GradeRepository {
  GradeRepository._();
  static final GradeRepository instance = GradeRepository._();

  DatabaseHelper get _dbHelper => DatabaseHelper.instance;

  Future<Grade?> getGradeByEnrollmentId(int enrollmentId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'grades',
      where: 'enrollment_id = ?',
      whereArgs: [enrollmentId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Grade.fromMap(results.first);
  }

  Future<void> upsertGrade(Grade grade) async {
    final db = await _dbHelper.database;

    final existing = await db.query(
      'grades',
      columns: ['id'],
      where: 'enrollment_id = ?',
      whereArgs: [grade.enrollmentId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      await db.update(
        'grades',
        {
          'cpmk_1': grade.cpmk1,
          'cpmk_2': grade.cpmk2,
          'cpmk_3': grade.cpmk3,
          'cpmk_4': grade.cpmk4,
        },
        where: 'enrollment_id = ?',
        whereArgs: [grade.enrollmentId],
      );
    } else {
      await db.insert(
        'grades',
        grade.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteGrade(int enrollmentId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'grades',
      where: 'enrollment_id = ?',
      whereArgs: [enrollmentId],
    );
  }
}
