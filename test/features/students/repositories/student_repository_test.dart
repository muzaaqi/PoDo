import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/repositories/student_repository.dart';

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

  group('StudentRepository', () {
    test('getAllStudents returns seeded students sorted by NIM', () async {
      final repo = StudentRepository();
      final students = await repo.getAllStudents();

      expect(students.length, 5);
      expect(students.first.nim, '2101001');
      expect(students.first.fullName, 'Ahmad Fauzi');
    });

    test('getAllStudents with query filters by name or NIM case-insensitively', () async {
      final repo = StudentRepository();

      final byName = await repo.getAllStudents(query: 'fauzi');
      expect(byName.length, 1);
      expect(byName.first.nim, '2101001');

      final byNim = await repo.getAllStudents(query: '2101003');
      expect(byNim.length, 1);
      expect(byNim.first.fullName, 'Citra Dewi');

      final notFound = await repo.getAllStudents(query: 'ZzzZzzZ');
      expect(notFound, isEmpty);
    });

    test('getStudentByNim returns student or null', () async {
      final repo = StudentRepository();

      final student = await repo.getStudentByNim('2101002');
      expect(student, isNotNull);
      expect(student!.fullName, 'Budi Santoso');

      final notFound = await repo.getStudentByNim('9999999');
      expect(notFound, isNull);
    });

    test('isNimExists correctly detects presence of NIM', () async {
      final repo = StudentRepository();

      expect(await repo.isNimExists('2101001'), isTrue);
      expect(await repo.isNimExists('9999999'), isFalse);
    });

    test('createStudent inserts student and throws if NIM already exists', () async {
      final repo = StudentRepository();

      const newStudent = Student(
        nim: '2101099',
        fullName: 'Fajar Nugraha',
        studyProgram: 'Teknik Informatika',
        department: 'Teknologi Informasi',
        phone: '081299998888',
        address: 'Jl. Surya Sumantri',
      );

      await repo.createStudent(newStudent);

      final fetched = await repo.getStudentByNim('2101099');
      expect(fetched, isNotNull);
      expect(fetched!.fullName, 'Fajar Nugraha');

      // Attempt duplicate NIM
      expect(
        () async => await repo.createStudent(newStudent),
        throwsA(isA<Exception>()),
      );
    });

    test('updateStudent modifies student record in database', () async {
      final repo = StudentRepository();

      final student = await repo.getStudentByNim('2101001');
      expect(student, isNotNull);

      final updated = student!.copyWith(
        fullName: 'Ahmad Fauzi, S.T.',
        phone: '081299990000',
        address: 'Jl. Dago No. 100',
      );

      await repo.updateStudent(updated);

      final refreshed = await repo.getStudentByNim('2101001');
      expect(refreshed!.fullName, 'Ahmad Fauzi, S.T.');
      expect(refreshed.phone, '081299990000');
      expect(refreshed.address, 'Jl. Dago No. 100');
    });

    test('deleteStudent removes record from database', () async {
      final repo = StudentRepository();

      expect(await repo.isNimExists('2101005'), isTrue);

      await repo.deleteStudent('2101005');

      expect(await repo.isNimExists('2101005'), isFalse);
      expect(await repo.getStudentByNim('2101005'), isNull);
    });
  });
}
