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

      expect(schedules.length, 10);

      // Verify order: Senin -> Selasa -> Kamis -> Jumat -> Sabtu
      expect(schedules[0].dayOfWeek, 'Senin');
      expect(schedules[0].courseCode, 'IF101');
      expect(schedules[0].courseName, 'Pemrograman Mobile');
      expect(schedules[0].room, 'KU3.01');
      expect(schedules[0].startTime, '08:00');
      expect(schedules[0].endTime, '10:30');
      expect(schedules[0].credits, 3);
      expect(schedules[0].className, 'IF-44-01');

      expect(schedules[1].dayOfWeek, 'Senin');
      expect(schedules[1].courseCode, 'IF102');
      expect(schedules[1].courseName, 'Rekayasa Perangkat Lunak');
      expect(schedules[1].room, 'KU3.05');
      expect(schedules[1].startTime, '13:00');

      expect(schedules[2].dayOfWeek, 'Selasa');
      expect(schedules[2].courseCode, 'IF102');
      expect(schedules[2].courseName, 'Rekayasa Perangkat Lunak');
      expect(schedules[2].room, 'KU3.05');
      expect(schedules[2].startTime, '09:30');

      expect(schedules[3].dayOfWeek, 'Selasa');
      expect(schedules[3].courseCode, 'IF103');
      expect(schedules[3].courseName, 'Sistem Terdistribusi');
      expect(schedules[3].room, 'KU3.08');
      expect(schedules[3].startTime, '13:30');

      expect(schedules[4].dayOfWeek, 'Kamis');
      expect(schedules[4].courseCode, 'IF103');
      expect(schedules[4].courseName, 'Sistem Terdistribusi');
      expect(schedules[4].room, 'KU3.01');
      expect(schedules[4].startTime, '08:30');

      expect(schedules[5].dayOfWeek, 'Kamis');
      expect(schedules[5].courseCode, 'IF101');
      expect(schedules[5].room, 'KU3.02');
      expect(schedules[5].startTime, '13:00');

      expect(schedules[6].dayOfWeek, 'Jumat');
      expect(schedules[6].courseCode, 'IF101');
      expect(schedules[6].startTime, '13:30');

      expect(schedules[7].dayOfWeek, 'Jumat');
      expect(schedules[7].courseCode, 'IF103');
      expect(schedules[7].courseName, 'Sistem Terdistribusi');
      expect(schedules[7].startTime, '16:30');

      expect(schedules[8].dayOfWeek, 'Jumat');
      expect(schedules[8].courseCode, 'IF102');
      expect(schedules[8].startTime, '19:30');
    });

    test('getSchedulesByLecturer with dayOfWeek filters by day', () async {
      final seninSchedules = await ScheduleRepository.instance.getSchedulesByLecturer(
        'L001',
        dayOfWeek: 'Senin',
      );
      expect(seninSchedules.length, 2);
      expect(seninSchedules.first.dayOfWeek, 'Senin');
      expect(seninSchedules.first.courseName, 'Pemrograman Mobile');
      expect(seninSchedules.last.courseName, 'Rekayasa Perangkat Lunak');

      final rabuSchedules = await ScheduleRepository.instance.getSchedulesByLecturer(
        'L001',
        dayOfWeek: 'Rabu',
      );
      expect(rabuSchedules, isEmpty);
    });

    test('getSchedulesByLecturer returns schedules belonging strictly to requested lecturer', () async {
      final l002Schedules = await ScheduleRepository.instance.getSchedulesByLecturer('L002');

      expect(l002Schedules.length, 2);
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
        room: 'LAB-05',
        startTime: '10:00',
        endTime: '12:30',
      );
      expect(newId, isPositive);

      final sabtuSchedules = await ScheduleRepository.instance.getSchedulesByLecturer(
        'L001',
        dayOfWeek: 'Sabtu',
      );
      expect(sabtuSchedules.length, 2);
      expect(sabtuSchedules.any((s) => s.room == 'LAB-05'), isTrue);
    });

    test('updateSchedule updates room, times, and day for existing schedule', () async {
      final schedule = await ScheduleRepository.instance.getScheduleById(1);
      expect(schedule, isNotNull);
      expect(schedule!.room, 'KU3.01');

      final updated = schedule.copyWith(
        room: 'LAB-CORE',
        startTime: '09:00',
        endTime: '11:30',
        dayOfWeek: 'Selasa',
      );
      await ScheduleRepository.instance.updateSchedule(updated);

      final fetched = await ScheduleRepository.instance.getScheduleById(1);
      expect(fetched, isNotNull);
      expect(fetched!.room, 'LAB-CORE');
      expect(fetched.startTime, '09:00');
      expect(fetched.endTime, '11:30');
      expect(fetched.dayOfWeek, 'Selasa');
    });

    test('deleteSchedule removes schedule by id', () async {
      expect(await ScheduleRepository.instance.getScheduleById(2), isNotNull);

      await ScheduleRepository.instance.deleteSchedule(2);

      expect(await ScheduleRepository.instance.getScheduleById(2), isNull);
    });
  });
}
