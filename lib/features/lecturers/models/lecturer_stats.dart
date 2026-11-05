class LecturerStats {
  final int courseCount;
  final int totalCredits;
  final int studentCount;

  const LecturerStats({
    required this.courseCount,
    required this.totalCredits,
    required this.studentCount,
  });

  const LecturerStats.zero()
      : courseCount = 0,
        totalCredits = 0,
        studentCount = 0;
}
