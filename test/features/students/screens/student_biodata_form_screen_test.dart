import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/repositories/student_repository.dart';
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final helper = DatabaseHelper.instance;
    await helper.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  Widget buildTestableWidget({Student? student}) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: StudentBiodataFormScreen(student: student),
    );
  }

  testWidgets('Create mode renders empty form with Tambah Mahasiswa title', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Tambah Mahasiswa'), findsOneWidget);
    expect(find.text('Simpan Mahasiswa'), findsOneWidget);
    expect(find.text('Hapus Mahasiswa'), findsNothing);
  });

  testWidgets('Validation error is shown when submitting empty NIM or Name', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final saveButton = find.text('Simpan Mahasiswa');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('NIM wajib diisi'), findsOneWidget);
    expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
  });

  testWidgets('Create mode rejects duplicate NIM', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Fill NIM with existing seed NIM 2101001
    final nimField = find.byType(FTextField).first;
    await tester.enterText(nimField, '2101001');

    final nameField = find.byType(FTextField).at(1);
    await tester.enterText(nameField, 'Mahasiswa Baru');

    final saveButton = find.text('Simpan Mahasiswa');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('NIM sudah terdaftar'), findsOneWidget);
  });

  testWidgets('Create mode successfully saves student to SQLite', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // NIM
    await tester.enterText(find.byType(FTextField).at(0), '2101088');
    // Full Name
    await tester.enterText(find.byType(FTextField).at(1), 'Rian Hidayat');
    // Study Program
    await tester.enterText(find.byType(FTextField).at(2), 'Sistem Informasi');
    // Department
    await tester.enterText(find.byType(FTextField).at(3), 'Teknologi Informasi');
    // Phone
    await tester.enterText(find.byType(FTextField).at(4), '081234567888');
    // Address
    await tester.enterText(find.byType(FTextField).at(5), 'Jl. Buah Batu No. 5');

    final saveButton = find.text('Simpan Mahasiswa');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    Student? student;
    await tester.runAsync(() async {
      student = await StudentRepository.instance.getStudentByNim('2101088');
    });
    expect(student, isNotNull);
    expect(student!.fullName, 'Rian Hidayat');
    expect(student!.studyProgram, 'Sistem Informasi');
  });

  testWidgets('Edit mode populates fields, locks NIM, and updates student in SQLite', (tester) async {
    const existing = Student(
      nim: '2101001',
      fullName: 'Ahmad Fauzi',
      studyProgram: 'Teknik Informatika',
      department: 'Teknologi Informasi',
      phone: '082111111111',
      address: 'Jl. Merdeka No. 10',
    );

    await tester.pumpWidget(buildTestableWidget(student: existing));
    await tester.pumpAndSettle();

    expect(find.text('Edit Biodata Mahasiswa'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Hapus Mahasiswa'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsOneWidget);

    // Update Name
    final nameField = find.byType(FTextField).at(1);
    await tester.enterText(nameField, 'Ahmad Fauzi, M.T.');

    final saveButton = find.text('Simpan Perubahan');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    Student? updated;
    await tester.runAsync(() async {
      updated = await StudentRepository.instance.getStudentByNim('2101001');
    });
    expect(updated!.fullName, 'Ahmad Fauzi, M.T.');
  });

  testWidgets('Edit mode allows deleting student with confirmation dialog', (tester) async {
    const existing = Student(
      nim: '2101002',
      fullName: 'Budi Santoso',
      studyProgram: 'Teknik Informatika',
    );

    await tester.pumpWidget(buildTestableWidget(student: existing));
    await tester.pumpAndSettle();

    final deleteButton = find.text('Hapus Mahasiswa');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Hapus'), findsOneWidget);
    expect(find.text('Apakah Anda yakin ingin menghapus data mahasiswa ini?'), findsOneWidget);

    final dialogConfirmButton = find.descendant(
      of: find.byType(FDialog),
      matching: find.text('Hapus'),
    );
    await tester.tap(dialogConfirmButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    Student? deleted;
    await tester.runAsync(() async {
      deleted = await StudentRepository.instance.getStudentByNim('2101002');
    });
    expect(deleted, isNull);
  });
}
