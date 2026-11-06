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
import 'package:podo/features/courses/widgets/add_course_offering_sheet.dart';

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

      // Verify Header
      expect(find.text('Mata Kuliah'), findsWidgets);
      expect(find.text('Tambah Kelas'), findsOneWidget);

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

    testWidgets('tapping Tambah Kelas opens AddCourseOfferingSheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Tap Tambah Kelas button
      await tester.tap(find.text('Tambah Kelas'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Verify sheet opens
      expect(find.byType(AddCourseOfferingSheet), findsOneWidget);
      expect(find.text('Tambah Kelas Kuliah'), findsOneWidget);
      expect(find.text('Simpan Kelas'), findsOneWidget);
    });

    testWidgets('successfully creates new course offering via sheet and updates list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      expect(find.text('Total Kelas'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Open AddCourseOfferingSheet
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
      expect(find.byType(AddCourseOfferingSheet), findsNothing);

      // New offering should appear on screen
      expect(find.textContaining('IF-44-04'), findsOneWidget);

      // Total Kelas updated to 4
      expect(find.text('Total Kelas'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });
}
