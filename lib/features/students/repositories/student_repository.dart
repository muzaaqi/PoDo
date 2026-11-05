import 'package:sqflite/sqflite.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/students/models/student.dart';

class StudentRepository {
  static final StudentRepository instance = StudentRepository();

  DatabaseHelper get _databaseHelper => DatabaseHelper.instance;

  Future<List<Student>> getAllStudents({String? query}) async {
    final db = await _databaseHelper.database;
    List<Map<String, dynamic>> results;

    if (query != null && query.trim().isNotEmpty) {
      final sanitized = '%${query.trim()}%';
      results = await db.query(
        'students',
        where: 'nim LIKE ? OR full_name LIKE ?',
        whereArgs: [sanitized, sanitized],
        orderBy: 'nim ASC',
      );
    } else {
      results = await db.query(
        'students',
        orderBy: 'nim ASC',
      );
    }

    return results.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudentByNim(String nim) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'students',
      where: 'nim = ?',
      whereArgs: [nim.trim()],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Student.fromMap(results.first);
  }

  Future<bool> isNimExists(String nim) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'students',
      columns: ['nim'],
      where: 'nim = ?',
      whereArgs: [nim.trim()],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  Future<void> createStudent(Student student) async {
    final db = await _databaseHelper.database;
    final exists = await isNimExists(student.nim);
    if (exists) {
      throw Exception('Mahasiswa dengan NIM ${student.nim} sudah terdaftar.');
    }

    await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateStudent(Student student) async {
    final db = await _databaseHelper.database;
    final count = await db.update(
      'students',
      student.toMap(),
      where: 'nim = ?',
      whereArgs: [student.nim.trim()],
    );
    if (count == 0) {
      throw Exception('Mahasiswa dengan NIM ${student.nim} tidak ditemukan.');
    }
  }

  Future<void> deleteStudent(String nim) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'students',
      where: 'nim = ?',
      whereArgs: [nim.trim()],
    );
  }
}
