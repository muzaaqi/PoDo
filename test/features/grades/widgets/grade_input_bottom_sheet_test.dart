import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/grades/models/enrolled_student.dart';
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
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  Widget buildTestableWidget(EnrolledStudent student) {
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
        body: GradeInputBottomSheet(student: student),
      ),
    );
  }

  group('GradeInputBottomSheet Widget Tests', () {
    testWidgets('renders student info, 4 CPMK fields, and action buttons', (tester) async {
      const student = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Fauzi',
      );

      await tester.pumpWidget(buildTestableWidget(student));
      await tester.pumpAndSettle();

      expect(find.text('Penilaian CPMK Mahasiswa'), findsOneWidget);
      expect(find.textContaining('Ahmad Fauzi'), findsOneWidget);
      expect(find.textContaining('2101001'), findsOneWidget);

      expect(find.text('CPMK 1'), findsOneWidget);
      expect(find.text('CPMK 2'), findsOneWidget);
      expect(find.text('CPMK 3'), findsOneWidget);
      expect(find.text('CPMK 4'), findsOneWidget);

      expect(find.text('Simpan Nilai'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('pre-fills CPMK fields when student already has a grade', (tester) async {
      const student = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Fauzi',
        grade: Grade(
          id: 10,
          enrollmentId: 1,
          cpmk1: 85.0,
          cpmk2: 90.0,
          cpmk3: 75.0,
          cpmk4: 88.0,
        ),
      );

      await tester.pumpWidget(buildTestableWidget(student));
      await tester.pumpAndSettle();

      expect(find.text('85'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('88'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty or out of 0-100 range', (tester) async {
      const student = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Fauzi',
      );

      await tester.pumpWidget(buildTestableWidget(student));
      await tester.pumpAndSettle();

      // Submit with empty fields
      await tester.tap(find.text('Simpan Nilai'));
      await tester.pumpAndSettle();

      expect(find.text('Nilai CPMK harus diisi'), findsNWidgets(4));

      // Enter invalid range (< 0 and > 100)
      final fields = find.byType(FTextField);
      await tester.enterText(fields.at(0), '-5');
      await tester.enterText(fields.at(1), '105');
      await tester.enterText(fields.at(2), 'abc');
      await tester.enterText(fields.at(3), '80');

      await tester.tap(find.text('Simpan Nilai'));
      await tester.pumpAndSettle();

      expect(find.text('Nilai harus antara 0 - 100'), findsNWidgets(2));
      expect(find.text('Nilai harus berupa angka valid'), findsOneWidget);
    });

    testWidgets('submits valid grades to GradeRepository and pops route', (tester) async {
      const student = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Fauzi',
      );

      bool? popResult;

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
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    popResult = await Navigator.of(context).push<bool>(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const Scaffold(
                          body: GradeInputBottomSheet(student: student),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final fields = find.byType(FTextField);
      await tester.enterText(fields.at(0), '85');
      await tester.enterText(fields.at(1), '90');
      await tester.enterText(fields.at(2), '78');
      await tester.enterText(fields.at(3), '88');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Nilai'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(popResult, isTrue);

      // Verify persisted in SQLite
      Grade? savedGrade;
      await tester.runAsync(() async {
        savedGrade = await GradeRepository.instance.getGradeByEnrollmentId(1);
      });
      expect(savedGrade, isNotNull);
      expect(savedGrade!.cpmk1, 85.0);
      expect(savedGrade!.cpmk2, 90.0);
      expect(savedGrade!.cpmk3, 78.0);
      expect(savedGrade!.cpmk4, 88.0);
    });

    testWidgets('shows Reset Nilai button when student is graded and resets grade upon confirmation', (tester) async {
      // First insert grade in DB
      const existingGrade = Grade(
        id: 1,
        enrollmentId: 1,
        cpmk1: 85.0,
        cpmk2: 90.0,
        cpmk3: 78.0,
        cpmk4: 88.0,
      );
      await tester.runAsync(() async {
        await GradeRepository.instance.upsertGrade(existingGrade);
      });

      const student = EnrolledStudent(
        enrollmentId: 1,
        offeringId: 'OFF001',
        studentNim: '2101001',
        studentName: 'Ahmad Fauzi',
        grade: existingGrade,
      );

      bool? popResult;
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
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    popResult = await Navigator.of(context).push<bool>(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const Scaffold(
                          body: GradeInputBottomSheet(student: student),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Reset button should be visible
      final resetButton = find.text('Reset Nilai');
      expect(resetButton, findsOneWidget);

      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Reset Nilai Mahasiswa?'), findsOneWidget);

      // Tap confirm button in dialog (the one inside dialog action)
      final dialogResetAction = find.descendant(
        of: find.byType(FDialog),
        matching: find.text('Reset Nilai'),
      );
      await tester.tap(dialogResetAction);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(popResult, isTrue);

      // Verify grade removed from SQLite
      Grade? deletedGrade;
      await tester.runAsync(() async {
        deletedGrade = await GradeRepository.instance.getGradeByEnrollmentId(1);
      });
      expect(deletedGrade, isNull);
    });
  });
}
