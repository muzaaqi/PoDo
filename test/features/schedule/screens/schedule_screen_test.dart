import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/screens/course_detail_screen.dart';
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

  Widget buildTestableWidget({DateTime? currentDateTime}) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: ScheduleScreen(currentDateTime: currentDateTime),
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

    // Monday schedules for L001 (minimal 2 classes):
    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Kelas IF-44-01'), findsOneWidget);
    expect(find.text('3 SKS'), findsWidgets);
    expect(find.textContaining('08:00 - 10:30'), findsOneWidget);
    expect(find.textContaining('KU3.01'), findsOneWidget);
    expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);
    expect(find.textContaining('13:00 - 15:30'), findsOneWidget);
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

  testWidgets('Tapping Sabtu tab displays Saturday schedule at 07:00 - 09:30', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final sabtuTab = find.text('Sabtu');
    expect(sabtuTab, findsOneWidget);
    await tester.tap(sabtuTab);
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Kelas IF-44-01'), findsOneWidget);
    expect(find.textContaining('07:00 - 09:30'), findsOneWidget);
    expect(find.textContaining('KU3.01'), findsOneWidget);
  });

  testWidgets('Tapping Jumat tab displays all 3 Friday classes with real-time status', (tester) async {
    final fridayAfternoon = DateTime(2026, 11, 6, 17, 30);
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: fridayAfternoon));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final jumatTab = find.text('Jumat');
    expect(jumatTab, findsOneWidget);
    await tester.tap(jumatTab);
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Sistem Terdistribusi'), findsOneWidget);
    expect(find.text('Rekayasa Perangkat Lunak'), findsOneWidget);

    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.byType(FDeterminateProgress), findsOneWidget);
    expect(find.textContaining('Tersisa'), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
    expect(find.text('Berlangsung'), findsNothing);
    expect(find.text('Selesai'), findsNothing);
    expect(find.textContaining('Waktu Berjalan'), findsNothing);
  });

  testWidgets('Tapping schedule card navigates to CourseDetailScreen', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/schedule_test',
        routes: {
          ...AppRoutes.routes,
          '/schedule_test': (context) => const ScheduleScreen(),
        },
        builder: (context, child) => FTheme(
          data: AppTheme.lightTheme,
          child: FToaster(
            child: FTooltipGroup(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final card = find.text('Pemrograman Mobile');
    expect(card, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(card);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
    });
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailScreen), findsOneWidget);
  });

  testWidgets('ScheduleScreen displays live ongoing progress and timeline node for active class', (tester) async {
    // Monday at 09:00 (Pemrograman Mobile is 08:00 - 10:30)
    final mondayMorning = DateTime(2026, 11, 2, 9, 0);
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: mondayMorning));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.byType(FDeterminateProgress), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
    expect(find.textContaining('Tersisa'), findsOneWidget);
    expect(find.text('Berlangsung'), findsNothing);
    expect(find.textContaining('Waktu Berjalan'), findsNothing);

    final scheduleSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('Sedang berlangsung'),
    );
    expect(scheduleSemantics, findsWidgets);
  });

  testWidgets('ScheduleScreen displays completed status on timeline for past class', (tester) async {
    // Monday at 12:00 (Pemrograman Mobile 08:00 - 10:30 has ended)
    final mondayAfternoon = DateTime(2026, 11, 2, 12, 0);
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: mondayAfternoon));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.text('Selesai'), findsNothing);

    final scheduleSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('Kelas telah selesai'),
    );
    expect(scheduleSemantics, findsWidgets);
  });

  testWidgets('ScheduleScreen displays upcoming status for future class', (tester) async {
    // Monday at 07:00 (Pemrograman Mobile starts at 08:00)
    final mondayEarly = DateTime(2026, 11, 2, 7, 0);
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: mondayEarly));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Berlangsung'), findsNothing);
    expect(find.text('Selesai'), findsNothing);
    expect(find.textContaining('Waktu Berjalan'), findsNothing);
  });

  testWidgets('ScheduleScreen is pure read-only with no add button in header', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.byIcon(FLucideIcons.plus), findsNothing);
  });

  testWidgets('Schedule cards are pure read-only with no pencil or trash action icons', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.byIcon(FLucideIcons.pencil), findsNothing);
    expect(find.byIcon(FLucideIcons.trash2), findsNothing);
  });
}
