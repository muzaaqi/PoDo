import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

class ScheduleScreen extends StatefulWidget {
  final String initialDay;

  const ScheduleScreen({super.key, this.initialDay = 'Senin'});

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

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay;
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

  Widget _buildScheduleCard(
    BuildContext context, {
    required TeachingSchedule schedule,
    required ColorToken token,
  }) {
    final theme = context.theme;

    final scheduleSemantics = 'Jadwal: ${schedule.courseName}, '
        'Kelas ${schedule.className}, ${schedule.credits} SKS, '
        'Ruang ${schedule.room}, pukul ${schedule.startTime} sampai ${schedule.endTime}. '
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
                          Row(
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
                              const SizedBox(width: 6),
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

                      // Zone 3: Multi-Pastel Class Cards
                      if (daySchedules.isEmpty)
                        _buildEmptyState(context, _selectedDay)
                      else
                        ...daySchedules.asMap().entries.map((entry) {
                          final index = entry.key;
                          final schedule = entry.value;
                          final token = palette[index % palette.length];

                          return _buildScheduleCard(
                            context,
                            schedule: schedule,
                            token: token,
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
