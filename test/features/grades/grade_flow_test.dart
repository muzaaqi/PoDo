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
import 'package:podo/features/grades/models/grade.dart';
import 'package:podo/features/grades/repositories/grade_repository.dart';
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

  testWidgets(
      'End-to-end integration flow: Home -> CourseList -> CourseDetail -> Grade Sheet Input -> Update SQLite -> Re-edit',
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

    // 1. Initial tab is Home
    expect(find.text('Selamat Datang,'), findsOneWidget);

    // 2. Tap Quick Action "Input Nilai" -> switches to CourseListScreen
    final inputNilaiAction = find.text('Input Nilai');
    expect(inputNilaiAction, findsOneWidget);
    await tester.ensureVisible(inputNilaiAction);
    await tester.tap(inputNilaiAction);
    await tester.pumpAndSettle();

    expect(find.byType(CourseListScreen), findsOneWidget);

    // 3. Tap "Pemrograman Mobile" class card -> opens CourseDetailScreen
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
    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.textContaining('Kelas IF-44-01'), findsOneWidget);
    expect(find.text('3 SKS'), findsOneWidget);

    // 4. Verify initial progress & student roster: 3 students, all Belum Dinilai
    expect(find.text('Progress Penilaian'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FBadge),
        matching: find.text('Belum Dinilai'),
      ),
      findsNWidgets(3),
    );

    // 5. Tap Ahmad Fauzi -> opens GradeInputBottomSheet
    await tester.tap(find.text('Ahmad Fauzi'));
    await tester.pumpAndSettle();

    expect(find.byType(GradeInputBottomSheet), findsOneWidget);
    expect(find.text('Penilaian CPMK Mahasiswa'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(GradeInputBottomSheet),
        matching: find.textContaining('Ahmad Fauzi'),
      ),
      findsOneWidget,
    );

    // 6. Enter CPMK 1-4
    final fields = find.descendant(
      of: find.byType(GradeInputBottomSheet),
      matching: find.byType(FTextField),
    );
    await tester.enterText(fields.at(0), '85');
    await tester.enterText(fields.at(1), '90');
    await tester.enterText(fields.at(2), '78');
    await tester.enterText(fields.at(3), '88');
    await tester.pumpAndSettle();

    // 7. Save grade
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

    // 8. Verify sheet closed & Ahmad Fauzi is now "Sudah Dinilai"
    expect(find.byType(GradeInputBottomSheet), findsNothing);
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

    // 9. Tap Ahmad Fauzi again to edit -> Verify pre-filled values
    await tester.tap(find.text('Ahmad Fauzi'));
    await tester.pumpAndSettle();

    expect(find.byType(GradeInputBottomSheet), findsOneWidget);
    expect(find.text('85'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('88'), findsOneWidget);

    // 10. Update CPMK 1 to 95 and save
    final editFields = find.descendant(
      of: find.byType(GradeInputBottomSheet),
      matching: find.byType(FTextField),
    );
    await tester.enterText(editFields.at(0), '95');
    await tester.pumpAndSettle();

    final updateButton = find.text('Simpan Nilai');
    await tester.ensureVisible(updateButton);
    await tester.tap(updateButton);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.byType(GradeInputBottomSheet), findsNothing);

    // 11. Verify persisted update in SQLite
    Grade? persistedGrade;
    await tester.runAsync(() async {
      persistedGrade = await GradeRepository.instance.getGradeByEnrollmentId(1);
    });
    expect(persistedGrade, isNotNull);
    expect(persistedGrade!.cpmk1, 95.0);
    expect(persistedGrade!.cpmk2, 90.0);
    expect(persistedGrade!.cpmk3, 78.0);
    expect(persistedGrade!.cpmk4, 88.0);

    // 12. Navigate back to CourseListScreen
    Navigator.of(tester.element(find.byType(CourseDetailScreen))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(CourseListScreen), findsOneWidget);
  });
}
