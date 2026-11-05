import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  List<TeachingSchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final lecturerId = AuthRepository.instance.activeLecturerId;
    if (lecturerId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final schedules = await ScheduleRepository.instance.getSchedulesByLecturer(lecturerId);
    if (mounted) {
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      header: FHeader(
        title: const Text('Jadwal Mengajar'),
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat jadwal mengajar...'))
          : FTabs(
              expands: true,
              scrollable: true,
              children: _days.map((day) {
                return FTabEntry(
                  label: Text(day),
                  child: _buildDayContent(context, theme, day),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDayContent(BuildContext context, FThemeData theme, String day) {
    final daySchedules = _schedules.where((s) => s.dayOfWeek == day).toList();

    if (daySchedules.isEmpty) {
      return _buildEmptyState(context, theme, day);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: daySchedules.length,
      itemBuilder: (context, index) {
        final schedule = daySchedules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildScheduleCard(context, theme, schedule),
        );
      },
    );
  }

  Widget _buildScheduleCard(BuildContext context, FThemeData theme, TeachingSchedule schedule) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    schedule.courseName,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FBadge(
                  variant: FBadgeVariant.secondary,
                  child: Text('${schedule.credits} SKS'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${schedule.courseCode} • Kelas ${schedule.className}',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  FLucideIcons.clock,
                  size: 15,
                  color: theme.colors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  '${schedule.startTime} - ${schedule.endTime} WIB',
                  style: theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  FLucideIcons.mapPin,
                  size: 15,
                  color: theme.colors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ruang ${schedule.room}',
                  style: theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FThemeData theme, String day) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FLucideIcons.calendarX,
                    size: 32,
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak Ada Jadwal Mengajar',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tidak ada perkuliahan pada hari $day. Selamat beristirahat atau gunakan waktu untuk kegiatan akademik lainnya.',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
