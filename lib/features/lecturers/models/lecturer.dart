class Lecturer {
  final String lecturerId;
  final String fullName;
  final String? title;
  final String? nidh;
  final String? email;
  final String? phone;
  final String? department;
  final String? photoPath;

  const Lecturer({
    required this.lecturerId,
    required this.fullName,
    this.title,
    this.nidh,
    this.email,
    this.phone,
    this.department,
    this.photoPath,
  });

  factory Lecturer.fromMap(Map<String, dynamic> map) {
    return Lecturer(
      lecturerId: map['lecturer_id'] as String,
      fullName: map['full_name'] as String,
      title: map['title'] as String?,
      nidh: map['nidh'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      department: map['department'] as String?,
      photoPath: map['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lecturer_id': lecturerId,
      'full_name': fullName,
      'title': title,
      'nidh': nidh,
      'email': email,
      'phone': phone,
      'department': department,
      'photo_path': photoPath,
    };
  }
}
