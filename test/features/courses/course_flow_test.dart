import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
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
    await AuthRepository.instance.login('dosen@kampus.id', 'password123');
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await AuthRepository.instance.logout();
  });

  Widget buildApp() {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.courseDetail) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              final args = settings.arguments;
              return CourseDetailScreen(
                offering: args is CourseOffering ? args : null,
              );
            },
          );
        }
        return null;
      },
    );
  }

  testWidgets('Integration flow: Quick Action Input Nilai navigates to CourseListScreen and opens CourseDetailScreen',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // 1. Initial screen is Home
    expect(find.text('Selamat Datang,'), findsOneWidget);

    // 2. Tap Quick Action "Input Nilai"
    final inputNilaiButton = find.text('Input Nilai');
    expect(inputNilaiButton, findsOneWidget);
    await tester.ensureVisible(inputNilaiButton);
    await tester.tap(inputNilaiButton);
    await tester.pumpAndSettle();

    // 3. Verify CourseListScreen is now active
    expect(find.byType(CourseListScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CourseListScreen),
        matching: find.text('Mata Kuliah'),
      ),
      findsOneWidget,
    );
    expect(find.text('Total Kelas'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Total SKS'), findsOneWidget);
    expect(find.text('Total Mahasiswa'), findsOneWidget);
    expect(find.text('9'), findsNWidgets(2));

    // 4. Verify course offerings for L001
    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);

    // 5. Tap on "Pemrograman Mobile" card -> opens CourseDetailScreen
    await tester.tap(find.text('Pemrograman Mobile'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailScreen), findsOneWidget);
    expect(find.textContaining('IF101 • Kelas IF-44-01'), findsOneWidget);

    // 6. Navigate back to MainScreen via back action
    Navigator.of(tester.element(find.byType(CourseDetailScreen))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(CourseListScreen), findsOneWidget);

    // 7. Search for 'Rekayasa' in FTextField
    await tester.enterText(find.byType(FTextField), 'Rekayasa');
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
    expect(find.text('Pemrograman Mobile'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));

    // 8. Test switching to Jadwal tab and switching back via BottomNavigationBar
    final jadwalTab = find.text('Jadwal');
    await tester.tap(jadwalTab);
    await tester.pumpAndSettle();
    expect(find.text('Jadwal Mengajar'), findsOneWidget);

    final mataKuliahTab = find.text('Mata Kuliah');
    await tester.tap(mataKuliahTab);
    await tester.pumpAndSettle();
    expect(find.byType(CourseListScreen), findsOneWidget);
  });
}
