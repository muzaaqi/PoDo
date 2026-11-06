import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/main_screen.dart';
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
    );
  }

  testWidgets('Integration flow: Active lecturer L001 views and filters teaching schedules via MainScreen tabs',
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

    // 2. Tap on "Jadwal" tab on bottom navigation
    final jadwalTab = find.descendant(
      of: find.byType(FBottomNavigationBar),
      matching: find.text('Jadwal'),
    );
    expect(jadwalTab, findsOneWidget);
    await tester.tap(jadwalTab);
    await tester.pumpAndSettle();

    // 3. Verify ScheduleScreen is now displayed
    expect(find.byType(ScheduleScreen), findsOneWidget);
    expect(find.text('Jadwal Mengajar'), findsOneWidget);

    // 4. Default day is Senin -> Displays Monday classes
    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.textContaining('KU3.01'), findsOneWidget);
    expect(find.text('3 SKS'), findsWidgets);
    expect(find.textContaining('08:00 - 10:30'), findsOneWidget);

    // 5. Tap Selasa tab -> Updates to Tuesday class
    await tester.tap(find.text('Selasa'));
    await tester.pumpAndSettle();

    expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
    expect(find.textContaining('KU3.05'), findsOneWidget);
    expect(find.textContaining('09:30 - 12:00'), findsOneWidget);

    // 6. Tap Rabu tab -> Displays empty state
    await tester.tap(find.text('Rabu'));
    await tester.pumpAndSettle();

    expect(find.text('Tidak Ada Jadwal Mengajar'), findsOneWidget);
    expect(find.textContaining('Tidak ada perkuliahan pada hari Rabu'), findsOneWidget);

    // 7. Tap Kamis tab -> Displays Thursday class
    await tester.tap(find.text('Kamis'));
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.textContaining('KU3.02'), findsOneWidget);
    expect(find.textContaining('13:00 - 15:30'), findsOneWidget);
  });

  testWidgets('Integration flow: Lecturer L002 views Wednesday schedule and Monday empty state',
      (tester) async {
    await tester.runAsync(() async {
      await AuthRepository.instance.login('siti@kampus.id', 'password123');
    });

    await tester.pumpWidget(buildApp());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // Switch to Jadwal tab
    final jadwalTab = find.descendant(
      of: find.byType(FBottomNavigationBar),
      matching: find.text('Jadwal'),
    );
    await tester.tap(jadwalTab);
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleScreen), findsOneWidget);

    // Monday (default) is empty for L002
    expect(find.text('Tidak Ada Jadwal Mengajar'), findsOneWidget);

    // Switch to Rabu -> Displays L002's classes: Basis Data Lanjut
    await tester.tap(find.text('Rabu'));
    await tester.pumpAndSettle();

    expect(find.text('Basis Data Lanjut'), findsWidgets);
    expect(find.textContaining('KU2.04'), findsOneWidget);
    expect(find.text('4 SKS'), findsWidgets);
    expect(find.textContaining('08:00 - 11:20'), findsOneWidget);
  });
}
