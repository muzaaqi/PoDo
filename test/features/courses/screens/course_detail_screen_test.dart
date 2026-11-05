import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/core/widgets/stat_card.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/screens/course_detail_screen.dart';
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
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Mobile'), findsOneWidget);
      expect(find.textContaining('IF101'), findsOneWidget);
      expect(find.textContaining('IF-44-01'), findsOneWidget);
      expect(find.text('3 SKS'), findsOneWidget);
      expect(find.textContaining('2024/2025'), findsOneWidget);
    });

    testWidgets('displays 3 academic stat metrics for OFF001 initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(StatCard),
          matching: find.text('Total Mahasiswa'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StatCard),
          matching: find.text('Sudah Dinilai'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StatCard),
          matching: find.text('Belum Dinilai'),
        ),
        findsOneWidget,
      );

      expect(find.text('3'), findsNWidgets(2)); // Total: 3, Belum: 3
      expect(find.text('0'), findsOneWidget); // Sudah: 0
    });

    testWidgets('displays enrolled student roster with Belum Dinilai badge initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
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
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ahmad Fauzi'));
      await tester.pumpAndSettle();

      expect(find.byType(GradeInputBottomSheet), findsOneWidget);
      expect(find.text('Penilaian CPMK Mahasiswa'), findsOneWidget);
    });

    testWidgets('submitting grades in sheet updates student status to Sudah Dinilai and refreshes stat metrics',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Tap Ahmad Fauzi
      await tester.tap(find.text('Ahmad Fauzi'));
      await tester.pumpAndSettle();

      // Fill CPMK fields
      final fields = find.byType(FTextField);
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
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
