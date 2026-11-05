import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/repositories/student_repository.dart';
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';
import 'package:podo/features/students/screens/student_list_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.instance.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    await AuthRepository.instance.login('dosen@kampus.id', 'password123');
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await AuthRepository.instance.logout();
  });

  Widget buildApp({String initialRoute = AppRoutes.main}) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        ...AppRoutes.routes,
        AppRoutes.splash: (context) => const SizedBox.shrink(),
      },
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  testWidgets('AppRoutes.studentBiodataForm extracts Student argument for edit mode',
      (tester) async {
    const student = Student(
      nim: '2024099099',
      fullName: 'Test Route Student',
      studyProgram: 'Teknik Informatika',
      department: 'Teknik Elektro dan Informatika',
      phone: '081234567890',
      address: 'Jl. Kampus No. 1',
    );

    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        initialRoute: '/test-root',
        routes: {
          '/test-root': (context) => const SizedBox(),
          ...AppRoutes.routes,
          AppRoutes.splash: (context) => const SizedBox.shrink(),
        },
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: FToaster(
            child: FTooltipGroup(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    navKey.currentState!.pushNamed(
      AppRoutes.studentBiodataForm,
      arguments: student,
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Edit Biodata Mahasiswa'), findsOneWidget);
    expect(find.text('Test Route Student'), findsOneWidget);
    expect(find.text('2024099099'), findsOneWidget);
  });

  testWidgets('End-to-end student flow: Home -> List -> Add Student -> Edit in SQLite',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(buildApp(initialRoute: AppRoutes.main));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // 1. On Home Screen, tap 'Informasi Mahasiswa' quick action
    final infoMahasiswaButton = find.text('Informasi Mahasiswa');
    expect(infoMahasiswaButton, findsOneWidget);

    await tester.tap(infoMahasiswaButton);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Verify on StudentListScreen
    expect(find.byType(StudentListScreen), findsOneWidget);
    expect(find.text('Daftar Mahasiswa'), findsOneWidget);

    // 2. Tap Add Student button (the userPlus header action)
    final addHeaderAction = find.byIcon(FLucideIcons.userPlus);
    expect(addHeaderAction, findsOneWidget);
    await tester.tap(addHeaderAction);
    await tester.pumpAndSettle();

    // Verify on StudentBiodataFormScreen in create mode
    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);

    // 3. Fill in student form
    final formFields = find.descendant(
      of: find.byType(StudentBiodataFormScreen),
      matching: find.byType(FTextField),
    );
    await tester.enterText(formFields.at(0), '2024009999'); // NIM
    await tester.enterText(formFields.at(1), 'Mahasiswa Baru Alur'); // Nama
    await tester.enterText(formFields.at(2), 'Sistem Informasi'); // Prodi
    await tester.enterText(formFields.at(3), 'Teknologi Informasi'); // Jurusan
    await tester.enterText(formFields.at(4), '081234567899'); // Phone
    await tester.enterText(formFields.at(5), 'Jl. Integrasi No. 99'); // Alamat
    await tester.pumpAndSettle();

    // 4. Save student
    final saveButton = find.text('Simpan Mahasiswa');
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    // Allow _saveStudent (SQLite write) and subsequent pop to execute
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    // Allow StudentListScreen._loadStudents (SQLite read) to complete
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // 5. Verify back on StudentListScreen and new student is visible
    expect(find.byType(StudentListScreen), findsOneWidget);

    // Verify persisted in SQLite
    Student? created;
    await tester.runAsync(() async {
      created = await StudentRepository.instance.getStudentByNim('2024009999');
    });
    expect(created, isNotNull);
    expect(created?.fullName, 'Mahasiswa Baru Alur');

    // Scroll to new student if needed
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Mahasiswa Baru Alur'), findsOneWidget);

    // 6. Tap on new student to edit
    await tester.tap(find.text('Mahasiswa Baru Alur'));
    await tester.pumpAndSettle();

    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Edit Biodata Mahasiswa'), findsOneWidget);

    // Edit Name
    final editFormFields = find.descendant(
      of: find.byType(StudentBiodataFormScreen),
      matching: find.byType(FTextField),
    );
    await tester.enterText(editFormFields.at(1), 'Mahasiswa Baru Diperbarui');
    await tester.pumpAndSettle();

    // Save update
    final editSaveButton = find.text('Simpan Perubahan');
    await tester.ensureVisible(editSaveButton);
    await tester.tap(editSaveButton);

    // Allow _saveStudent (SQLite update) and pop to execute
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    // Allow StudentListScreen._loadStudents to complete
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // Verify back on StudentListScreen with updated name
    expect(find.byType(StudentListScreen), findsOneWidget);

    // Scroll to updated student if needed
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Mahasiswa Baru Diperbarui'), findsOneWidget);

    Student? updated;
    await tester.runAsync(() async {
      updated = await StudentRepository.instance.getStudentByNim('2024009999');
    });
    expect(updated?.fullName, 'Mahasiswa Baru Diperbarui');
  });
}
