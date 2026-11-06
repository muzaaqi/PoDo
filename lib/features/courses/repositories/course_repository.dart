import 'package:sqflite/sqflite.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/courses/models/course.dart';
import 'package:podo/features/courses/models/course_offering.dart';

class CourseRepository {
  CourseRepository._();
  static final CourseRepository instance = CourseRepository._();

  DatabaseHelper get _dbHelper => DatabaseHelper.instance;

  Future<List<CourseOffering>> getOfferingsByLecturer(
    String lecturerId, {
    String? query,
  }) async {
    final db = await _dbHelper.database;

    final trimmedQuery = query?.trim() ?? '';
    final hasQuery = trimmedQuery.isNotEmpty;

    final String sql;
    final List<dynamic> args;

    if (hasQuery) {
      final searchPattern = '%$trimmedQuery%';
      sql = '''
        SELECT 
          co.offering_id,
          co.course_code,
          co.lecturer_id,
          co.class_name,
          co.academic_year,
          co.term,
          c.course_name,
          c.credits,
          COUNT(ce.id) as enrolled_count
        FROM course_offerings co
        JOIN courses c ON co.course_code = c.course_code
        LEFT JOIN course_enrollments ce ON co.offering_id = ce.offering_id
        WHERE co.lecturer_id = ?
          AND (
            c.course_name LIKE ? 
            OR c.course_code LIKE ? 
            OR co.class_name LIKE ?
          )
        GROUP BY co.offering_id
        ORDER BY c.course_name ASC, co.class_name ASC
      ''';
      args = [lecturerId, searchPattern, searchPattern, searchPattern];
    } else {
      sql = '''
        SELECT 
          co.offering_id,
          co.course_code,
          co.lecturer_id,
          co.class_name,
          co.academic_year,
          co.term,
          c.course_name,
          c.credits,
          COUNT(ce.id) as enrolled_count
        FROM course_offerings co
        JOIN courses c ON co.course_code = c.course_code
        LEFT JOIN course_enrollments ce ON co.offering_id = ce.offering_id
        WHERE co.lecturer_id = ?
        GROUP BY co.offering_id
        ORDER BY c.course_name ASC, co.class_name ASC
      ''';
      args = [lecturerId];
    }

    final results = await db.rawQuery(sql, args);
    return results.map((map) => CourseOffering.fromMap(map)).toList();
  }

  Future<CourseOffering?> getOfferingById(String offeringId) async {
    final db = await _dbHelper.database;
    const sql = '''
      SELECT 
        co.offering_id,
        co.course_code,
        co.lecturer_id,
        co.class_name,
        co.academic_year,
        co.term,
        c.course_name,
        c.credits,
        COUNT(ce.id) as enrolled_count
      FROM course_offerings co
      JOIN courses c ON co.course_code = c.course_code
      LEFT JOIN course_enrollments ce ON co.offering_id = ce.offering_id
      WHERE co.offering_id = ?
      GROUP BY co.offering_id
    ''';
    final results = await db.rawQuery(sql, [offeringId]);
    if (results.isEmpty) return null;
    return CourseOffering.fromMap(results.first);
  }

  Future<List<Course>> getAllCourses() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'courses',
      orderBy: 'course_code ASC',
    );
    return results.map((map) => Course.fromMap(map)).toList();
  }

  Future<Course?> getCourseByCode(String courseCode) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'courses',
      where: 'course_code = ?',
      whereArgs: [courseCode],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Course.fromMap(results.first);
  }

  Future<void> createCourse(Course course) async {
    final db = await _dbHelper.database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> createOffering(CourseOffering offering) async {
    final db = await _dbHelper.database;
    await db.insert(
      'course_offerings',
      {
        'offering_id': offering.offeringId,
        'course_code': offering.courseCode,
        'lecturer_id': offering.lecturerId,
        'class_name': offering.className,
        'academic_year': offering.academicYear,
        'term': offering.term,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateOffering(CourseOffering offering) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_offerings',
      {
        'course_code': offering.courseCode,
        'class_name': offering.className,
        'academic_year': offering.academicYear,
        'term': offering.term,
      },
      where: 'offering_id = ?',
      whereArgs: [offering.offeringId],
    );
  }

  Future<void> deleteOffering(String offeringId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_offerings',
      where: 'offering_id = ?',
      whereArgs: [offeringId],
    );
  }
}
