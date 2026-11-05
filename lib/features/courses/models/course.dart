import 'package:flutter/foundation.dart';

@immutable
class Course {
  final String courseCode;
  final String courseName;
  final int credits;

  const Course({
    required this.courseCode,
    required this.courseName,
    required this.credits,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseCode: map['course_code'] as String,
      courseName: map['course_name'] as String,
      credits: (map['credits'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_code': courseCode,
      'course_name': courseName,
      'credits': credits,
    };
  }

  Course copyWith({
    String? courseCode,
    String? courseName,
    int? credits,
  }) {
    return Course(
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Course &&
        other.courseCode == courseCode &&
        other.courseName == courseName &&
        other.credits == credits;
  }

  @override
  int get hashCode =>
      courseCode.hashCode ^ courseName.hashCode ^ credits.hashCode;

  @override
  String toString() =>
      'Course(courseCode: $courseCode, courseName: $courseName, credits: $credits)';
}
