import 'package:flutter/foundation.dart';

@immutable
class Grade {
  final int? id;
  final int enrollmentId;
  final double? cpmk1;
  final double? cpmk2;
  final double? cpmk3;
  final double? cpmk4;

  const Grade({
    this.id,
    required this.enrollmentId,
    this.cpmk1,
    this.cpmk2,
    this.cpmk3,
    this.cpmk4,
  });

  bool get isFullyGraded =>
      cpmk1 != null && cpmk2 != null && cpmk3 != null && cpmk4 != null;

  double? get averageScore {
    final scores = [cpmk1, cpmk2, cpmk3, cpmk4].whereType<double>().toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'] as int?,
      enrollmentId: (map['enrollment_id'] as num).toInt(),
      cpmk1: (map['cpmk_1'] as num?)?.toDouble(),
      cpmk2: (map['cpmk_2'] as num?)?.toDouble(),
      cpmk3: (map['cpmk_3'] as num?)?.toDouble(),
      cpmk4: (map['cpmk_4'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'enrollment_id': enrollmentId,
      'cpmk_1': cpmk1,
      'cpmk_2': cpmk2,
      'cpmk_3': cpmk3,
      'cpmk_4': cpmk4,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Grade copyWith({
    int? id,
    int? enrollmentId,
    double? cpmk1,
    double? cpmk2,
    double? cpmk3,
    double? cpmk4,
  }) {
    return Grade(
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      cpmk1: cpmk1 ?? this.cpmk1,
      cpmk2: cpmk2 ?? this.cpmk2,
      cpmk3: cpmk3 ?? this.cpmk3,
      cpmk4: cpmk4 ?? this.cpmk4,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Grade &&
        other.id == id &&
        other.enrollmentId == enrollmentId &&
        other.cpmk1 == cpmk1 &&
        other.cpmk2 == cpmk2 &&
        other.cpmk3 == cpmk3 &&
        other.cpmk4 == cpmk4;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      enrollmentId,
      cpmk1,
      cpmk2,
      cpmk3,
      cpmk4,
    );
  }
}
