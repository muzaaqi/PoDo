import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

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
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('ScheduleRepository', () {
    test('getSchedulesByLecturer returns all schedules sorted by day and time for L001', () async {
      final schedules = await ScheduleRepository.instance.getSchedulesByLecturer('L001');

      expect(schedules.length, 6);

      // Verify order: Senin -> Selasa -> Kamis -> Jumat
      expect(schedules[0].dayOfWeek, 'Senin');
      expect(schedules[0].courseCode, 'IF101');
      expect(schedules[0].courseName, 'Pemrograman Mobile');
      expect(schedules[0].room, 'KU3.01');
      expect(schedules[0].startTime, '08:00');
      expect(schedules[0].endTime, '10:30');
      expect(schedules[0].credits, 3);
      expect(schedules[0].className, 'IF-44-01');

      expect(schedules[1].dayOfWeek, 'Selasa');
      expect(schedules[1].courseCode, 'IF102');
      expect(schedules[1].courseName, 'Rekayasa Perangkat Lunak');
      expect(schedules[1].room, 'KU3.05');
      expect(schedules[1].startTime, '09:30');

      expect(schedules[2].dayOfWeek, 'Kamis');
      expect(schedules[2].courseCode, 'IF101');
      expect(schedules[2].room, 'KU3.02');
      expect(schedules[2].startTime, '13:00');

      expect(schedules[3].dayOfWeek, 'Jumat');
      expect(schedules[3].courseCode, 'IF101');
      expect(schedules[3].startTime, '13:30');

      expect(schedules[4].dayOfWeek, 'Jumat');
      expect(schedules[4].courseCode, 'IF103');
      expect(schedules[4].courseName, 'Sistem Terdistribusi');
      expect(schedules[4].startTime, '16:30');

      expect(schedules[5].dayOfWeek, 'Jumat');
      expect(schedules[5].courseCode, 'IF102');
      expect(schedules[5].startTime, '19:30');
    });

    test('getSchedulesByLecturer with dayOfWeek filters by day', () async {
      final seninSchedules = await ScheduleRepository.instance.getSchedulesByLecturer(
        'L001',
        dayOfWeek: 'Senin',
      );
      expect(seninSchedules.length, 1);
      expect(seninSchedules.first.dayOfWeek, 'Senin');
      expect(seninSchedules.first.courseName, 'Pemrograman Mobile');

      final rabuSchedules = await ScheduleRepository.instance.getSchedulesByLecturer(
        'L001',
        dayOfWeek: 'Rabu',
      );
      expect(rabuSchedules, isEmpty);
    });

    test('getSchedulesByLecturer returns schedules belonging strictly to requested lecturer', () async {
      final l002Schedules = await ScheduleRepository.instance.getSchedulesByLecturer('L002');

      expect(l002Schedules.length, 1);
      expect(l002Schedules.first.courseCode, 'SI101');
      expect(l002Schedules.first.courseName, 'Basis Data Lanjut');
      expect(l002Schedules.first.dayOfWeek, 'Rabu');
      expect(l002Schedules.first.room, 'KU2.04');
    });

    test('getScheduleById returns schedule when found and null when not found', () async {
      final schedule = await ScheduleRepository.instance.getScheduleById(1);
      expect(schedule, isNotNull);
      expect(schedule!.id, 1);
      expect(schedule.offeringId, 'OFF001');
      expect(schedule.courseCode, 'IF101');

      final notFound = await ScheduleRepository.instance.getScheduleById(9999);
      expect(notFound, isNull);
    });

    test('createSchedule inserts a new schedule into SQLite', () async {
      final newId = await ScheduleRepository.instance.createSchedule(
        offeringId: 'OFF001',
        dayOfWeek: 'Sabtu',
        room: 'LAB-02',
        startTime: '08:00',
        endTime: '10:00',
      );
      expect(newId, isPositive);

      final sabtuSchedules = await ScheduleRepository.instance.getSchedulesByLecturer(
        'L001',
        dayOfWeek: 'Sabtu',
      );
      expect(sabtuSchedules.length, 1);
      expect(sabtuSchedules.first.room, 'LAB-02');
    });
  });
}
