import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/app.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';
import 'package:podo/features/students/screens/student_list_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.instance.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  test('AppRoutes contains student routes', () {
    expect(AppRoutes.studentList, '/students');
    expect(AppRoutes.studentBiodataForm, '/students/form');

    expect(AppRoutes.routes[AppRoutes.studentList], isNotNull);
    expect(AppRoutes.routes[AppRoutes.studentBiodataForm], isNotNull);
  });

  testWidgets('Navigating to studentList route builds StudentListScreen', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PoDoApp(initialRoute: AppRoutes.studentList));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.byType(StudentListScreen), findsOneWidget);
    expect(find.text('Daftar Mahasiswa'), findsOneWidget);
  });

  testWidgets('Navigating to studentBiodataForm route builds StudentBiodataFormScreen', (tester) async {
    await tester.pumpWidget(const PoDoApp(initialRoute: AppRoutes.studentBiodataForm));
    await tester.pumpAndSettle();

    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);
  });

  testWidgets('MainScreen allows switching tabs programmatically via MainScreenScope', (tester) async {
    await tester.pumpWidget(
      const PoDoApp(initialRoute: AppRoutes.main),
    );
    await tester.pumpAndSettle();

    final BuildContext homeContext = tester.element(find.text('Home').first);
    final scope = MainScreenScope.of(homeContext);
    expect(scope, isNotNull);

    scope!.switchToTab(2);
    await tester.pumpAndSettle();

    expect(find.text('Mata Kuliah'), findsWidgets);
  });
}
