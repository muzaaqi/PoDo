class Student {
  final String nim;
  final String fullName;
  final String? studyProgram;
  final String? department;
  final String? phone;
  final String? address;

  const Student({
    required this.nim,
    required this.fullName,
    this.studyProgram,
    this.department,
    this.phone,
    this.address,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      nim: map['nim'] as String,
      fullName: map['full_name'] as String,
      studyProgram: map['study_program'] as String?,
      department: map['department'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nim': nim,
      'full_name': fullName,
      'study_program': studyProgram,
      'department': department,
      'phone': phone,
      'address': address,
    };
  }

  Student copyWith({
    String? nim,
    String? fullName,
    String? studyProgram,
    String? department,
    String? phone,
    String? address,
  }) {
    return Student(
      nim: nim ?? this.nim,
      fullName: fullName ?? this.fullName,
      studyProgram: studyProgram ?? this.studyProgram,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
