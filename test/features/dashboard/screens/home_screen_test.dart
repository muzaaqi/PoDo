import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/dashboard/screens/home_screen.dart';

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

  Widget buildTestableWidget({void Function(int)? onSwitchTab}) {
    return MaterialApp(
      initialRoute: AppRoutes.main,
      routes: {
        ...AppRoutes.routes,
        AppRoutes.main: (context) => MainScreenScope(
          switchToTab: onSwitchTab ?? (_) {},
          child: const HomeScreen(),
        ),
      },
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  testWidgets('HomeScreen loads active lecturer and displays greeting, quick actions, and announcements',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Lecturer greeting
    expect(find.textContaining('Dr. Eng. Muhammad Rizki'), findsOneWidget);
    expect(find.text('Selamat Datang,'), findsOneWidget);

    // Quick Actions
    expect(find.text('Isi Biodata'), findsOneWidget);
    expect(find.text('Input Nilai'), findsOneWidget);
    expect(find.text('Informasi Mahasiswa'), findsOneWidget);

    // Announcements
    expect(find.textContaining('Pengumuman Kampus'), findsOneWidget);
  });

  testWidgets('Tapping Input Nilai quick action triggers switch to tab index 2', (tester) async {
    int switchedTab = -1;

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(
        onSwitchTab: (index) => switchedTab = index,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final inputNilaiButton = find.text('Input Nilai');
    expect(inputNilaiButton, findsOneWidget);

    await tester.tap(inputNilaiButton);
    await tester.pumpAndSettle();

    expect(switchedTab, 2);
  });

  testWidgets('Tapping Isi Biodata navigates to student biodata form', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final isiBiodataButton = find.text('Isi Biodata');
    expect(isiBiodataButton, findsOneWidget);

    await tester.tap(isiBiodataButton);
    await tester.pumpAndSettle();

    expect(find.text('Biodata Mahasiswa'), findsOneWidget);
  });
}
