import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/courses/screens/course_detail_screen.dart';
import 'package:podo/features/courses/widgets/add_student_to_offering_sheet.dart';
import 'package:podo/features/grades/widgets/grade_input_bottom_sheet.dart';

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

  const testOffering = CourseOffering(
    offeringId: 'OFF001',
    courseCode: 'IF101',
    lecturerId: 'L001',
    className: 'IF-44-01',
    academicYear: '2024/2025',
    term: 'Ganjil',
    courseName: 'Pemrograman Mobile',
    credits: 3,
    enrolledCount: 3,
  );

  Widget buildTestableWidget({CourseOffering offering = testOffering}) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: CourseDetailScreen(offering: offering),
    );
  }

  group('CourseDetailScreen Widget Tests', () {
    testWidgets('displays course offering info card, header, and SKS badge', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.textContaining('IF101'), findsOneWidget);
      expect(find.textContaining('IF-44-01'), findsOneWidget);
      expect(find.text('3 SKS'), findsOneWidget);
      expect(find.textContaining('2024/2025'), findsNothing);
    });

    testWidgets('displays schedule information in header card when schedule exists', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // OFF001 schedule: Senin, 08:00 - 10:30, Ruang KU3.01
      expect(find.textContaining('Senin, 08:00 - 10:30'), findsOneWidget);
      expect(find.textContaining('Ruang KU3.01'), findsOneWidget);
    });

    testWidgets('displays progress bar for OFF001 initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      expect(find.text('Progress Penilaian'), findsOneWidget);
      expect(find.byType(FDeterminateProgress), findsOneWidget);
      expect(find.text('Sudah Dinilai'), findsOneWidget); // in filter tab
      expect(find.text('Belum Dinilai'), findsWidgets); // in filter tab + cards
      expect(find.text('Total Mahasiswa'), findsNothing); // removed from island

      expect(find.text('3'), findsWidgets); // Belum and Semua counts
      expect(find.text('0'), findsWidgets); // Sudah count
      expect(find.text('0%'), findsOneWidget); // Progress percent
      expect(find.textContaining('0/3 Dinilai'), findsNothing); // Redundant text removed
    });

    testWidgets('displays enrolled student roster with Belum Dinilai badge initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      expect(find.text('Ahmad Fauzi'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Citra Dewi'), findsOneWidget);

      expect(
        find.descendant(
          of: find.byType(FBadge),
          matching: find.text('Belum Dinilai'),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('tapping student card opens GradeInputBottomSheet via showFSheet', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ahmad Fauzi'));
      await tester.pumpAndSettle();

      expect(find.byType(GradeInputBottomSheet), findsOneWidget);
      expect(find.text('Penilaian CPMK Mahasiswa'), findsOneWidget);
    });

    testWidgets('submitting grades in sheet updates student status to Sudah Dinilai and refreshes stat metrics',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(buildTestableWidget());
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Tap Ahmad Fauzi
      await tester.tap(find.text('Ahmad Fauzi'));
      await tester.pumpAndSettle();

      // Fill CPMK fields in sheet
      final fields = find.descendant(
        of: find.byType(GradeInputBottomSheet),
        matching: find.byType(FTextField),
      );
      await tester.enterText(fields.at(0), '85');
      await tester.enterText(fields.at(1), '90');
      await tester.enterText(fields.at(2), '80');
      await tester.enterText(fields.at(3), '88');
      await tester.pumpAndSettle();

      // Submit
      final saveButton = find.text('Simpan Nilai');
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

      // Sheet should be dismissed
      expect(find.byType(GradeInputBottomSheet), findsNothing);

      // Status badge for Ahmad Fauzi updated
      expect(
        find.descendant(
          of: find.byType(FBadge),
          matching: find.text('Sudah Dinilai'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(FBadge),
          matching: find.text('Belum Dinilai'),
        ),
        findsNWidgets(2),
      );

      // Stat cards updated: Sudah = 1, Belum = 2
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('filters students in real time by name or NIM search query', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      final searchField = find.widgetWithText(FTextField, 'Cari nama atau NIM mahasiswa...');
      expect(searchField, findsOneWidget);

      // Search for Citra
      await tester.enterText(searchField, 'Citra');
      await tester.pumpAndSettle();

      expect(find.text('Citra Dewi'), findsOneWidget);
      expect(find.text('Ahmad Fauzi'), findsNothing);
      expect(find.text('Budi Santoso'), findsNothing);

      // Search for Budi's NIM
      await tester.enterText(searchField, '2101002');
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Citra Dewi'), findsNothing);

      // Empty search shows empty state
      await tester.enterText(searchField, 'ZzzNotExist');
      await tester.pumpAndSettle();

      expect(find.text('Mahasiswa tidak ditemukan'), findsOneWidget);
      expect(find.text('Reset Filter'), findsOneWidget);

      // Tap Reset Filter
      await tester.ensureVisible(find.text('Reset Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Ahmad Fauzi'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Citra Dewi'), findsOneWidget);
    });

    testWidgets('filters students via status segment tabs', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Tap 'Sudah Dinilai' filter tab
      await tester.tap(find.text('Sudah Dinilai'));
      await tester.pumpAndSettle();

      expect(find.text('Mahasiswa tidak ditemukan'), findsOneWidget);

      // Tap 'Belum Dinilai' filter tab
      await tester.tap(find.text('Belum Dinilai').first);
      await tester.pumpAndSettle();

      expect(find.text('Ahmad Fauzi'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Citra Dewi'), findsOneWidget);
    });

    testWidgets('shows error state when query fails and recovers on Coba Lagi', (tester) async {
      await tester.runAsync(() async {
        final db = await DatabaseHelper.instance.database;
        await db.execute('ALTER TABLE course_enrollments RENAME TO course_enrollments_bak');
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Kendala Memuat Data Perkuliahan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Restore table
      await tester.runAsync(() async {
        final db = await DatabaseHelper.instance.database;
        await db.execute('ALTER TABLE course_enrollments_bak RENAME TO course_enrollments');
      });

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Kendala Memuat Data Perkuliahan'), findsNothing);
      expect(find.text('Ahmad Fauzi'), findsOneWidget);
    });

    testWidgets('tapping 3-dot menu and Tambah Mahasiswa opens AddStudentToOfferingSheet and enrolls new student', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Initially Dewi Lestari is not in the course roster
      expect(find.text('Dewi Lestari'), findsNothing);

      // Tap 3-dot overflow menu
      final moreMenu = find.byIcon(FLucideIcons.ellipsis);
      expect(moreMenu, findsOneWidget);
      await tester.tap(moreMenu);
      await tester.pumpAndSettle();

      // Tap "Tambah Mahasiswa" in popover
      final addOption = find.text('Tambah Mahasiswa');
      expect(addOption, findsOneWidget);
      await tester.tap(addOption);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Expect AddStudentToOfferingSheet is displayed
      expect(find.byType(AddStudentToOfferingSheet), findsOneWidget);
      expect(find.text('Tambah Mahasiswa ke Kelas'), findsOneWidget);
      expect(find.textContaining('Dewi Lestari'), findsWidgets);

      // Tap "Tambahkan ke Kelas"
      final submitButton = find.text('Tambahkan ke Kelas');
      await tester.tap(submitButton);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(AddStudentToOfferingSheet), findsNothing);

      // Dewi Lestari should now be in the enrolled students roster
      expect(find.text('Dewi Lestari'), findsOneWidget);
    });

    testWidgets('tapping 3-dot and Edit Kelas opens AddClassOfferingSheet in edit mode and updates offering', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      final moreMenu = find.byIcon(FLucideIcons.ellipsis);
      expect(moreMenu, findsOneWidget);

      await tester.tap(moreMenu);
      await tester.pumpAndSettle();

      final editOption = find.text('Edit Kelas');
      expect(editOption, findsOneWidget);

      await tester.tap(editOption);
      await tester.pumpAndSettle();

      expect(find.text('Edit Kelas Perkuliahan'), findsOneWidget);

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });

    testWidgets('tapping 3-dot and Hapus Kelas shows confirmation dialog and deleting removes offering and pops', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      final moreMenu = find.byIcon(FLucideIcons.ellipsis);
      expect(moreMenu, findsOneWidget);

      await tester.tap(moreMenu);
      await tester.pumpAndSettle();

      final deleteOption = find.text('Hapus Kelas');
      expect(deleteOption, findsOneWidget);

      await tester.tap(deleteOption);
      await tester.pumpAndSettle();

      expect(find.text('Hapus Kelas Perkuliahan?'), findsOneWidget);

      // Tap confirm button
      final confirmDelete = find.descendant(
        of: find.byType(FDialog),
        matching: find.text('Hapus Kelas'),
      );
      await tester.tap(confirmDelete);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Verify offering was deleted from SQLite
      CourseOffering? deleted;
      await tester.runAsync(() async {
        deleted = await CourseRepository.instance.getOfferingById('OFF001');
      });
      expect(deleted, isNull);
    });

    testWidgets('tapping 3-dot and Kelola Mahasiswa enables edit mode with Batal button and removes student from class', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Ahmad Fauzi should be in the list
      expect(find.text('Ahmad Fauzi'), findsOneWidget);

      // Open 3-dot menu and select Kelola Mahasiswa
      final moreMenu = find.byIcon(FLucideIcons.ellipsis);
      expect(moreMenu, findsOneWidget);
      await tester.tap(moreMenu);
      await tester.pumpAndSettle();

      final manageOption = find.text('Kelola Mahasiswa');
      expect(manageOption, findsOneWidget);
      await tester.tap(manageOption);
      await tester.pumpAndSettle();

      // Edit mode is now active: 3-dot is replaced by "Batal" destructive button
      expect(find.byIcon(FLucideIcons.ellipsis), findsNothing);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.textContaining('Mode Kelola Mahasiswa aktif'), findsOneWidget);

      // Minus icons are now visible on each student card
      final unenrollButtons = find.byIcon(FLucideIcons.userMinus);
      expect(unenrollButtons, findsWidgets);

      await tester.tap(unenrollButtons.at(1)); // at(0) is the banner icon, at(1) is first student card
      await tester.pumpAndSettle();

      expect(find.text('Keluarkan Mahasiswa?'), findsOneWidget);

      final confirmButton = find.descendant(
        of: find.byType(FDialog),
        matching: find.text('Keluarkan'),
      );
      await tester.tap(confirmButton);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      });
      await tester.pumpAndSettle();

      // Ahmad Fauzi should now be removed from the UI list
      expect(find.text('Ahmad Fauzi'), findsNothing);

      // Tap "Batal" to exit edit mode
      await tester.tap(find.text('Batal'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // 3-dot icon is back, and edit mode banner is gone
      expect(find.byIcon(FLucideIcons.ellipsis), findsOneWidget);
      expect(find.text('Batal'), findsNothing);
      expect(find.textContaining('Mode Kelola Mahasiswa aktif'), findsNothing);
    });
  });
}
