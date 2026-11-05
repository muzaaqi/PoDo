import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/courses/screens/course_list_screen.dart';
import 'package:podo/features/dashboard/screens/home_screen.dart';
import 'package:podo/features/lecturers/screens/account_screen.dart';
import 'package:podo/features/schedule/screens/schedule_screen.dart';

void main() {
  testWidgets('MainScreen renders 4 tabs in strict order and switches views on selection', (WidgetTester tester) async {
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
        home: const MainScreen(),
      ),
    );

    final bottomNav = find.byType(FBottomNavigationBar);
    expect(bottomNav, findsOneWidget);

    // Verify all 4 tabs exist in bottom navigation in strict order
    final homeTab = find.descendant(of: bottomNav, matching: find.text('Home'));
    final jadwalTab = find.descendant(of: bottomNav, matching: find.text('Jadwal'));
    final matkulTab = find.descendant(of: bottomNav, matching: find.text('Mata Kuliah'));
    final akunTab = find.descendant(of: bottomNav, matching: find.text('Akun'));

    expect(homeTab, findsOneWidget);
    expect(jadwalTab, findsOneWidget);
    expect(matkulTab, findsOneWidget);
    expect(akunTab, findsOneWidget);

    // Initial tab is Home
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ScheduleScreen), findsNothing);

    // Switch to Jadwal (Tab index 1)
    await tester.tap(jadwalTab);
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    // Switch to Mata Kuliah (Tab index 2)
    await tester.tap(matkulTab);
    await tester.pumpAndSettle();
    expect(find.byType(CourseListScreen), findsOneWidget);
    expect(find.byType(ScheduleScreen), findsNothing);

    // Switch to Akun (Tab index 3)
    await tester.tap(akunTab);
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.byType(CourseListScreen), findsNothing);
  });
}
