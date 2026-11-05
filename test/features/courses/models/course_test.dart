import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/courses/models/course.dart';

void main() {
  group('Course Model', () {
    const sampleMap = <String, dynamic>{
      'course_code': 'IF101',
      'course_name': 'Pemrograman Mobile',
      'credits': 3,
    };

    const sampleCourse = Course(
      courseCode: 'IF101',
      courseName: 'Pemrograman Mobile',
      credits: 3,
    );

    test('instantiates with given properties', () {
      expect(sampleCourse.courseCode, 'IF101');
      expect(sampleCourse.courseName, 'Pemrograman Mobile');
      expect(sampleCourse.credits, 3);
    });

    test('fromMap parses map correctly', () {
      final course = Course.fromMap(sampleMap);
      expect(course.courseCode, 'IF101');
      expect(course.courseName, 'Pemrograman Mobile');
      expect(course.credits, 3);
    });

    test('toMap converts entity back to map representation', () {
      final map = sampleCourse.toMap();
      expect(map['course_code'], 'IF101');
      expect(map['course_name'], 'Pemrograman Mobile');
      expect(map['credits'], 3);
    });

    test('copyWith updates properties properly', () {
      final updated = sampleCourse.copyWith(
        courseName: 'Pemrograman Piranti Bergerak',
        credits: 4,
      );
      expect(updated.courseCode, sampleCourse.courseCode);
      expect(updated.courseName, 'Pemrograman Piranti Bergerak');
      expect(updated.credits, 4);
    });

    test('equality and hashCode work properly', () {
      final duplicate = Course.fromMap(sampleMap);
      expect(sampleCourse, equals(duplicate));
      expect(sampleCourse.hashCode, equals(duplicate.hashCode));

      final different = sampleCourse.copyWith(credits: 2);
      expect(sampleCourse, isNot(equals(different)));
    });
  });
}
