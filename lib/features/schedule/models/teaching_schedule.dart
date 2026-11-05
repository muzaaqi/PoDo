import 'package:flutter/foundation.dart';

@immutable
class TeachingSchedule {
  final int id;
  final String offeringId;
  final String dayOfWeek;
  final String room;
  final String startTime;
  final String endTime;

  // Relational join fields
  final String courseCode;
  final String courseName;
  final int credits;
  final String className;
  final String academicYear;
  final String term;

  const TeachingSchedule({
    required this.id,
    required this.offeringId,
    required this.dayOfWeek,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.className,
    required this.academicYear,
    required this.term,
  });

  factory TeachingSchedule.fromMap(Map<String, dynamic> map) {
    return TeachingSchedule(
      id: map['id'] as int,
      offeringId: map['offering_id'] as String,
      dayOfWeek: map['day_of_week'] as String,
      room: map['room'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      courseCode: map['course_code'] as String? ?? '',
      courseName: map['course_name'] as String? ?? '',
      credits: (map['credits'] as num?)?.toInt() ?? 0,
      className: map['class_name'] as String? ?? '',
      academicYear: map['academic_year'] as String? ?? '',
      term: map['term'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offering_id': offeringId,
      'day_of_week': dayOfWeek,
      'room': room,
      'start_time': startTime,
      'end_time': endTime,
      'course_code': courseCode,
      'course_name': courseName,
      'credits': credits,
      'class_name': className,
      'academic_year': academicYear,
      'term': term,
    };
  }

  TeachingSchedule copyWith({
    int? id,
    String? offeringId,
    String? dayOfWeek,
    String? room,
    String? startTime,
    String? endTime,
    String? courseCode,
    String? courseName,
    int? credits,
    String? className,
    String? academicYear,
    String? term,
  }) {
    return TeachingSchedule(
      id: id ?? this.id,
      offeringId: offeringId ?? this.offeringId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      className: className ?? this.className,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeachingSchedule &&
        other.id == id &&
        other.offeringId == offeringId &&
        other.dayOfWeek == dayOfWeek &&
        other.room == room &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.courseCode == courseCode &&
        other.courseName == courseName &&
        other.credits == credits &&
        other.className == className &&
        other.academicYear == academicYear &&
        other.term == term;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        offeringId.hashCode ^
        dayOfWeek.hashCode ^
        room.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        courseCode.hashCode ^
        courseName.hashCode ^
        credits.hashCode ^
        className.hashCode ^
        academicYear.hashCode ^
        term.hashCode;
  }

  @override
  String toString() {
    return 'TeachingSchedule(id: $id, offeringId: $offeringId, dayOfWeek: $dayOfWeek, '
        'room: $room, startTime: $startTime, endTime: $endTime, courseCode: $courseCode, '
        'courseName: $courseName, credits: $credits, className: $className, '
        'academicYear: $academicYear, term: $term)';
  }
}
