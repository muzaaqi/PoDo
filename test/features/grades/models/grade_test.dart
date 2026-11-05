import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/grades/models/grade.dart';

void main() {
  group('Grade Model', () {
    test('instantiates with given properties', () {
      const grade = Grade(
        id: 1,
        enrollmentId: 10,
        cpmk1: 85.0,
        cpmk2: 90.0,
        cpmk3: 78.5,
        cpmk4: 88.0,
      );

      expect(grade.id, 1);
      expect(grade.enrollmentId, 10);
      expect(grade.cpmk1, 85.0);
      expect(grade.cpmk2, 90.0);
      expect(grade.cpmk3, 78.5);
      expect(grade.cpmk4, 88.0);
      expect(grade.isFullyGraded, isTrue);
      expect(grade.averageScore, closeTo(85.375, 0.001));
    });

    test('isFullyGraded returns false if any CPMK is null', () {
      const partialGrade = Grade(
        enrollmentId: 10,
        cpmk1: 80.0,
        cpmk2: null,
        cpmk3: 70.0,
        cpmk4: 90.0,
      );

      expect(partialGrade.isFullyGraded, isFalse);
      expect(partialGrade.averageScore, closeTo(80.0, 0.001));
    });

    test('averageScore returns null if all CPMK are null', () {
      const emptyGrade = Grade(
        enrollmentId: 10,
      );

      expect(emptyGrade.isFullyGraded, isFalse);
      expect(emptyGrade.averageScore, isNull);
    });

    test('fromMap parses map representation correctly', () {
      final map = {
        'id': 2,
        'enrollment_id': 15,
        'cpmk_1': 80.0,
        'cpmk_2': 85.5,
        'cpmk_3': 90.0,
        'cpmk_4': 95.0,
      };

      final grade = Grade.fromMap(map);

      expect(grade.id, 2);
      expect(grade.enrollmentId, 15);
      expect(grade.cpmk1, 80.0);
      expect(grade.cpmk2, 85.5);
      expect(grade.cpmk3, 90.0);
      expect(grade.cpmk4, 95.0);
    });

    test('toMap converts entity back to map representation', () {
      const grade = Grade(
        id: 3,
        enrollmentId: 20,
        cpmk1: 75.0,
        cpmk2: 80.0,
        cpmk3: 85.0,
        cpmk4: 90.0,
      );

      final map = grade.toMap();

      expect(map['id'], 3);
      expect(map['enrollment_id'], 20);
      expect(map['cpmk_1'], 75.0);
      expect(map['cpmk_2'], 80.0);
      expect(map['cpmk_3'], 85.0);
      expect(map['cpmk_4'], 90.0);
    });

    test('copyWith updates properties properly', () {
      const grade = Grade(
        id: 1,
        enrollmentId: 10,
        cpmk1: 70.0,
        cpmk2: 70.0,
        cpmk3: 70.0,
        cpmk4: 70.0,
      );

      final updated = grade.copyWith(cpmk1: 95.0, cpmk4: 100.0);

      expect(updated.id, 1);
      expect(updated.enrollmentId, 10);
      expect(updated.cpmk1, 95.0);
      expect(updated.cpmk2, 70.0);
      expect(updated.cpmk3, 70.0);
      expect(updated.cpmk4, 100.0);
    });

    test('equality and hashCode work properly', () {
      const grade1 = Grade(
        id: 1,
        enrollmentId: 10,
        cpmk1: 80.0,
        cpmk2: 85.0,
        cpmk3: 90.0,
        cpmk4: 95.0,
      );
      const grade2 = Grade(
        id: 1,
        enrollmentId: 10,
        cpmk1: 80.0,
        cpmk2: 85.0,
        cpmk3: 90.0,
        cpmk4: 95.0,
      );
      const grade3 = Grade(
        id: 1,
        enrollmentId: 10,
        cpmk1: 70.0,
        cpmk2: 85.0,
        cpmk3: 90.0,
        cpmk4: 95.0,
      );

      expect(grade1, equals(grade2));
      expect(grade1.hashCode, equals(grade2.hashCode));
      expect(grade1, isNot(equals(grade3)));
    });
  });
}
