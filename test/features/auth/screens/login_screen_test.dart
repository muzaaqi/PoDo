import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/auth/screens/login_screen.dart';

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
    await AuthRepository.instance.logout();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  testWidgets('LoginScreen shows validation error when submitting empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: FToaster(
            child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
          ),
        ),
        home: const LoginScreen(),
      ),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(FAlert), findsOneWidget);
    expect(find.text('Email dan password tidak boleh kosong.'), findsOneWidget);
  });

  testWidgets('LoginScreen renders fields, shows error on failure, and navigates on success', (WidgetTester tester) async {
    bool navigatedToMain = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: FToaster(
            child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
          ),
        ),
        routes: {
          '/': (context) => const LoginScreen(),
          AppRoutes.main: (context) {
            navigatedToMain = true;
            return const Scaffold(body: Text('Main Screen'));
          },
        },
      ),
    );

    // Verify fields and button exist
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(FTextField), findsWidgets);

    // 1. Enter invalid credentials
    await tester.enterText(find.byType(EditableText).first, 'wrong@kampus.id');
    await tester.enterText(find.byType(EditableText).last, 'wrongpass');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();

    // Verify error alert is shown
    expect(find.byType(FAlert), findsOneWidget);
    expect(find.text('Email atau password tidak sesuai.'), findsOneWidget);
    expect(navigatedToMain, isFalse);

    // 2. Enter valid credentials
    await tester.enterText(find.byType(EditableText).first, 'dosen@kampus.id');
    await tester.enterText(find.byType(EditableText).last, 'password123');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();

    // Verify navigated to /main
    expect(navigatedToMain, isTrue);
  });
}
