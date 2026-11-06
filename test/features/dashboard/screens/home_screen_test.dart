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
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';

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

  Widget buildTestableWidget({
    void Function(int)? onSwitchTab,
    DateTime? currentDateTime,
  }) {
    return MaterialApp(
      initialRoute: AppRoutes.main,
      routes: {
        ...AppRoutes.routes,
        AppRoutes.main: (context) => MainScreenScope(
          switchToTab: onSwitchTab ?? (_) {},
          child: HomeScreen(currentDateTime: currentDateTime),
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

    // Verify no 'Portal Dosen' title or search bar on HomeScreen
    expect(find.text('Portal Dosen'), findsNothing);
    expect(find.byType(FTextField), findsNothing);

    // Lecturer greeting
    expect(find.textContaining('Dr. Eng. Muhammad Rizki'), findsOneWidget);
    expect(find.text('Selamat Datang,'), findsOneWidget);

    // Quick Actions
    expect(find.text('Isi Biodata'), findsOneWidget);
    expect(find.text('Input Nilai'), findsOneWidget);
    expect(find.text('Mahasiswa'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsNothing);

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
    await tester.ensureVisible(inputNilaiButton);
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
    await tester.ensureVisible(isiBiodataButton);
    await tester.tap(isiBiodataButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentBiodataFormScreen), findsOneWidget);
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);
  });

  testWidgets('Tapping notification bell opens notification sheet and can be closed', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final bellButton = find.bySemanticsLabel('Notifikasi kampus');
    expect(bellButton, findsOneWidget);
    await tester.tap(bellButton);
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi & Pengumuman'), findsOneWidget);
    expect(find.text('Batas Akhir Penginputan Nilai CPMK Semester Ganjil'), findsWidgets);

    // Tap close
    final closeIcon = find.byIcon(FLucideIcons.x);
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi & Pengumuman'), findsNothing);
  });

  testWidgets('Hero schedule card displays ongoing class when within scheduled time', (tester) async {
    // 2026-11-02 was a Monday, 09:00 is within 08:00 - 10:30
    final mondayMorning = DateTime(2026, 11, 2, 9, 0);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: mondayMorning));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Hari Ini'), findsOneWidget);
    expect(find.text('Pemrograman Mobile'), findsAtLeastNWidgets(1));
    expect(find.text('Berlangsung'), findsNothing);
    expect(find.textContaining('Waktu Berjalan'), findsNothing);
    expect(find.textContaining('Tersisa'), findsOneWidget);
    expect(find.byType(FDeterminateProgress), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);

    final heroScheduleSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.startsWith('Jadwal sekarang:'),
    );
    expect(heroScheduleSemantics, findsOneWidget);
  });

  testWidgets('Tapping schedule card navigates to CourseDetailScreen', (tester) async {
    final mondayMorning = DateTime(2026, 11, 2, 9, 0);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: mondayMorning));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Tap the ongoing card
    final cardFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.startsWith('Jadwal sekarang:'),
    );
    expect(cardFinder, findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(cardFinder);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // Verify CourseDetailScreen is opened
    expect(find.text('Progress Penilaian'), findsOneWidget);
  });

  testWidgets('Tapping Lihat Semua in schedule header switches to Jadwal tab (index 1)', (tester) async {
    int? selectedTab;
    final mondayMorning = DateTime(2026, 11, 2, 9, 0);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(
        currentDateTime: mondayMorning,
        onSwitchTab: (index) => selectedTab = index,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final lihatSemuaFinder = find.text('Lihat Semua');
    expect(lihatSemuaFinder, findsOneWidget);
    await tester.tap(lihatSemuaFinder);
    await tester.pumpAndSettle();

    expect(selectedTab, equals(1));
  });

  testWidgets('Friday has multiple schedules: displays stacked card deck with dots only and supports swipe', (tester) async {
    // 2026-11-06 was a Friday, 14:00 is within Friday 13:30 - 16:00
    final fridayAfternoon = DateTime(2026, 11, 6, 14, 0);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: fridayAfternoon));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Header and ongoing course
    expect(find.text('Jadwal Hari Ini'), findsOneWidget);
    expect(find.text('Pemrograman Mobile'), findsAtLeastNWidgets(1));

    // Verify dots are present (Friday has 3 classes: dot 1, dot 2, dot 3)
    expect(find.bySemanticsLabel('Jadwal ke-1'), findsOneWidget);
    expect(find.bySemanticsLabel('Jadwal ke-2'), findsOneWidget);
    expect(find.bySemanticsLabel('Jadwal ke-3'), findsOneWidget);

    // Verify chevron buttons are NOT present (cukup dots aja)
    expect(find.bySemanticsLabel('Jadwal berikutnya'), findsNothing);
    expect(find.bySemanticsLabel('Jadwal sebelumnya'), findsNothing);

    // Tap dot 2 to navigate to next class today (Sistem Terdistribusi 16:30 - 19:00)
    await tester.tap(find.bySemanticsLabel('Jadwal ke-2'));
    await tester.pumpAndSettle();
    expect(find.text('Sistem Terdistribusi'), findsAtLeastNWidgets(1));

    // Drag left to swipe to the third class today (Rekayasa Perangkat Lunak 19:30 - 21:00)
    final cardFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('Sistem Terdistribusi'),
    );
    await tester.drag(cardFinder, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Rekayasa Perangkat Lunak'), findsAtLeastNWidgets(1));
  });

  testWidgets('Sunday has no schedules: renders empty state card', (tester) async {
    // 2026-11-08 was a Sunday
    final sunday = DateTime(2026, 11, 8, 10, 0);

    await tester.runAsync(() async {
      await tester.pumpWidget(buildTestableWidget(currentDateTime: sunday));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Hari Ini'), findsOneWidget);
    expect(find.text('Tidak Ada Jadwal Hari Ini'), findsOneWidget);
    expect(find.textContaining('tidak ada perkuliahan yang terjadwal untuk hari ini'), findsOneWidget);
  });
}
