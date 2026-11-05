import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/grades/models/enrolled_student.dart';
import 'package:podo/features/grades/models/grade.dart';

void main() {
  group('EnrolledStudent Model', () {
    test('instantiates with given properties', () {
      const student = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Dahlan',
        studyProgram: 'Teknik Informatika',
        grade: Grade(
          id: 1,
          enrollmentId: 1,
          cpmk1: 85.0,
          cpmk2: 90.0,
          cpmk3: 75.0,
          cpmk4: 80.0,
        ),
      );

      expect(student.enrollmentId, 1);
      expect(student.offeringId, 'OFF001');
      expect(student.studentNim, '2101001');
      expect(student.studentName, 'Ahmad Dahlan');
      expect(student.studyProgram, 'Teknik Informatika');
      expect(student.isGraded, isTrue);
      expect(student.averageScore, 82.5);
    });

    test('isGraded returns false when grade is null', () {
      const student = EnrolledStudent(
        enrollmentId: 2,
        offeringId: 'OFF001',
        studentNim: '2101002',
        studentName: 'Siti Aisyah',
      );

      expect(student.isGraded, isFalse);
      expect(student.grade, isNull);
      expect(student.averageScore, isNull);
    });

    test('fromMap parses map representation with joined grade columns', () {
      final mapWithGrade = {
        'enrollment_id': 1,
        'offering_id': 'OFF001',
        'student_nim': '2101001',
        'student_name': 'Ahmad Dahlan',
        'study_program': 'Teknik Informatika',
        'grade_id': 10,
        'cpmk_1': 88.0,
        'cpmk_2': 92.0,
        'cpmk_3': 85.0,
        'cpmk_4': 90.0,
      };

      final student = EnrolledStudent.fromMap(mapWithGrade);

      expect(student.enrollmentId, 1);
      expect(student.offeringId, 'OFF001');
      expect(student.studentNim, '2101001');
      expect(student.studentName, 'Ahmad Dahlan');
      expect(student.studyProgram, 'Teknik Informatika');
      expect(student.grade, isNotNull);
      expect(student.grade!.id, 10);
      expect(student.grade!.cpmk1, 88.0);
      expect(student.isGraded, isTrue);
      expect(student.averageScore, 88.75);
    });

    test('fromMap parses map representation without grade columns', () {
      final mapWithoutGrade = {
        'enrollment_id': 2,
        'offering_id': 'OFF001',
        'student_nim': '2101002',
        'student_name': 'Siti Aisyah',
        'study_program': 'Teknik Informatika',
        'grade_id': null,
        'cpmk_1': null,
        'cpmk_2': null,
        'cpmk_3': null,
        'cpmk_4': null,
      };

      final student = EnrolledStudent.fromMap(mapWithoutGrade);

      expect(student.enrollmentId, 2);
      expect(student.grade, isNull);
      expect(student.isGraded, isFalse);
    });

    test('toMap converts entity back to map representation', () {
      const student = EnrolledStudent(
        enrollmentId: 3,
        offeringId: 'OFF002',
        studentNim: '2101003',
        studentName: 'Budi Santoso',
        studyProgram: 'Sistem Informasi',
      );

      final map = student.toMap();

      expect(map['enrollment_id'], 3);
      expect(map['offering_id'], 'OFF002');
      expect(map['student_nim'], '2101003');
      expect(map['student_name'], 'Budi Santoso');
      expect(map['study_program'], 'Sistem Informasi');
    });

    test('copyWith and equality work properly', () {
      const s1 = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Dahlan',
      );
      const s2 = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Dahlan',
      );

      final updated = s1.copyWith(studentName: 'Ahmad Dahlan, S.Kom.');

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(updated.studentName, 'Ahmad Dahlan, S.Kom.');
      expect(updated, isNot(equals(s1)));
    });
  });
}
