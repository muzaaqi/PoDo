import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/courses/models/course_offering.dart';

void main() {
  group('CourseOffering Model', () {
    const sampleMap = <String, dynamic>{
      'offering_id': 'OFF001',
      'course_code': 'IF101',
      'lecturer_id': 'L001',
      'class_name': 'IF-44-01',
      'academic_year': '2024/2025',
      'term': 'Ganjil',
      'course_name': 'Pemrograman Mobile',
      'credits': 3,
      'enrolled_count': 3,
    };

    const sampleOffering = CourseOffering(
      offeringId: 'OFF001',
      courseCode: 'IF101',
      lecturerId: 'L001',
      className: 'IF-44-01',
      academicYear: '2024/2025',
      term: 'Ganjil',
      courseName: 'Pemrograman Mobile',
      credits: 3,
      enrolledCount: 3,
    );

    test('instantiates with given properties', () {
      expect(sampleOffering.offeringId, 'OFF001');
      expect(sampleOffering.courseCode, 'IF101');
      expect(sampleOffering.lecturerId, 'L001');
      expect(sampleOffering.className, 'IF-44-01');
      expect(sampleOffering.academicYear, '2024/2025');
      expect(sampleOffering.term, 'Ganjil');
      expect(sampleOffering.courseName, 'Pemrograman Mobile');
      expect(sampleOffering.credits, 3);
      expect(sampleOffering.enrolledCount, 3);
    });

    test('fromMap parses map including relational fields correctly', () {
      final offering = CourseOffering.fromMap(sampleMap);
      expect(offering.offeringId, 'OFF001');
      expect(offering.courseCode, 'IF101');
      expect(offering.lecturerId, 'L001');
      expect(offering.className, 'IF-44-01');
      expect(offering.academicYear, '2024/2025');
      expect(offering.term, 'Ganjil');
      expect(offering.courseName, 'Pemrograman Mobile');
      expect(offering.credits, 3);
      expect(offering.enrolledCount, 3);
    });

    test('toMap converts entity back to map representation', () {
      final map = sampleOffering.toMap();
      expect(map['offering_id'], 'OFF001');
      expect(map['course_code'], 'IF101');
      expect(map['lecturer_id'], 'L001');
      expect(map['class_name'], 'IF-44-01');
      expect(map['academic_year'], '2024/2025');
      expect(map['term'], 'Ganjil');
      expect(map['course_name'], 'Pemrograman Mobile');
      expect(map['credits'], 3);
      expect(map['enrolled_count'], 3);
    });

    test('copyWith updates properties properly', () {
      final updated = sampleOffering.copyWith(
        className: 'IF-44-03',
        enrolledCount: 4,
      );
      expect(updated.offeringId, sampleOffering.offeringId);
      expect(updated.className, 'IF-44-03');
      expect(updated.enrolledCount, 4);
      expect(updated.courseName, sampleOffering.courseName);
    });

    test('equality and hashCode work properly', () {
      final duplicate = CourseOffering.fromMap(sampleMap);
      expect(sampleOffering, equals(duplicate));
      expect(sampleOffering.hashCode, equals(duplicate.hashCode));

      final different = sampleOffering.copyWith(enrolledCount: 0);
      expect(sampleOffering, isNot(equals(different)));
    });
  });
}
