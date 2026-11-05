import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';

class ScheduleRepository {
  ScheduleRepository._();
  static final ScheduleRepository instance = ScheduleRepository._();

  Future<List<TeachingSchedule>> getSchedulesByLecturer(
    String lecturerId, {
    String? dayOfWeek,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final String whereClause;
    final List<dynamic> whereArgs;

    if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
      whereClause = 'WHERE co.lecturer_id = ? AND ts.day_of_week = ?';
      whereArgs = [lecturerId, dayOfWeek];
    } else {
      whereClause = 'WHERE co.lecturer_id = ?';
      whereArgs = [lecturerId];
    }

    final sql = '''
      SELECT 
        ts.id,
        ts.offering_id,
        ts.day_of_week,
        ts.room,
        ts.start_time,
        ts.end_time,
        co.class_name,
        co.academic_year,
        co.term,
        c.course_code,
        c.course_name,
        c.credits
      FROM teaching_schedules ts
      JOIN course_offerings co ON ts.offering_id = co.offering_id
      JOIN courses c ON co.course_code = c.course_code
      $whereClause
      ORDER BY 
        CASE ts.day_of_week
          WHEN 'Senin' THEN 1
          WHEN 'Selasa' THEN 2
          WHEN 'Rabu' THEN 3
          WHEN 'Kamis' THEN 4
          WHEN 'Jumat' THEN 5
          WHEN 'Sabtu' THEN 6
          ELSE 7
        END,
        ts.start_time ASC
    ''';

    final results = await db.rawQuery(sql, whereArgs);
    return results.map((row) => TeachingSchedule.fromMap(row)).toList();
  }

  Future<TeachingSchedule?> getScheduleById(int id) async {
    final db = await DatabaseHelper.instance.database;

    final sql = '''
      SELECT 
        ts.id,
        ts.offering_id,
        ts.day_of_week,
        ts.room,
        ts.start_time,
        ts.end_time,
        co.class_name,
        co.academic_year,
        co.term,
        c.course_code,
        c.course_name,
        c.credits
      FROM teaching_schedules ts
      JOIN course_offerings co ON ts.offering_id = co.offering_id
      JOIN courses c ON co.course_code = c.course_code
      WHERE ts.id = ?
      LIMIT 1
    ''';

    final results = await db.rawQuery(sql, [id]);
    if (results.isEmpty) return null;
    return TeachingSchedule.fromMap(results.first);
  }
}
