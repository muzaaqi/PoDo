import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/screens/course_detail_screen.dart';
import 'package:podo/features/courses/screens/course_list_screen.dart';

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
        '/courses/detail': (context) => const CourseDetailScreen(),
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
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Mata Kuliah'), findsOneWidget);

      // Verify Stat Cards: 2 classes, 6 SKS (3 + 3)
      expect(find.text('Total Kelas'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Total SKS'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);

      // Verify search field
      expect(find.byType(FTextField), findsOneWidget);

      // Verify course cards
      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
      expect(find.textContaining('IF-44-01'), findsOneWidget);
      expect(find.textContaining('IF-44-02'), findsOneWidget);
    });

    testWidgets('displays credits badge and enrolled student count on cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Badges with SKS
      expect(find.text('3 SKS'), findsNWidgets(2));

      // Student count
      expect(find.text('3 Mahasiswa'), findsNWidgets(2));
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

      // Stat cards updated: 1 class, 3 SKS
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
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
      await tester.pumpAndSettle();

      // CourseDetailScreen stub should be displayed with course info
      expect(find.text('IF101 - IF-44-01'), findsOneWidget);
    });
  });
}
