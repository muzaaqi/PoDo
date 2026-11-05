import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/schedule/screens/schedule_screen.dart';

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
      home: const ScheduleScreen(),
    );
  }

  testWidgets('ScheduleScreen displays header and all day tabs', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Mengajar'), findsOneWidget);
    expect(find.text('Senin'), findsOneWidget);
    expect(find.text('Selasa'), findsOneWidget);
    expect(find.text('Rabu'), findsOneWidget);
    expect(find.text('Kamis'), findsOneWidget);
    expect(find.text('Jumat'), findsOneWidget);
    expect(find.text('Sabtu'), findsOneWidget);
  });

  testWidgets('Displays schedules for active lecturer on default tab (Senin)', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Monday schedule for L001: Pemrograman Mobile, IF-44-01, KU3.01, 08:00 - 10:30, 3 SKS
    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.textContaining('IF101'), findsOneWidget);
    expect(find.textContaining('IF-44-01'), findsOneWidget);
    expect(find.text('3 SKS'), findsOneWidget);
    expect(find.textContaining('08:00 - 10:30'), findsOneWidget);
    expect(find.textContaining('KU3.01'), findsOneWidget);
  });

  testWidgets('Tapping Selasa tab updates list to Tuesday schedule', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final selasaTab = find.text('Selasa');
    expect(selasaTab, findsOneWidget);
    await tester.tap(selasaTab);
    await tester.pumpAndSettle();

    // Tuesday schedule for L001: Rekayasa Perangkat Lunak, KU3.05, 09:30 - 12:00
    expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
    expect(find.textContaining('KU3.05'), findsOneWidget);
    expect(find.textContaining('09:30 - 12:00'), findsOneWidget);
  });

  testWidgets('Tapping Rabu tab displays empty state when no classes exist', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final rabuTab = find.text('Rabu');
    expect(rabuTab, findsOneWidget);
    await tester.tap(rabuTab);
    await tester.pumpAndSettle();

    expect(find.text('Tidak Ada Jadwal Mengajar'), findsOneWidget);
    expect(find.textContaining('Tidak ada perkuliahan pada hari Rabu'), findsOneWidget);
  });

  testWidgets('Tapping Kamis tab displays Thursday schedule', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final kamisTab = find.text('Kamis');
    expect(kamisTab, findsOneWidget);
    await tester.tap(kamisTab);
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.textContaining('KU3.02'), findsOneWidget);
    expect(find.textContaining('13:00 - 15:30'), findsOneWidget);
  });
}
