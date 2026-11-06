import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/screens/course_detail_screen.dart';
import 'package:podo/features/courses/screens/course_list_screen.dart';
import 'package:podo/features/courses/widgets/add_class_offering_sheet.dart';
import 'package:podo/features/courses/widgets/add_course_sheet.dart';

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
    // Login as L001
    await AuthRepository.instance.login('dosen@kampus.id', 'password123');
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await AuthRepository.instance.logout();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      routes: {
        '/courses/detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CourseDetailScreen(
            offering: args is CourseOffering ? args : null,
          );
        },
      },
      home: const CourseListScreen(),
    );
  }

  group('CourseListScreen Widget Tests', () {
    testWidgets('renders header, stat metrics, search field, and course cards for L001', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Verify Header and Floating Action Button
      expect(find.text('Mata Kuliah'), findsWidgets);
      expect(find.byIcon(FLucideIcons.plus), findsOneWidget);

      // Verify Hero Summary Banner: 3 classes, 9 SKS, 9 students (3 per class)
      expect(find.text('Total Kelas'), findsOneWidget);
      expect(find.text('Total SKS'), findsOneWidget);
      expect(find.text('Total Mahasiswa'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('9'), findsNWidgets(2));

      // Verify search field
      expect(find.byType(FTextField), findsOneWidget);

      // Verify course cards
      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
      expect(find.text('Sistem Terdistribusi'), findsOneWidget);
      expect(find.textContaining('IF-44-01'), findsOneWidget);
      expect(find.textContaining('IF-44-02'), findsOneWidget);
      expect(find.textContaining('IF-44-03'), findsOneWidget);
    });

    testWidgets('displays credits badge and enrolled student count on cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Badges with SKS
      expect(find.text('3 SKS'), findsNWidgets(3));

      // Student count
      expect(find.text('3 Mahasiswa'), findsNWidgets(3));
    });

    testWidgets('filters offerings in real time when typing search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Enter search query 'Mobile'
      await tester.enterText(find.byType(FTextField), 'Mobile');
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.text('Rekayasa Perangkat Lunak'), findsNothing);

      // Hero banner updated: 1 class, 3 SKS, 3 students
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsNWidgets(2));
    });

    testWidgets('shows empty state when no courses match search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Enter search query 'NonExistent'
      await tester.enterText(find.byType(FTextField), 'NonExistent');
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Mata kuliah tidak ditemukan'), findsOneWidget);
      expect(find.text('Pemrograman Mobile'), findsNothing);
    });

    testWidgets('tapping a course card navigates to CourseDetailScreen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Tap on 'Pemrograman Mobile'
      await tester.tap(find.text('Pemrograman Mobile'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // CourseDetailScreen should be displayed with course info
      expect(find.byType(CourseDetailScreen), findsOneWidget);
      expect(find.textContaining('IF101 • Kelas IF-44-01'), findsOneWidget);
    });

    testWidgets('tapping Reset Pencarian in empty state clears search query and restores courses', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Enter search query 'NonExistent'
      await tester.enterText(find.byType(FTextField), 'NonExistent');
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Mata kuliah tidak ditemukan'), findsOneWidget);
      expect(find.text('Reset Pencarian'), findsOneWidget);

      // Tap Reset Pencarian
      await tester.tap(find.text('Reset Pencarian'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
    });

    testWidgets('tapping floating action button expands speed dial with Tambah Kelas and Tambah Mata Kuliah', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Tap FAB to expand
      await tester.tap(find.byIcon(FLucideIcons.plus));
      await tester.pumpAndSettle();

      // Verify speed dial actions are displayed
      expect(find.text('Tambah Kelas'), findsOneWidget);
      expect(find.text('Tambah Mata Kuliah'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.school), findsOneWidget);
      expect(find.byIcon(FLucideIcons.bookPlus), findsOneWidget);

      // Tap Tambah Kelas action to open AddClassOfferingSheet
      await tester.tap(find.text('Tambah Kelas'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Verify AddClassOfferingSheet opens
      expect(find.byType(AddClassOfferingSheet), findsOneWidget);
      expect(find.text('Tambah Kelas Kuliah'), findsOneWidget);
      expect(find.text('Simpan Kelas'), findsOneWidget);
    });

    testWidgets('tapping Tambah Mata Kuliah in speed dial opens AddCourseSheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Tap FAB to expand
      await tester.tap(find.byIcon(FLucideIcons.plus));
      await tester.pumpAndSettle();

      // Tap Tambah Mata Kuliah action
      await tester.tap(find.text('Tambah Mata Kuliah'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Verify AddCourseSheet opens
      expect(find.byType(AddCourseSheet), findsOneWidget);
      expect(find.text('Kode Mata Kuliah'), findsOneWidget);
      expect(find.text('Nama Mata Kuliah'), findsOneWidget);
      expect(find.text('Simpan Mata Kuliah'), findsOneWidget);
    });

    testWidgets('successfully creates new course offering via AddClassOfferingSheet and updates list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      expect(find.text('Total Kelas'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Open speed dial and tap Tambah Kelas
      await tester.tap(find.byIcon(FLucideIcons.plus));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Kelas'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Enter class name IF-44-04
      final classField = find.widgetWithText(FTextField, 'Contoh: IF-44-01');
      await tester.enterText(classField, 'IF-44-04');
      await tester.pump();

      // Scroll to Simpan Kelas if needed and tap
      await tester.ensureVisible(find.text('Simpan Kelas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Kelas'));

      // Let SQLite persist and refresh
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(AddClassOfferingSheet), findsNothing);

      // New offering should appear on screen
      expect(find.textContaining('IF-44-04'), findsOneWidget);

      // Total Kelas updated to 4
      expect(find.text('Total Kelas'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('successfully creates new master course via AddCourseSheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Open speed dial and tap Tambah Mata Kuliah
      await tester.tap(find.byIcon(FLucideIcons.plus));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Mata Kuliah'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Fill in new master course
      final codeField = find.widgetWithText(FTextField, 'Contoh: IF104');
      final nameField = find.widgetWithText(FTextField, 'Contoh: Kecerdasan Buatan');
      await tester.enterText(codeField, 'IF105');
      await tester.enterText(nameField, 'Jaringan Komputer');
      await tester.pump();

      // Tap Simpan Mata Kuliah
      await tester.ensureVisible(find.text('Simpan Mata Kuliah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Mata Kuliah'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(AddCourseSheet), findsNothing);
    });

    testWidgets('ListView has keyboardDismissBehavior set to onDrag', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);
      final listView = tester.widget<ListView>(listViewFinder);
      expect(listView.keyboardDismissBehavior, ScrollViewKeyboardDismissBehavior.onDrag);
    });

    testWidgets('shows error state when query fails and recovers on Coba Lagi', (tester) async {
      await tester.runAsync(() async {
        final db = await DatabaseHelper.instance.database;
        await db.execute('ALTER TABLE course_offerings RENAME TO course_offerings_bak');
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text('Kendala Memuat Mata Kuliah'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Restore table
      await tester.runAsync(() async {
        final db = await DatabaseHelper.instance.database;
        await db.execute('ALTER TABLE course_offerings_bak RENAME TO course_offerings');
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

      expect(find.text('Kendala Memuat Mata Kuliah'), findsNothing);
      expect(find.text('Pemrograman Mobile'), findsOneWidget);
    });
  });
}
