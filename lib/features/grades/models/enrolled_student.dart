import 'package:flutter/foundation.dart';
import 'package:podo/features/grades/models/grade.dart';

@immutable
class EnrolledStudent {
  final int enrollmentId;
  final String offeringId;
  final String studentNim;
  final String studentName;
  final String studyProgram;
  final Grade? grade;

  const EnrolledStudent({
    required this.enrollmentId,
    required this.offeringId,
    required this.studentNim,
    required this.studentName,
    this.studyProgram = '',
    this.grade,
  });

  bool get isGraded => grade?.hasAnyGrade ?? false;

  bool get isFullyGraded => grade?.isFullyGraded ?? false;

  int get gradedCpmkCount => grade?.gradedCpmkCount ?? 0;

  double? get averageScore => grade?.averageScore;

  factory EnrolledStudent.fromMap(Map<String, dynamic> map) {
    final hasGradeData = map['grade_id'] != null ||
        map['cpmk_1'] != null ||
        map['cpmk_2'] != null ||
        map['cpmk_3'] != null ||
        map['cpmk_4'] != null;

    final grade = hasGradeData
        ? Grade(
            id: map['grade_id'] as int?,
            enrollmentId: (map['enrollment_id'] as num).toInt(),
            cpmk1: (map['cpmk_1'] as num?)?.toDouble(),
            cpmk2: (map['cpmk_2'] as num?)?.toDouble(),
            cpmk3: (map['cpmk_3'] as num?)?.toDouble(),
            cpmk4: (map['cpmk_4'] as num?)?.toDouble(),
          )
        : null;

    return EnrolledStudent(
      enrollmentId: (map['enrollment_id'] as num).toInt(),
      offeringId: map['offering_id'] as String,
      studentNim: map['student_nim'] as String,
      studentName: map['student_name'] as String? ?? '',
      studyProgram: map['study_program'] as String? ?? '',
      grade: grade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enrollment_id': enrollmentId,
      'offering_id': offeringId,
      'student_nim': studentNim,
      'student_name': studentName,
      'study_program': studyProgram,
    };
  }

  EnrolledStudent copyWith({
    int? enrollmentId,
    String? offeringId,
    String? studentNim,
    String? studentName,
    String? studyProgram,
    Grade? grade,
  }) {
    return EnrolledStudent(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      offeringId: offeringId ?? this.offeringId,
      studentNim: studentNim ?? this.studentNim,
      studentName: studentName ?? this.studentName,
      studyProgram: studyProgram ?? this.studyProgram,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EnrolledStudent &&
        other.enrollmentId == enrollmentId &&
        other.offeringId == offeringId &&
        other.studentNim == studentNim &&
        other.studentName == studentName &&
        other.studyProgram == studyProgram &&
        other.grade == grade;
  }

  @override
  int get hashCode {
    return Object.hash(
      enrollmentId,
      offeringId,
      studentNim,
      studentName,
      studyProgram,
      grade,
    );
  }
}
