import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/models/lecturer_stats.dart';

void main() {
  group('Lecturer model', () {
    test('creates Lecturer instance and maps to/from Map correctly', () {
      final map = {
        'lecturer_id': 'L001',
        'full_name': 'Dr. Eng. Muhammad Rizki, M.T.',
        'title': 'Ketua Program Studi',
        'nidh': '0012058801',
        'email': 'dosen@kampus.id',
        'phone': '081234567890',
        'department': 'Teknologi Informasi',
        'photo_path': '/path/to/photo.jpg',
      };

      final lecturer = Lecturer.fromMap(map);

      expect(lecturer.lecturerId, 'L001');
      expect(lecturer.fullName, 'Dr. Eng. Muhammad Rizki, M.T.');
      expect(lecturer.title, 'Ketua Program Studi');
      expect(lecturer.nidh, '0012058801');
      expect(lecturer.email, 'dosen@kampus.id');
      expect(lecturer.phone, '081234567890');
      expect(lecturer.department, 'Teknologi Informasi');
      expect(lecturer.photoPath, '/path/to/photo.jpg');

      final serialized = lecturer.toMap();
      expect(serialized, map);
    });

    test('handles optional nullable fields gracefully', () {
      final map = {
        'lecturer_id': 'L003',
        'full_name': 'Budi Santoso, M.Kom.',
        'title': null,
        'nidh': null,
        'email': null,
        'phone': null,
        'department': null,
        'photo_path': null,
      };

      final lecturer = Lecturer.fromMap(map);
      expect(lecturer.lecturerId, 'L003');
      expect(lecturer.fullName, 'Budi Santoso, M.Kom.');
      expect(lecturer.title, isNull);
      expect(lecturer.nidh, isNull);
      expect(lecturer.email, isNull);
      expect(lecturer.phone, isNull);
      expect(lecturer.department, isNull);
      expect(lecturer.photoPath, isNull);

      final serialized = lecturer.toMap();
      expect(serialized['title'], isNull);
    });
  });

  group('LecturerStats model', () {
    test('instantiates with expected counts and values', () {
      const stats = LecturerStats(
        courseCount: 3,
        totalCredits: 9,
        studentCount: 25,
      );

      expect(stats.courseCount, 3);
      expect(stats.totalCredits, 9);
      expect(stats.studentCount, 25);
    });
  });
}
