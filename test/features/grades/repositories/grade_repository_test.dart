import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/grades/models/grade.dart';
import 'package:podo/features/grades/repositories/enrollment_repository.dart';
import 'package:podo/features/grades/repositories/grade_repository.dart';

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

  group('GradeRepository', () {
    test('upsertGrade inserts new grade and getGradeByEnrollmentId retrieves it', () async {
      // Check initially no grade
      final initialGrade = await GradeRepository.instance.getGradeByEnrollmentId(1);
      expect(initialGrade, isNull);

      // Upsert new grade
      const newGrade = Grade(
        enrollmentId: 1,
        cpmk1: 85.0,
        cpmk2: 90.0,
        cpmk3: 78.0,
        cpmk4: 88.0,
      );
      await GradeRepository.instance.upsertGrade(newGrade);

      // Verify retrieved
      final retrieved = await GradeRepository.instance.getGradeByEnrollmentId(1);
      expect(retrieved, isNotNull);
      expect(retrieved!.enrollmentId, 1);
      expect(retrieved.cpmk1, 85.0);
      expect(retrieved.cpmk2, 90.0);
      expect(retrieved.cpmk3, 78.0);
      expect(retrieved.cpmk4, 88.0);
      expect(retrieved.isFullyGraded, isTrue);
    });

    test('upsertGrade updates existing grade without duplicating records', () async {
      const initialGrade = Grade(
        enrollmentId: 2,
        cpmk1: 70.0,
        cpmk2: 75.0,
        cpmk3: 80.0,
        cpmk4: 85.0,
      );
      await GradeRepository.instance.upsertGrade(initialGrade);

      // Update CPMK 1 to 95.0
      const updatedGrade = Grade(
        enrollmentId: 2,
        cpmk1: 95.0,
        cpmk2: 75.0,
        cpmk3: 80.0,
        cpmk4: 85.0,
      );
      await GradeRepository.instance.upsertGrade(updatedGrade);

      final retrieved = await GradeRepository.instance.getGradeByEnrollmentId(2);
      expect(retrieved, isNotNull);
      expect(retrieved!.cpmk1, 95.0);

      // Verify no duplicate in database
      final db = await DatabaseHelper.instance.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM grades WHERE enrollment_id = 2'),
      );
      expect(count, 1);
    });

    test('EnrollmentRepository reflects upserted grades in getEnrolledStudentsByOffering', () async {
      // 1. Initial state: OFF001 students are not graded
      final before = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF001');
      expect(before.firstWhere((s) => s.studentNim == '2101001').isGraded, isFalse);

      // 2. Insert grade for enrollment_id 1 (Ahmad Dahlan, 2101001)
      const grade = Grade(
        enrollmentId: 1,
        cpmk1: 85.0,
        cpmk2: 90.0,
        cpmk3: 80.0,
        cpmk4: 88.0,
      );
      await GradeRepository.instance.upsertGrade(grade);

      // 3. After upsert: Ahmad Dahlan is now marked as isGraded = true
      final after = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF001');
      final ahmad = after.firstWhere((s) => s.studentNim == '2101001');
      expect(ahmad.isGraded, isTrue);
      expect(ahmad.grade, isNotNull);
      expect(ahmad.grade!.cpmk1, 85.0);
      expect(ahmad.averageScore, closeTo(85.75, 0.01));

      // Other students remain un-graded
      final budi = after.firstWhere((s) => s.studentNim == '2101003');
      expect(budi.isGraded, isFalse);
    });

    test('deleteGrade removes grade record', () async {
      const grade = Grade(
        enrollmentId: 3,
        cpmk1: 80.0,
        cpmk2: 80.0,
        cpmk3: 80.0,
        cpmk4: 80.0,
      );
      await GradeRepository.instance.upsertGrade(grade);
      expect(await GradeRepository.instance.getGradeByEnrollmentId(3), isNotNull);

      await GradeRepository.instance.deleteGrade(3);
      expect(await GradeRepository.instance.getGradeByEnrollmentId(3), isNull);
    });
  });
}
