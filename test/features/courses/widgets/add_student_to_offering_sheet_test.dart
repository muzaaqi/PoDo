import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/widgets/add_student_to_offering_sheet.dart';

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
  );

  Widget buildTestableWidget({
    CourseOffering offering = testOffering,
    Set<String> enrolledNims = const {'2101001', '2101002', '2101003'},
  }) {
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
        body: AddStudentToOfferingSheet(
          offering: offering,
          enrolledNims: enrolledNims,
        ),
      ),
    );
  }

  group('AddStudentToOfferingSheet Widget Tests', () {
    testWidgets('renders title, offering name, and available unenrolled students', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Tambah Mahasiswa ke Kelas'), findsOneWidget);
      expect(find.textContaining('Pemrograman Mobile • Kelas IF-44-01'), findsOneWidget);
      expect(find.text('Pilih Mahasiswa'), findsOneWidget);
      expect(find.text('Tambahkan ke Kelas'), findsOneWidget);

      // Dewi Lestari (2101004) should be available and selected initially
      expect(find.textContaining('Dewi Lestari'), findsWidgets);
      expect(find.textContaining('2101004'), findsWidgets);
    });

    testWidgets('shows empty state when all students in database are already enrolled', (tester) async {
      // Pass all 5 seed student NIMs as already enrolled
      await tester.pumpWidget(
        buildTestableWidget(
          enrolledNims: {'2101001', '2101002', '2101003', '2101004', '2101005'},
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      expect(find.text('Tidak Ada Mahasiswa Tersedia'), findsOneWidget);
      expect(find.text('Buat Biodata Mahasiswa Baru'), findsOneWidget);
      expect(find.text('Tambahkan ke Kelas'), findsNothing);
    });
  });
}
