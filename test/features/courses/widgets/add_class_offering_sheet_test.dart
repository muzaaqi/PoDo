import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/courses/widgets/add_class_offering_sheet.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

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
    await AuthRepository.instance.login('dosen@kampus.id', 'password123');
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await AuthRepository.instance.logout();
  });

  Widget buildTestableWidget({CourseOffering? initialOffering}) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: Scaffold(
        body: AddClassOfferingSheet(initialOffering: initialOffering),
      ),
    );
  }

  testWidgets('AddClassOfferingSheet renders schedule inputs in create mode and saves both offering & schedule', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();

    // Verify title and schedule section headers exist
    expect(find.text('Tambah Kelas Kuliah'), findsOneWidget);
    expect(find.text('Jadwal Perkuliahan'), findsOneWidget);
    expect(find.text('Ruangan'), findsOneWidget);
    expect(find.text('Jam Mulai'), findsOneWidget);
    expect(find.text('Jam Selesai'), findsOneWidget);

    // Enter class name
    final classNameField = find.byWidgetPredicate(
      (w) => w is FTextField && w.hint == 'Contoh: IF-44-01',
    );
    expect(classNameField, findsOneWidget);
    await tester.enterText(classNameField, 'IF-TEST-99');
    await tester.pumpAndSettle();

    // Enter room
    final roomField = find.byWidgetPredicate(
      (w) => w is FTextField && w.hint == 'Contoh: KU3.01 / LAB-02',
    );
    expect(roomField, findsOneWidget);
    await tester.enterText(roomField, 'LAB-ROBOTIK');
    await tester.pumpAndSettle();

    // Submit form
    final submitButton = find.widgetWithText(FButton, 'Simpan Kelas');
    expect(submitButton, findsOneWidget);
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // Verify offering created in database
    await tester.runAsync(() async {
      final offerings = await CourseRepository.instance.getOfferingsByLecturer('L001');
      final createdOffering = offerings.firstWhere((o) => o.className == 'IF-TEST-99');
      expect(createdOffering, isNotNull);

      // Verify schedule created and linked to that offering
      final schedules = await ScheduleRepository.instance.getSchedulesByOffering(createdOffering.offeringId);
      expect(schedules, isNotEmpty);
      expect(schedules.first.room, 'LAB-ROBOTIK');
      expect(schedules.first.startTime, '08:00');
      expect(schedules.first.endTime, '10:30');
    });
  });

  testWidgets('AddClassOfferingSheet in edit mode loads existing schedule and updates both', (tester) async {
    final existingOffering = CourseOffering(
      offeringId: 'OFF001',
      courseCode: 'IF101',
      lecturerId: 'L001',
      className: 'IF-44-01',
      academicYear: '2024/2025',
      term: 'Ganjil',
      courseName: 'Pemrograman Mobile',
      credits: 3,
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(initialOffering: existingOffering));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Edit Kelas Perkuliahan'), findsOneWidget);
    expect(find.text('Jadwal Perkuliahan'), findsOneWidget);

    // Initial schedule for OFF001 is KU3.01 on Senin 08:00 - 10:30
    final roomField = find.byWidgetPredicate(
      (w) => w is FTextField && w.hint == 'Contoh: KU3.01 / LAB-02',
    );
    expect(roomField, findsOneWidget);
    await tester.ensureVisible(roomField);
    await tester.pumpAndSettle();
    await tester.enterText(roomField, 'LAB-MULTIMEDIA');
    await tester.pumpAndSettle();

    // Submit changes
    final saveButton = find.widgetWithText(FButton, 'Simpan Perubahan');
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // Verify schedule room updated in SQLite
    await tester.runAsync(() async {
      final schedule = await ScheduleRepository.instance.getPrimaryScheduleForOffering('OFF001');
      expect(schedule, isNotNull);
      expect(schedule!.room, 'LAB-MULTIMEDIA');
    });
  });
}
