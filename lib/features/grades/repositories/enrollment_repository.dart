import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/grades/models/enrolled_student.dart';

class EnrollmentRepository {
  EnrollmentRepository._();
  static final EnrollmentRepository instance = EnrollmentRepository._();

  DatabaseHelper get _dbHelper => DatabaseHelper.instance;

  Future<List<EnrolledStudent>> getEnrolledStudentsByOffering(String offeringId) async {
    final db = await _dbHelper.database;
    const sql = '''
      SELECT 
        ce.id as enrollment_id,
        ce.offering_id,
        ce.student_nim,
        s.full_name as student_name,
        s.study_program,
        g.id as grade_id,
        g.cpmk_1,
        g.cpmk_2,
        g.cpmk_3,
        g.cpmk_4
      FROM course_enrollments ce
      JOIN students s ON ce.student_nim = s.nim
      LEFT JOIN grades g ON ce.id = g.enrollment_id
      WHERE ce.offering_id = ?
      ORDER BY s.full_name ASC
    ''';

    final results = await db.rawQuery(sql, [offeringId]);
    return results.map((map) => EnrolledStudent.fromMap(map)).toList();
  }

  Future<EnrolledStudent?> getEnrolledStudentById(int enrollmentId) async {
    final db = await _dbHelper.database;
    const sql = '''
      SELECT 
        ce.id as enrollment_id,
        ce.offering_id,
        ce.student_nim,
        s.full_name as student_name,
        s.study_program,
        g.id as grade_id,
        g.cpmk_1,
        g.cpmk_2,
        g.cpmk_3,
        g.cpmk_4
      FROM course_enrollments ce
      JOIN students s ON ce.student_nim = s.nim
      LEFT JOIN grades g ON ce.id = g.enrollment_id
      WHERE ce.id = ?
      LIMIT 1
    ''';

    final results = await db.rawQuery(sql, [enrollmentId]);
    if (results.isEmpty) return null;
    return EnrolledStudent.fromMap(results.first);
  }

  Future<int> enrollStudent({
    required String offeringId,
    required String studentNim,
  }) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'course_enrollments',
      where: 'offering_id = ? AND student_nim = ?',
      whereArgs: [offeringId, studentNim],
    );
    if (existing.isNotEmpty) {
      throw Exception('Mahasiswa dengan NIM $studentNim sudah terdaftar di kelas ini.');
    }
    return await db.insert(
      'course_enrollments',
      {
        'offering_id': offeringId,
        'student_nim': studentNim,
      },
    );
  }

  Future<void> unenrollStudent({
    required String offeringId,
    required String studentNim,
  }) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_enrollments',
      where: 'offering_id = ? AND student_nim = ?',
      whereArgs: [offeringId, studentNim],
    );
  }

  Future<void> unenrollStudentById(int enrollmentId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_enrollments',
      where: 'id = ?',
      whereArgs: [enrollmentId],
    );
  }
}
