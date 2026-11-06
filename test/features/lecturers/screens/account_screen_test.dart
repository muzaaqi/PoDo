import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/core/widgets/stat_card.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/lecturers/screens/account_screen.dart';

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
      initialRoute: '/account_test',
      routes: {
        ...AppRoutes.routes,
        '/account_test': (context) => const AccountScreen(),
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

  testWidgets('AccountScreen displays lecturer profile details and SQLite academic stats', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Profile Info
    expect(find.text('Dr. Eng. Muhammad Rizki, M.T.'), findsOneWidget);
    expect(find.text('Ketua Program Studi'), findsOneWidget);
    expect(find.textContaining('0012058801'), findsOneWidget);
    expect(find.textContaining('Teknologi Informasi'), findsOneWidget);
    expect(find.textContaining('dosen@kampus.id'), findsOneWidget);

    // Stat cards from SQLite
    expect(find.byType(StatCard), findsNWidgets(3));
    expect(find.text('3 Kelas'), findsOneWidget);
    expect(find.text('9 SKS'), findsOneWidget);
    expect(find.text('5 Mahasiswa'), findsOneWidget);

    // Logout button
    expect(find.text('Keluar dari Akun'), findsOneWidget);
  });

  testWidgets('Tapping Keluar shows confirmation dialog and Batal cancels logout', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final logoutButton = find.text('Keluar dari Akun');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Keluar'), findsOneWidget);
    expect(find.text('Apakah Anda yakin ingin keluar dari akun?'), findsOneWidget);

    // Tap Batal
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Keluar'), findsNothing);
    expect(AuthRepository.instance.isAuthenticated, isTrue);
  });

  testWidgets('Confirming Keluar logs out active session and navigates to LoginScreen', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final logoutButton = find.text('Keluar dari Akun');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Keluar'), findsOneWidget);

    // In dialog, tap Keluar
    // There are 2 texts "Keluar" (one is button in dialog, find descendant inside dialog)
    final dialogConfirmButton = find.descendant(
      of: find.byType(FDialog),
      matching: find.text('Keluar'),
    );
    await tester.tap(dialogConfirmButton);
    await tester.pumpAndSettle();

    expect(AuthRepository.instance.isAuthenticated, isFalse);
    expect(find.text('Masuk untuk mengakses portal akademik Anda'), findsOneWidget);
  });
}
