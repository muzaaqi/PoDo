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
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nomor Induk Mahasiswa (NIM)'),
      '2101088',
    );
    // Full Name
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nama Lengkap'),
      'Rian Hidayat',
    );
    // Select Study Program: Sistem Informasi
    await tester.tap(find.byWidgetPredicate((widget) => widget is FSelect));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sistem Informasi').last);
    await tester.pumpAndSettle();
    // Department
    await tester.enterText(
      find.widgetWithText(FTextField, 'Jurusan / Departemen'),
      'Sistem Informasi',
    );
    // Phone
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nomor Telepon'),
      '081234567888',
    );
    // Address
    await tester.enterText(
      find.widgetWithText(FTextField, 'Alamat Lengkap'),
      'Jl. Buah Batu No. 5',
    );

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

  testWidgets('Renders two grouped section cards with correct labels', (tester) async {
    const existing = Student(
      nim: '2101001',
      fullName: 'Ahmad Fauzi',
      studyProgram: 'Teknik Informatika',
    );

    await tester.pumpWidget(buildTestableWidget(student: existing));
    await tester.pumpAndSettle();

    expect(find.text('Data Akademik & Identitas'), findsOneWidget);
    expect(find.text('Kontak & Domisili'), findsOneWidget);
    expect(find.text('NIM bersifat tetap dan tidak dapat diubah'), findsOneWidget);
  });

  testWidgets('No bullet point character exists in StudentBiodataFormScreen', (tester) async {
    const existing = Student(
      nim: '2101001',
      fullName: 'Ahmad Fauzi',
      studyProgram: 'Teknik Informatika',
      department: 'Teknologi Informasi',
      phone: '081234567890',
      address: 'Jl. Merdeka No. 10',
    );

    await tester.pumpWidget(buildTestableWidget(student: existing));
    await tester.pumpAndSettle();

    final allTextWidgets = tester.widgetList<Text>(find.byType(Text));
    for (final textWidget in allTextWidgets) {
      final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
      expect(data.contains('•'), isFalse, reason: 'Text contains banned bullet: "$data"');
    }
  });

  testWidgets('Dirty form triggers discard dialog when back button is pressed, and can cancel or discard', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: FToaster(
            child: FTooltipGroup(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentBiodataFormScreen(),
              ),
            ),
            child: const Text('Open Form'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open form
    await tester.tap(find.text('Open Form'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);

    // Modify a field to make the form dirty
    await tester.enterText(find.byType(FTextField).at(0), '2101099');
    await tester.pumpAndSettle();

    // Tap back button
    final backButton = find.byType(FHeaderAction);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Buang Perubahan?'), findsOneWidget);
    expect(find.text('Data biodata mahasiswa yang sudah Anda isi belum disimpan dan akan hilang jika Anda keluar.'), findsOneWidget);

    // Tap "Lanjut Mengisi" to stay
    await tester.tap(find.text('Lanjut Mengisi'));
    await tester.pumpAndSettle();
    expect(find.text('Buang Perubahan?'), findsNothing);
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);

    // Tap back again and choose "Buang Perubahan"
    await tester.tap(backButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buang Perubahan'));
    await tester.pumpAndSettle();

    // Screen is popped back to Open Form
    expect(find.text('Open Form'), findsOneWidget);
    expect(find.text('Tambah Mahasiswa'), findsNothing);
  });

  testWidgets('Selecting "Lainnya" shows custom study program field and saves custom value', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // NIM & Name
    await tester.enterText(find.byType(FTextField).at(0), '2101095');
    await tester.enterText(find.byType(FTextField).at(1), 'Siti Aminah');

    // Select "Lainnya" in FSelect
    await tester.tap(find.byWidgetPredicate((widget) => widget is FSelect));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lainnya (Kustom)').last);
    await tester.pumpAndSettle();

    // Custom study program field should now be visible
    expect(find.text('Nama Program Studi Kustom'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nama Program Studi Kustom'),
      'Teknologi Sains Data',
    );

    // Save
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
      student = await StudentRepository.instance.getStudentByNim('2101095');
    });
    expect(student, isNotNull);
    expect(student!.studyProgram, 'Teknologi Sains Data');
  });

  testWidgets('Shows error banner when save operation fails and dismisses when close icon tapped', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Fill valid data
    await tester.enterText(find.byType(FTextField).at(0), '2101096');
    await tester.enterText(find.byType(FTextField).at(1), 'Dewi Sartika');

    // Drop table students to simulate database error
    await tester.runAsync(() async {
      final db = await DatabaseHelper.instance.database;
      await db.execute('DROP TABLE students;');
    });

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

    // Error banner should be displayed
    expect(find.textContaining('Gagal menyimpan biodata mahasiswa'), findsAtLeast(1));

    // Tap dismiss icon on error banner
    final dismissIcon = find.byIcon(FLucideIcons.x);
    expect(dismissIcon, findsOneWidget);
    await tester.ensureVisible(dismissIcon);
    await tester.tap(dismissIcon);
    await tester.pumpAndSettle();

    // Banner is dismissed
    expect(find.byIcon(FLucideIcons.circleAlert), findsNothing);
  });

  testWidgets('validates custom study program when "Lainnya" is selected and empty', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(FTextField, 'Nomor Induk Mahasiswa (NIM)'),
      '2101097',
    );
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nama Lengkap'),
      'Rina Melati',
    );

    // Select Lainnya but leave custom field empty
    await tester.tap(find.byWidgetPredicate((widget) => widget is FSelect));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lainnya (Kustom)').last);
    await tester.pumpAndSettle();

    final saveButton = find.text('Simpan Mahasiswa');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify validation error
    expect(find.text('Program studi kustom wajib diisi jika memilih Lainnya'), findsAtLeast(1));
  });

  testWidgets('validates phone number format when filled with invalid value', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(FTextField, 'Nomor Induk Mahasiswa (NIM)'),
      '2101098',
    );
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nama Lengkap'),
      'Farhan Pratama',
    );
    await tester.enterText(
      find.widgetWithText(FTextField, 'Nomor Telepon'),
      '123',
    );

    final saveButton = find.text('Simpan Mahasiswa');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify phone validation error
    expect(find.text('Nomor telepon tidak valid (minimal 8 angka)'), findsAtLeast(1));
  });
}
