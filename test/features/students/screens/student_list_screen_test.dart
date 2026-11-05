import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';
import 'package:podo/features/students/screens/student_list_screen.dart';

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

  Widget buildTestableWidget() {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const StudentListScreen(),
    );
  }

  testWidgets('StudentListScreen displays all seeded students', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Daftar Mahasiswa'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Citra Dewi'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Eko Prasetyo'), findsOneWidget);
  });

  testWidgets('Searching by name or NIM filters the list', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    final searchField = find.byType(FTextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'Dewi');
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Citra Dewi'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsNothing);
  });

  testWidgets('Empty state is shown when search yields no results', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    final searchField = find.byType(FTextField);
    await tester.enterText(searchField, 'ZzzTidakAda');
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Mahasiswa tidak ditemukan'), findsOneWidget);
  });

  testWidgets('Tapping add button on header navigates to StudentBiodataFormScreen in create mode',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    final addButton = find.byIcon(FLucideIcons.userPlus);
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);
  });

  testWidgets('Tapping a student card opens StudentBiodataFormScreen in edit mode', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    final ahmadCard = find.text('Ahmad Fauzi');
    expect(ahmadCard, findsOneWidget);

    await tester.tap(ahmadCard);
    await tester.pumpAndSettle();

    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Edit Biodata Mahasiswa'), findsOneWidget);
    expect(find.text('2101001'), findsOneWidget);
  });
}
