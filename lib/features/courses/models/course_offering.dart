import 'package:flutter/foundation.dart';

@immutable
class CourseOffering {
  final String offeringId;
  final String courseCode;
  final String lecturerId;
  final String className;
  final String academicYear;
  final String term;

  // Relational join fields
  final String courseName;
  final int credits;
  final int enrolledCount;

  const CourseOffering({
    required this.offeringId,
    required this.courseCode,
    required this.lecturerId,
    required this.className,
    required this.academicYear,
    required this.term,
    this.courseName = '',
    this.credits = 0,
    this.enrolledCount = 0,
  });

  factory CourseOffering.fromMap(Map<String, dynamic> map) {
    return CourseOffering(
      offeringId: map['offering_id'] as String,
      courseCode: map['course_code'] as String,
      lecturerId: map['lecturer_id'] as String,
      className: map['class_name'] as String,
      academicYear: map['academic_year'] as String,
      term: map['term'] as String,
      courseName: map['course_name'] as String? ?? '',
      credits: (map['credits'] as num?)?.toInt() ?? 0,
      enrolledCount: (map['enrolled_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offering_id': offeringId,
      'course_code': courseCode,
      'lecturer_id': lecturerId,
      'class_name': className,
      'academic_year': academicYear,
      'term': term,
      'course_name': courseName,
      'credits': credits,
      'enrolled_count': enrolledCount,
    };
  }

  CourseOffering copyWith({
    String? offeringId,
    String? courseCode,
    String? lecturerId,
    String? className,
    String? academicYear,
    String? term,
    String? courseName,
    int? credits,
    int? enrolledCount,
  }) {
    return CourseOffering(
      offeringId: offeringId ?? this.offeringId,
      courseCode: courseCode ?? this.courseCode,
      lecturerId: lecturerId ?? this.lecturerId,
      className: className ?? this.className,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      enrolledCount: enrolledCount ?? this.enrolledCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseOffering &&
        other.offeringId == offeringId &&
        other.courseCode == courseCode &&
        other.lecturerId == lecturerId &&
        other.className == className &&
        other.academicYear == academicYear &&
        other.term == term &&
        other.courseName == courseName &&
        other.credits == credits &&
        other.enrolledCount == enrolledCount;
  }

  @override
  int get hashCode {
    return offeringId.hashCode ^
        courseCode.hashCode ^
        lecturerId.hashCode ^
        className.hashCode ^
        academicYear.hashCode ^
        term.hashCode ^
        courseName.hashCode ^
        credits.hashCode ^
        enrolledCount.hashCode;
  }

  @override
  String toString() {
    return 'CourseOffering(offeringId: $offeringId, courseCode: $courseCode, '
        'lecturerId: $lecturerId, className: $className, academicYear: $academicYear, '
        'term: $term, courseName: $courseName, credits: $credits, enrolledCount: $enrolledCount)';
  }
}
