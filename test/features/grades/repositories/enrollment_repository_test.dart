import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/grades/repositories/enrollment_repository.dart';

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

  group('EnrollmentRepository', () {
    test('getEnrolledStudentsByOffering returns enrolled students with join data for OFF001', () async {
      final students = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF001');

      expect(students.length, 3);

      // Ordered by student_name ASC: Ahmad Fauzi, Budi Santoso, Citra Dewi
      expect(students[0].studentName, 'Ahmad Fauzi');
      expect(students[0].studentNim, '2101001');
      expect(students[0].offeringId, 'OFF001');
      expect(students[0].isGraded, isFalse);
      expect(students[0].grade, isNull);

      expect(students[1].studentName, 'Budi Santoso');
      expect(students[1].studentNim, '2101002');
      expect(students[1].isGraded, isFalse);

      expect(students[2].studentName, 'Citra Dewi');
      expect(students[2].studentNim, '2101003');
      expect(students[2].isGraded, isFalse);
    });

    test('getEnrolledStudentsByOffering returns enrolled student for OFF003', () async {
      final students = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF003');

      expect(students.length, 1);
      expect(students.first.studentNim, '2101005');
      expect(students.first.studentName, 'Eko Prasetyo');
    });

    test('getEnrolledStudentsByOffering returns empty list for offering without enrollments', () async {
      final students = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('NON_EXISTENT');
      expect(students, isEmpty);
    });

    test('getEnrolledStudentById returns specific enrolled student with details', () async {
      final student = await EnrollmentRepository.instance.getEnrolledStudentById(1);

      expect(student, isNotNull);
      expect(student!.enrollmentId, 1);
      expect(student.offeringId, 'OFF001');
      expect(student.studentNim, '2101001');
      expect(student.studentName, 'Ahmad Fauzi');

      final notFound = await EnrollmentRepository.instance.getEnrolledStudentById(9999);
      expect(notFound, isNull);
    });

    test('enrollStudent adds new student to offering and unenrollStudent removes it', () async {
      // Dewi Lestari (2101004) is not in OFF001
      var students = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF001');
      expect(students.any((s) => s.studentNim == '2101004'), isFalse);

      final newEnrollmentId = await EnrollmentRepository.instance.enrollStudent(
        offeringId: 'OFF001',
        studentNim: '2101004',
      );
      expect(newEnrollmentId, isPositive);

      students = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF001');
      expect(students.length, 4);
      expect(students.any((s) => s.studentNim == '2101004'), isTrue);

      // Attempting to enroll duplicate throws exception
      expect(
        () => EnrollmentRepository.instance.enrollStudent(
          offeringId: 'OFF001',
          studentNim: '2101004',
        ),
        throwsA(isA<Exception>()),
      );

      // Unenroll
      await EnrollmentRepository.instance.unenrollStudent(
        offeringId: 'OFF001',
        studentNim: '2101004',
      );
      students = await EnrollmentRepository.instance.getEnrolledStudentsByOffering('OFF001');
      expect(students.length, 3);
      expect(students.any((s) => s.studentNim == '2101004'), isFalse);
    });
  });
}
