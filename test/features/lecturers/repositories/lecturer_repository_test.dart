import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/lecturers/repositories/lecturer_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final helper = DatabaseHelper.instance;
    await helper.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('LecturerRepository', () {
    test('getLecturerById returns lecturer from seeded database', () async {
      final repo = LecturerRepository();

      final lecturer = await repo.getLecturerById('L001');

      expect(lecturer, isNotNull);
      expect(lecturer!.lecturerId, 'L001');
      expect(lecturer.fullName, 'Dr. Eng. Muhammad Rizki, M.T.');
      expect(lecturer.nidh, '0012058801');
      expect(lecturer.email, 'dosen@kampus.id');
      expect(lecturer.department, 'Teknologi Informasi');
    });

    test('getLecturerById returns null when lecturer not found', () async {
      final repo = LecturerRepository();

      final lecturer = await repo.getLecturerById('UNKNOWN');

      expect(lecturer, isNull);
    });

    test('getLecturerStats computes accurate offerings, credits, and unique students', () async {
      final repo = LecturerRepository();

      final stats = await repo.getLecturerStats('L001');

      // L001 has 2 course offerings (OFF001 and OFF002)
      expect(stats.courseCount, 2);
      // CS101 (3 SKS) + CS102 (3 SKS) = 6 SKS
      expect(stats.totalCredits, 6);
      // Students 2101001, 2101002, 2101003 in OFF001; 2101001, 2101004, 2101005 in OFF002 -> 5 unique students
      expect(stats.studentCount, 5);
    });

    test('getLecturerStats returns zeroes for non-existent lecturer', () async {
      final repo = LecturerRepository();

      final stats = await repo.getLecturerStats('NON_EXISTENT');

      expect(stats.courseCount, 0);
      expect(stats.totalCredits, 0);
      expect(stats.studentCount, 0);
    });
  });
}
