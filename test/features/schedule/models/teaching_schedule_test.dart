import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';

void main() {
  group('TeachingSchedule Model', () {
    const sampleMap = <String, dynamic>{
      'id': 1,
      'offering_id': 'OFF001',
      'day_of_week': 'Senin',
      'room': 'KU3.01',
      'start_time': '08:00',
      'end_time': '10:30',
      'course_code': 'IF101',
      'course_name': 'Pemrograman Mobile',
      'credits': 3,
      'class_name': 'IF-44-01',
      'academic_year': '2024/2025',
      'term': 'Ganjil',
    };

    const sampleSchedule = TeachingSchedule(
      id: 1,
      offeringId: 'OFF001',
      dayOfWeek: 'Senin',
      room: 'KU3.01',
      startTime: '08:00',
      endTime: '10:30',
      courseCode: 'IF101',
      courseName: 'Pemrograman Mobile',
      credits: 3,
      className: 'IF-44-01',
      academicYear: '2024/2025',
      term: 'Ganjil',
    );

    test('should instantiate TeachingSchedule with given properties', () {
      expect(sampleSchedule.id, 1);
      expect(sampleSchedule.offeringId, 'OFF001');
      expect(sampleSchedule.dayOfWeek, 'Senin');
      expect(sampleSchedule.room, 'KU3.01');
      expect(sampleSchedule.startTime, '08:00');
      expect(sampleSchedule.endTime, '10:30');
      expect(sampleSchedule.courseCode, 'IF101');
      expect(sampleSchedule.courseName, 'Pemrograman Mobile');
      expect(sampleSchedule.credits, 3);
      expect(sampleSchedule.className, 'IF-44-01');
      expect(sampleSchedule.academicYear, '2024/2025');
      expect(sampleSchedule.term, 'Ganjil');
    });

    test('fromMap should parse map with relational join fields properly', () {
      final schedule = TeachingSchedule.fromMap(sampleMap);

      expect(schedule.id, 1);
      expect(schedule.offeringId, 'OFF001');
      expect(schedule.dayOfWeek, 'Senin');
      expect(schedule.room, 'KU3.01');
      expect(schedule.startTime, '08:00');
      expect(schedule.endTime, '10:30');
      expect(schedule.courseCode, 'IF101');
      expect(schedule.courseName, 'Pemrograman Mobile');
      expect(schedule.credits, 3);
      expect(schedule.className, 'IF-44-01');
      expect(schedule.academicYear, '2024/2025');
      expect(schedule.term, 'Ganjil');
    });

    test('toMap should convert entity back to map representation', () {
      final map = sampleSchedule.toMap();

      expect(map['id'], 1);
      expect(map['offering_id'], 'OFF001');
      expect(map['day_of_week'], 'Senin');
      expect(map['room'], 'KU3.01');
      expect(map['start_time'], '08:00');
      expect(map['end_time'], '10:30');
      expect(map['course_code'], 'IF101');
      expect(map['course_name'], 'Pemrograman Mobile');
      expect(map['credits'], 3);
      expect(map['class_name'], 'IF-44-01');
      expect(map['academic_year'], '2024/2025');
      expect(map['term'], 'Ganjil');
    });

    test('copyWith should return a new object with updated values', () {
      final updated = sampleSchedule.copyWith(
        room: 'KU3.02',
        startTime: '13:00',
        endTime: '15:30',
      );

      expect(updated.id, sampleSchedule.id);
      expect(updated.room, 'KU3.02');
      expect(updated.startTime, '13:00');
      expect(updated.endTime, '15:30');
      expect(updated.courseName, sampleSchedule.courseName);
    });

    test('equality and hashCode should work correctly based on all fields', () {
      final scheduleDuplicate = TeachingSchedule.fromMap(sampleMap);

      expect(sampleSchedule, equals(scheduleDuplicate));
      expect(sampleSchedule.hashCode, equals(scheduleDuplicate.hashCode));

      final differentSchedule = sampleSchedule.copyWith(room: 'KU1.01');
      expect(sampleSchedule, isNot(equals(differentSchedule)));
    });
  });
}
