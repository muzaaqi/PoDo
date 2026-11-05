import 'package:flutter_test/flutter_test.dart';
import 'package:podo/features/students/models/student.dart';

void main() {
  group('Student model', () {
    test('creates Student instance and maps to/from Map correctly', () {
      final map = {
        'nim': '2101001',
        'full_name': 'Ahmad Fauzi',
        'study_program': 'Teknologi Informasi',
        'department': 'Teknologi Informasi',
        'phone': '081234567891',
        'address': 'Jl. Merdeka No. 1, Jakarta',
      };

      final student = Student.fromMap(map);

      expect(student.nim, '2101001');
      expect(student.fullName, 'Ahmad Fauzi');
      expect(student.studyProgram, 'Teknologi Informasi');
      expect(student.department, 'Teknologi Informasi');
      expect(student.phone, '081234567891');
      expect(student.address, 'Jl. Merdeka No. 1, Jakarta');

      final serialized = student.toMap();
      expect(serialized, map);
    });

    test('handles optional nullable fields gracefully', () {
      final map = {
        'nim': '2101099',
        'full_name': 'Dewi Sartika',
        'study_program': null,
        'department': null,
        'phone': null,
        'address': null,
      };

      final student = Student.fromMap(map);
      expect(student.nim, '2101099');
      expect(student.fullName, 'Dewi Sartika');
      expect(student.studyProgram, isNull);
      expect(student.department, isNull);
      expect(student.phone, isNull);
      expect(student.address, isNull);

      final serialized = student.toMap();
      expect(serialized['study_program'], isNull);
    });

    test('copyWith updates specified fields while retaining others', () {
      const student = Student(
        nim: '2101001',
        fullName: 'Ahmad Fauzi',
        studyProgram: 'Teknologi Informasi',
        department: 'Teknologi Informasi',
        phone: '081234567891',
        address: 'Jl. Merdeka No. 1',
      );

      final updated = student.copyWith(
        fullName: 'Ahmad Fauzi, S.Kom.',
        phone: '0899999999',
      );

      expect(updated.nim, '2101001');
      expect(updated.fullName, 'Ahmad Fauzi, S.Kom.');
      expect(updated.studyProgram, 'Teknologi Informasi');
      expect(updated.phone, '0899999999');
      expect(updated.address, 'Jl. Merdeka No. 1');
    });
  });
}
