import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';

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

  group('CourseRepository', () {
    test('getOfferingsByLecturer returns all offerings for L001 with correct join fields and enrolled count', () async {
      final offerings = await CourseRepository.instance.getOfferingsByLecturer('L001');

      expect(offerings.length, 2);

      // Verify first offering (Pemrograman Mobile, ordered by course_name ASC)
      expect(offerings[0].offeringId, 'OFF001');
      expect(offerings[0].courseCode, 'IF101');
      expect(offerings[0].lecturerId, 'L001');
      expect(offerings[0].className, 'IF-44-01');
      expect(offerings[0].courseName, 'Pemrograman Mobile');
      expect(offerings[0].credits, 3);
      expect(offerings[0].enrolledCount, 3);

      // Verify second offering (Rekayasa Perangkat Lunak)
      expect(offerings[1].offeringId, 'OFF002');
      expect(offerings[1].courseCode, 'IF102');
      expect(offerings[1].lecturerId, 'L001');
      expect(offerings[1].className, 'IF-44-02');
      expect(offerings[1].courseName, 'Rekayasa Perangkat Lunak');
      expect(offerings[1].credits, 3);
      expect(offerings[1].enrolledCount, 3);
    });

    test('getOfferingsByLecturer filters by query matching course name, code, or class name', () async {
      final byName = await CourseRepository.instance.getOfferingsByLecturer('L001', query: 'Mobile');
      expect(byName.length, 1);
      expect(byName.first.courseCode, 'IF101');

      final byCode = await CourseRepository.instance.getOfferingsByLecturer('L001', query: 'IF102');
      expect(byCode.length, 1);
      expect(byCode.first.courseCode, 'IF102');

      final byClass = await CourseRepository.instance.getOfferingsByLecturer('L001', query: 'IF-44-01');
      expect(byClass.length, 1);
      expect(byClass.first.offeringId, 'OFF001');

      final noMatch = await CourseRepository.instance.getOfferingsByLecturer('L001', query: 'NonExistent');
      expect(noMatch, isEmpty);
    });

    test('getOfferingsByLecturer returns only offerings for L002', () async {
      final offerings = await CourseRepository.instance.getOfferingsByLecturer('L002');

      expect(offerings.length, 1);
      expect(offerings.first.offeringId, 'OFF003');
      expect(offerings.first.courseCode, 'SI101');
      expect(offerings.first.courseName, 'Basis Data Lanjut');
      expect(offerings.first.credits, 4);
      expect(offerings.first.enrolledCount, 1);
    });

    test('getOfferingById returns offering details with relational fields', () async {
      final offering = await CourseRepository.instance.getOfferingById('OFF001');

      expect(offering, isNotNull);
      expect(offering!.offeringId, 'OFF001');
      expect(offering.courseName, 'Pemrograman Mobile');
      expect(offering.credits, 3);
      expect(offering.enrolledCount, 3);

      final notFound = await CourseRepository.instance.getOfferingById('NON_EXISTENT');
      expect(notFound, isNull);
    });

    test('getAllCourses returns master courses', () async {
      final courses = await CourseRepository.instance.getAllCourses();

      expect(courses.length, 3);
      expect(courses.map((c) => c.courseCode), containsAll(['IF101', 'IF102', 'SI101']));
    });

    test('getCourseByCode returns specific course or null', () async {
      final course = await CourseRepository.instance.getCourseByCode('IF101');
      expect(course, isNotNull);
      expect(course!.courseName, 'Pemrograman Mobile');
      expect(course.credits, 3);

      final notFound = await CourseRepository.instance.getCourseByCode('UNKNOWN');
      expect(notFound, isNull);
    });
  });
}
