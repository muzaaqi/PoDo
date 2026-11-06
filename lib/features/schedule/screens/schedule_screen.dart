import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

enum ScheduleTimelineStatus {
  past,
  ongoing,
  upcoming,
}

class ScheduleScreen extends StatefulWidget {
  final String initialDay;
  final DateTime? currentDateTime;

  const ScheduleScreen({
    super.key,
    this.initialDay = 'Senin',
    this.currentDateTime,
  });

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

  late String _selectedDay;
  List<TeachingSchedule> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final ScrollController _scrollController;
  bool _showAppbarTitle = false;
  Timer? _liveTicker;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay;
    _scrollController = ScrollController()..addListener(_onScroll);
    _startLiveTicker();
    _loadSchedules();
  }

  void _startLiveTicker() {
    if (widget.currentDateTime != null) return;
    _liveTicker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _liveTicker?.cancel();
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
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
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
          _errorMessage =
              'Gagal memuat jadwal mengajar. Silakan periksa database lokal atau coba lagi.';
          _isLoading = false;
        });
      }
    }
  }

  bool _hasScheduleOn(String day) {
    return _schedules
        .any((s) => s.dayOfWeek.toLowerCase() == day.toLowerCase());
  }

  int? _parseTimeToMinutes(String time) {
    try {
      final parts = time.trim().split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (_) {}
    return null;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      default:
        return 'Minggu';
    }
  }

  ScheduleTimelineStatus _getScheduleStatus({
    required TeachingSchedule schedule,
    required bool isToday,
    required int currentMinutes,
  }) {
    if (!isToday) return ScheduleTimelineStatus.upcoming;

    final start = _parseTimeToMinutes(schedule.startTime);
    final end = _parseTimeToMinutes(schedule.endTime);
    if (start == null || end == null) return ScheduleTimelineStatus.upcoming;

    if (currentMinutes > end) {
      return ScheduleTimelineStatus.past;
    } else if (currentMinutes >= start && currentMinutes <= end) {
      return ScheduleTimelineStatus.ongoing;
    } else {
      return ScheduleTimelineStatus.upcoming;
    }
  }

  Future<void> _navigateToCourseDetail(TeachingSchedule schedule) async {
    final offering =
        await CourseRepository.instance.getOfferingById(schedule.offeringId) ??
            CourseOffering(
              offeringId: schedule.offeringId,
              courseCode: schedule.courseCode,
              lecturerId: AuthRepository.instance.activeLecturerId ?? '',
              className: schedule.className,
              academicYear: schedule.academicYear,
              term: schedule.term,
              courseName: schedule.courseName,
              credits: schedule.credits,
            );
    if (mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.courseDetail,
        arguments: offering,
      );
    }
  }

  Widget _buildDaySelector(BuildContext context, FThemeData theme) {
    return Row(
      children: _days.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final day = entry.value;
        final isSelected = day == _selectedDay;
        final hasClasses = _hasScheduleOn(day);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Semantics(
              button: true,
              selected: isSelected,
              label:
                  'Hari $day, ${hasClasses ? "ada jadwal kelas" : "tidak ada kelas"}',
              child: FTappable(
                onPress: () => setState(() => _selectedDay = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? theme.colors.primary : theme.colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? null
                        : Border.all(color: theme.colors.border, width: 1.2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFFFFF)
                              : theme.colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFFFFF)
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
                              ? const Color(0xFFFDE68A)
                              : (hasClasses
                                  ? theme.colors.primary
                                  : const Color(0x00000000)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineTrack(
    BuildContext context, {
    required ScheduleTimelineStatus status,
    required bool isFirst,
    required bool isLast,
    required FThemeData theme,
    required AppColors colors,
  }) {
    final activeColor = theme.colors.primary;
    final pastColor = colors.emerald.foreground;
    final neutralColor = theme.colors.border;

    final topTrackColor = isFirst
        ? const Color(0x00000000)
        : (status == ScheduleTimelineStatus.past ||
                status == ScheduleTimelineStatus.ongoing
            ? pastColor
            : neutralColor);

    final bottomTrackColor = isLast
        ? const Color(0x00000000)
        : (status == ScheduleTimelineStatus.past ? pastColor : neutralColor);

    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // Top connecting line
          Container(
            width: 2.5,
            height: 20,
            color: topTrackColor,
          ),
          // Node indicator based on real-time status
          if (status == ScheduleTimelineStatus.past)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: pastColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                FLucideIcons.check,
                size: 11,
                color: Color(0xFFFFFFFF),
              ),
            )
          else if (status == ScheduleTimelineStatus.ongoing)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colors.amber.background,
                shape: BoxShape.circle,
                border: Border.all(color: activeColor, width: 2),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: pastColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colors.card,
                shape: BoxShape.circle,
                border: Border.all(color: neutralColor, width: 2),
              ),
            ),
          // Bottom connecting line
          Expanded(
            child: Container(
              width: 2.5,
              color: bottomTrackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context, {
    required TeachingSchedule schedule,
    required ColorToken token,
    required ScheduleTimelineStatus status,
    required int currentMinutes,
    required DateTime now,
  }) {
    final theme = context.theme;
    final colors = context.appColors;

    final startMinutes = _parseTimeToMinutes(schedule.startTime) ?? 0;
    final endMinutes = _parseTimeToMinutes(schedule.endTime) ?? 0;
    final totalDuration = (endMinutes - startMinutes).clamp(1, 1440);
    final elapsedMinutes =
        (currentMinutes - startMinutes).clamp(0, totalDuration);
    final remainingMinutes =
        (endMinutes - currentMinutes).clamp(0, totalDuration);
    final progress = (elapsedMinutes / totalDuration).clamp(0.0, 1.0);

    final scheduleSemantics = 'Jadwal: ${schedule.courseName}, '
        'Kelas ${schedule.className}, ${schedule.credits} SKS, '
        'Ruang ${schedule.room}, pukul ${schedule.startTime} sampai ${schedule.endTime}. '
        '${status == ScheduleTimelineStatus.ongoing ? "Sedang berlangsung, tersisa $remainingMinutes menit. " : status == ScheduleTimelineStatus.past ? "Kelas telah selesai. " : ""}'
        'Ketuk untuk membuka detail mata kuliah.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        button: true,
        label: scheduleSemantics,
        excludeSemantics: true,
        child: FTappable(
          onPress: () => _navigateToCourseDetail(schedule),
          child: Container(
            decoration: BoxDecoration(
              color: token.background,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Calendar icon, Title & Pills, Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.calendarClock,
                        size: 22,
                        color: token.foreground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.courseName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: token.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colors.card,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Kelas ${schedule.className}',
                                  style: TextStyle(
                                    color: token.foreground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colors.card,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${schedule.credits} SKS',
                                  style: TextStyle(
                                    color: token.foreground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (status == ScheduleTimelineStatus.ongoing)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colors.card,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors.emerald.foreground,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Berlangsung',
                                        style: TextStyle(
                                          color: token.foreground,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (status == ScheduleTimelineStatus.past)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colors.card,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FLucideIcons.check,
                                        size: 10,
                                        color: colors.emerald.foreground,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Selesai',
                                        style: TextStyle(
                                          color: token.foreground,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: theme.colors.card,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.chevronRight,
                        size: 16,
                        color: token.foreground,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom row: Time and Room
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FLucideIcons.clock,
                          size: 15,
                          color: token.foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${schedule.startTime} - ${schedule.endTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: token.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FLucideIcons.mapPin,
                          size: 15,
                          color: token.foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ruang ${schedule.room}',
                          style: TextStyle(
                            fontSize: 12,
                            color: token.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // In-Card Live Real-Time Timeline Progress if ongoing
                if (status == ScheduleTimelineStatus.ongoing) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FLucideIcons.timer,
                                  size: 13,
                                  color: token.foreground,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Waktu Berjalan (${(progress * 100).toInt()}%)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: token.foreground,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              remainingMinutes > 0
                                  ? 'Tersisa $remainingMinutes mnt'
                                  : 'Waktu Habis',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: remainingMinutes <= 15
                                    ? colors.coral.foreground
                                    : token.foreground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 20,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              FDeterminateProgress(
                                value: progress,
                                style: FDeterminateProgressStyle(
                                  constraints:
                                      const BoxConstraints.tightFor(height: 6),
                                  trackDecoration: BoxDecoration(
                                    color: token.background,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  fillDecoration: BoxDecoration(
                                    color: token.foreground,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(
                                  (-1.0 + 2.0 * progress).clamp(-1.0, 1.0),
                                  0.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: token.foreground,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: theme.colors.card,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFFFFFF),
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule.startTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pukul ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: token.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              schedule.endTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String day) {
    final theme = context.theme;
    final colors = context.appColors;

    return Semantics(
      label:
          'Tidak ada jadwal mengajar pada hari $day. Tidak ada perkuliahan pada hari $day. Silakan pilih hari lain.',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: colors.emerald.background,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                FLucideIcons.calendarCheck,
                size: 22,
                color: colors.emerald.foreground,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tidak Ada Jadwal Mengajar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colors.emerald.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada perkuliahan pada hari $day. Silakan pilih hari lain.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.emerald.foreground,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.coral.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                FLucideIcons.circleAlert,
                size: 28,
                color: colors.coral.foreground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kendala Memuat Jadwal',
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan saat memuat jadwal mengajar.',
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            FButton(
              onPress: _loadSchedules,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;
    final now = widget.currentDateTime ?? DateTime.now();
    final isToday =
        _selectedDay.toLowerCase() == _getDayName(now.weekday).toLowerCase();
    final currentMinutes = now.hour * 60 + now.minute;

    final daySchedules = _schedules
        .where(
            (s) => s.dayOfWeek.toLowerCase() == _selectedDay.toLowerCase())
        .toList();

    final palette = [
      colors.amber,
      colors.violet,
      colors.sky,
      colors.emerald,
      colors.coral,
      colors.indigo,
    ];

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
          : _schedules.isEmpty && _errorMessage != null
              ? _buildErrorView(context)
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.coral.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(FLucideIcons.circleAlert,
                                  size: 20, color: colors.coral.foreground),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colors.coral.foreground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FButton(
                                variant: FButtonVariant.outline,
                                onPress: _loadSchedules,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      Text(
                        'Jadwal Mengajar',
                        style: theme.typography.display.lg.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Zone 2: Horizontal Day Selector Strip
                      _buildDaySelector(context, theme),

                      const SizedBox(height: 20),

                      // Zone 3: Multi-Pastel Class Cards with Real-Time Timeline Track
                      if (daySchedules.isEmpty)
                        _buildEmptyState(context, _selectedDay)
                      else
                        ...daySchedules.asMap().entries.map((entry) {
                          final index = entry.key;
                          final schedule = entry.value;
                          final token = palette[index % palette.length];
                          final isFirst = index == 0;
                          final isLast = index == daySchedules.length - 1;
                          final status = _getScheduleStatus(
                            schedule: schedule,
                            isToday: isToday,
                            currentMinutes: currentMinutes,
                          );

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTimelineTrack(
                                  context,
                                  status: status,
                                  isFirst: isFirst,
                                  isLast: isLast,
                                  theme: theme,
                                  colors: colors,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildScheduleCard(
                                    context,
                                    schedule: schedule,
                                    token: token,
                                    status: status,
                                    currentMinutes: currentMinutes,
                                    now: now,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
