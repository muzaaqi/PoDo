import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'seed/seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase({
    String? path,
    DatabaseFactory? factory,
  }) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await getDatabasesPath(), 'podo.db');

    _database = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
      ),
    );

    return _database!;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // 1. lecturers
      await txn.execute('''
        CREATE TABLE lecturers (
          lecturer_id TEXT PRIMARY KEY,
          full_name TEXT NOT NULL,
          title TEXT,
          nidh TEXT,
          email TEXT,
          phone TEXT,
          department TEXT,
          photo_path TEXT
        )
      ''');

      // 2. students
      await txn.execute('''
        CREATE TABLE students (
          nim TEXT PRIMARY KEY,
          full_name TEXT NOT NULL,
          study_program TEXT,
          department TEXT,
          phone TEXT,
          address TEXT
        )
      ''');

      // 3. courses
      await txn.execute('''
        CREATE TABLE courses (
          course_code TEXT PRIMARY KEY,
          course_name TEXT NOT NULL,
          credits INTEGER NOT NULL
        )
      ''');

      // 4. course_offerings
      await txn.execute('''
        CREATE TABLE course_offerings (
          offering_id TEXT PRIMARY KEY,
          course_code TEXT NOT NULL,
          lecturer_id TEXT NOT NULL,
          class_name TEXT NOT NULL,
          academic_year TEXT NOT NULL,
          term TEXT NOT NULL,
          FOREIGN KEY (course_code) REFERENCES courses (course_code) ON DELETE CASCADE,
          FOREIGN KEY (lecturer_id) REFERENCES lecturers (lecturer_id) ON DELETE CASCADE
        )
      ''');

      // 5. teaching_schedules
      await txn.execute('''
        CREATE TABLE teaching_schedules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          offering_id TEXT NOT NULL,
          day_of_week TEXT NOT NULL,
          room TEXT NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          FOREIGN KEY (offering_id) REFERENCES course_offerings (offering_id) ON DELETE CASCADE
        )
      ''');

      // 6. course_enrollments
      await txn.execute('''
        CREATE TABLE course_enrollments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          offering_id TEXT NOT NULL,
          student_nim TEXT NOT NULL,
          UNIQUE(offering_id, student_nim),
          FOREIGN KEY (offering_id) REFERENCES course_offerings (offering_id) ON DELETE CASCADE,
          FOREIGN KEY (student_nim) REFERENCES students (nim) ON DELETE CASCADE
        )
      ''');

      // 7. grades
      await txn.execute('''
        CREATE TABLE grades (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          enrollment_id INTEGER NOT NULL UNIQUE,
          cpmk_1 REAL,
          cpmk_2 REAL,
          cpmk_3 REAL,
          cpmk_4 REAL,
          FOREIGN KEY (enrollment_id) REFERENCES course_enrollments (id) ON DELETE CASCADE
        )
      ''');

      // 8. seed_metadata
      await txn.execute('''
        CREATE TABLE seed_metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    });

    // Populate initial demo seed
    await SeedData.seedInitialData(db);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
