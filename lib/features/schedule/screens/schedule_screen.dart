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

  String _selectedDay = 'Senin';
  List<TeachingSchedule> _schedules = [];
  bool _isLoading = true;
  late final ScrollController _scrollController;
  bool _showAppbarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadSchedules();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 40;
    if (show != _showAppbarTitle) {
      setState(() => _showAppbarTitle = show);
    }
  }

  Future<void> _loadSchedules() async {
    final lecturerId = AuthRepository.instance.activeLecturerId;
    if (lecturerId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final schedules =
          await ScheduleRepository.instance.getSchedulesByLecturer(lecturerId);
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _schedules = [];
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDaySelector(BuildContext context, FThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _days.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final day = entry.value;
          final isSelected = day == _selectedDay;

          return Expanded(
            child: FTappable(
              onPress: () => setState(() => _selectedDay = day),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day,
                    style: theme.typography.body.xs.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? theme.colors.primary
                          : theme.colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$index',
                    style: theme.typography.body.sm.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colors.primary
                          : theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? theme.colors.primary
                          : const Color(0x00000000),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    FThemeData theme,
    TeachingSchedule schedule,
    bool isActive,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vertical Timeline Track matching jadwal.jpg
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: isActive ? 16 : 12,
                  height: isActive ? 16 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? theme.colors.primary
                        : theme.colors.background,
                    border: Border.all(
                      color: theme.colors.primary,
                      width: isActive ? 3 : 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Schedule Card matching jadwal.jpg
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FCard(
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
                          Text(
                            '${schedule.startTime} - ${schedule.endTime}',
                            style: theme.typography.body.xs.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${schedule.courseCode} • Kelas ${schedule.className}',
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FBadge(
                            variant: FBadgeVariant.secondary,
                            child: Text('${schedule.credits} SKS'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            FLucideIcons.mapPin,
                            size: 14,
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
                      if (isActive) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: theme.colors.border,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FLucideIcons.users,
                                  size: 14,
                                  color: theme.colors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Perkuliahan Aktif',
                                  style: theme.typography.body.xs.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            FBadge(
                              variant: FBadgeVariant.outline,
                              child: Text(
                                '${schedule.academicYear} (${schedule.term})',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FThemeData theme, String day) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FLucideIcons.calendarOff,
                  size: 40,
                  color: theme.colors.mutedForeground,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tidak Ada Jadwal Mengajar',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tidak ada perkuliahan pada hari $day. Silakan pilih hari lain.',
                  textAlign: TextAlign.center,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final daySchedules =
        _schedules.where((s) => s.dayOfWeek == _selectedDay).toList();

    return FScaffold(
      header: FHeader.nested(
        titleAlignment: Alignment.center,
        style: const FHeaderStyleDelta.delta(
          constraints: BoxConstraints(minHeight: 40, maxHeight: 40),
          padding: EdgeInsetsGeometryDelta.value(
            EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        title: _showAppbarTitle
            ? Text(
                'Jadwal Mengajar',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const SizedBox.shrink(),
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat jadwal mengajar...'))
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone 1: Subtitle & Large Title Header (matching jadwal.jpg)
                  Text(
                    'Semester Ganjil 2024/2025',
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Jadwal Mengajar',
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Zone 2: Horizontal Day Selector Strip (matching jadwal.jpg)
                  _buildDaySelector(context, theme),

                  const SizedBox(height: 20),

                  // Zone 3: Vertical Timeline with connected cards (matching jadwal.jpg)
                  if (daySchedules.isEmpty)
                    _buildEmptyState(context, theme, _selectedDay)
                  else
                    ...daySchedules.asMap().entries.map((entry) {
                      final index = entry.key;
                      final schedule = entry.value;
                      final isActive = index == 0;
                      final isLast = index == daySchedules.length - 1;

                      return _buildTimelineItem(
                        context,
                        theme,
                        schedule,
                        isActive,
                        isLast,
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
