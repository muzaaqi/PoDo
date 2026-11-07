import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/core/theme/app_theme.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';
import 'package:podo/features/schedule/widgets/schedule_form_sheet.dart';

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

  Widget buildTestableWidget({TeachingSchedule? initialSchedule, String? initialDay}) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: FToaster(
          child: FTooltipGroup(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: Scaffold(
        body: ScheduleFormSheet(
          initialSchedule: initialSchedule,
          initialDay: initialDay,
        ),
      ),
    );
  }

  testWidgets('renders create mode fields properly', (tester) async {
    await tester.pumpWidget(buildTestableWidget(initialDay: 'Senin'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Tambah Jadwal Kuliah'), findsOneWidget);
    expect(find.text('Simpan Jadwal'), findsOneWidget);
    expect(find.text('Ruangan Kuliah'), findsOneWidget);
    expect(find.text('Jam Mulai (HH:mm)'), findsOneWidget);
    expect(find.text('Jam Selesai (HH:mm)'), findsOneWidget);
  });

  testWidgets('renders edit mode with pre-populated values', (tester) async {
    TeachingSchedule? schedule;
    await tester.runAsync(() async {
      schedule = await ScheduleRepository.instance.getScheduleById(1);
    });
    expect(schedule, isNotNull);

    await tester.pumpWidget(buildTestableWidget(initialSchedule: schedule));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    expect(find.text('Edit Jadwal Kuliah'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('KU3.01'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
  });

  testWidgets('submitting form in create mode inserts new schedule', (tester) async {
    await tester.pumpWidget(buildTestableWidget(initialDay: 'Rabu'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // Enter room
    final roomField = find.byWidgetPredicate(
      (w) => w is FTextField && w.hint == 'Contoh: KU3.01 / LAB-02',
    );
    expect(roomField, findsOneWidget);
    await tester.enterText(roomField, 'LAB-ROBOTIK');
    await tester.pumpAndSettle();

    // Tap Simpan Jadwal
    final saveButton = find.text('Simpan Jadwal');
    await tester.tap(saveButton);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // Verify in database
    List<TeachingSchedule> rabuSchedules = [];
    await tester.runAsync(() async {
      rabuSchedules = await ScheduleRepository.instance.getSchedulesByLecturer('L001', dayOfWeek: 'Rabu');
    });
    expect(rabuSchedules.any((s) => s.room == 'LAB-ROBOTIK'), isTrue);
  });

  testWidgets('validates and rejects empty room and inverted time range', (tester) async {
    await tester.pumpWidget(buildTestableWidget(initialDay: 'Kamis'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // Leave room empty and tap save
    final saveButton = find.text('Simpan Jadwal');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify room error is shown
    expect(find.text('Ruangan kuliah wajib diisi.'), findsAtLeast(1));

    // Fill room and invert times
    final roomField = find.byWidgetPredicate(
      (w) => w is FTextField && w.hint == 'Contoh: KU3.01 / LAB-02',
    );
    await tester.enterText(roomField, 'KU3.05');

    final startField = find.widgetWithText(FTextField, '08:00');
    final endField = find.widgetWithText(FTextField, '10:30');
    await tester.enterText(startField, '15:00');
    await tester.enterText(endField, '13:00');
    await tester.pumpAndSettle();

    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify time validation error is shown
    expect(find.text('Jam selesai harus lebih akhir daripada jam mulai.'), findsAtLeast(1));
    expect(find.byType(ScheduleFormSheet), findsOneWidget);
  });
}
