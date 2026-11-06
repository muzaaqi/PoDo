import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/dashboard/models/announcement.dart';
import 'package:podo/features/dashboard/widgets/schedule_card_stack.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/repositories/lecturer_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

class HomeScreen extends StatefulWidget {
  final DateTime? currentDateTime;

  const HomeScreen({super.key, this.currentDateTime});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lecturer? _lecturer;
  List<TeachingSchedule> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final ScrollController _scrollController;
  bool _showAppbarTitle = false;
  Timer? _liveTicker;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _startLiveTicker();
    _loadData();
  }

  void _startLiveTicker() {
    if (widget.currentDateTime != null) return;
    _liveTicker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() {});
      }
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

  int _getDayOrder(String day) {
    switch (day.trim().toLowerCase()) {
      case 'senin':
        return 1;
      case 'selasa':
        return 2;
      case 'rabu':
        return 3;
      case 'kamis':
        return 4;
      case 'jumat':
        return 5;
      case 'sabtu':
        return 6;
      default:
        return 7;
    }
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

  List<TeachingSchedule> _getTodaySchedules(List<TeachingSchedule> schedules) {
    final now = widget.currentDateTime ?? DateTime.now();
    final todayName = _getDayName(now.weekday);
    final todaySchedules = schedules
        .where((s) => s.dayOfWeek.trim().toLowerCase() == todayName.toLowerCase())
        .toList();
    todaySchedules.sort((a, b) {
      final startA = _parseTimeToMinutes(a.startTime) ?? 0;
      final startB = _parseTimeToMinutes(b.startTime) ?? 0;
      return startA.compareTo(startB);
    });
    return todaySchedules;
  }

  void _sortSchedules(List<TeachingSchedule> schedules) {
    schedules.sort((a, b) {
      final dayA = _getDayOrder(a.dayOfWeek);
      final dayB = _getDayOrder(b.dayOfWeek);
      if (dayA != dayB) return dayA.compareTo(dayB);
      final startA = _parseTimeToMinutes(a.startTime) ?? 0;
      final startB = _parseTimeToMinutes(b.startTime) ?? 0;
      return startA.compareTo(startB);
    });
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

  Future<void> _loadData() async {
    final activeId = AuthRepository.instance.activeLecturerId;
    if (activeId != null) {
      try {
        if (mounted) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        }
        final results = await Future.wait([
          LecturerRepository.instance.getLecturerById(activeId),
          ScheduleRepository.instance.getSchedulesByLecturer(activeId),
        ]);

        final lecturer = results[0] as Lecturer?;
        final schedules = results[1] as List<TeachingSchedule>;
        _sortSchedules(schedules);

        if (mounted) {
          setState(() {
            _lecturer = lecturer;
            _schedules = schedules;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Gagal memuat data akademik. Silakan periksa database lokal atau coba lagi.';
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'DS';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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

  void _showNotificationSheet(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    showFSheet(
      context: context,
      side: FLayout.btt,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(FLucideIcons.bell, size: 20, color: theme.colors.foreground),
                      const SizedBox(width: 8),
                      Text(
                        'Notifikasi & Pengumuman',
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                  FTappable(
                    onPress: () => Navigator.of(sheetContext).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(FLucideIcons.x, size: 18, color: theme.colors.mutedForeground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: Announcement.demoAnnouncements.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = Announcement.demoAnnouncements[index];
                    final isAkademik = item.category.toLowerCase().contains('akademik');
                    final isMahasiswa = item.category.toLowerCase().contains('mahasiswa');
                    final catToken = isAkademik
                        ? colors.violet
                        : (isMahasiswa ? colors.sky : colors.amber);
                    final catIcon = isAkademik
                        ? FLucideIcons.graduationCap
                        : (isMahasiswa ? FLucideIcons.users : FLucideIcons.building2);

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.colors.border, width: 1),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: catToken.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              catIcon,
                              size: 18,
                              color: catToken.foreground,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: catToken.foreground,
                                      ),
                                    ),
                                    Text(
                                      item.date,
                                      style: theme.typography.body.xs.copyWith(
                                        color: theme.colors.mutedForeground,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.title,
                                  style: theme.typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.summary,
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
              'Kendala Memuat Data',
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan saat memuat data akademik.',
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            FButton(
              onPress: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ColorToken token,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: FTappable(
          onPress: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: token.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: token.foreground,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: token.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScheduleCard(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return Semantics(
      label: 'Tidak ada jadwal perkuliahan hari ini.',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: colors.emerald.background,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tidak Ada Jadwal Hari Ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.emerald.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Saat ini tidak ada perkuliahan yang terjadwal untuk hari ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.emerald.foreground,
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

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
                'Portal Dosen',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const SizedBox.shrink(),
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat data...'))
          : _lecturer == null && _errorMessage != null
              ? _buildErrorView(context)
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.coral.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(FLucideIcons.circleAlert, size: 20, color: colors.coral.foreground),
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
                                onPress: _loadData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Zone 1: Cohesive Top Bar (Avatar + Greeting & Name + Notification Bell)
                      Row(
                        children: [
                          Semantics(
                            label: 'Profil ${_lecturer?.fullName ?? "Dosen"}',
                            child: FAvatar.raw(
                              size: 46,
                              child: Text(
                                _getInitials(_lecturer?.fullName),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Selamat Datang,',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _lecturer?.fullName ?? 'Dosen',
                                  style: theme.typography.body.lg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colors.foreground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Semantics(
                            button: true,
                            label: 'Notifikasi kampus',
                            child: FTappable(
                              onPress: () => _showNotificationSheet(context),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: theme.colors.card,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.colors.border),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      FLucideIcons.bell,
                                      size: 18,
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: theme.colors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                  const SizedBox(height: 22),

                  // Zone 2: Swipeable Teaching Schedule Card Stack (Jadwal Hari Ini)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal Hari Ini',
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colors.foreground,
                        ),
                      ),
                      FTappable(
                        onPress: () =>
                            MainScreenScope.of(context)?.switchToTab(1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Semua',
                              style: theme.typography.body.xs.copyWith(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              FLucideIcons.arrowRight,
                              size: 14,
                              color: theme.colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final todaySchedules = _getTodaySchedules(_schedules);
                      if (todaySchedules.isNotEmpty) {
                        return ScheduleCardStack(
                          schedules: todaySchedules,
                          currentDateTime: widget.currentDateTime,
                          onScheduleTap: _navigateToCourseDetail,
                        );
                      }
                      return _buildEmptyScheduleCard(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Zone 3: Menu Utama (3 Distinct Solid Matte Pastel Cards)
                  Text(
                    'Menu Utama',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickActionCard(
                        context,
                        label: 'Isi Biodata',
                        icon: FLucideIcons.clipboardEdit,
                        token: colors.violet,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.studentBiodataForm),
                      ),
                      const SizedBox(width: 10),
                      _buildQuickActionCard(
                        context,
                        label: 'Input Nilai',
                        icon: FLucideIcons.award,
                        token: colors.emerald,
                        onTap: () =>
                            MainScreenScope.of(context)?.switchToTab(2),
                      ),
                      const SizedBox(width: 10),
                      _buildQuickActionCard(
                        context,
                        label: 'Mahasiswa',
                        icon: FLucideIcons.users,
                        token: colors.sky,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.studentList),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Zone 4: Pengumuman Kampus Section (Solid Matte Pastel Category Badges)
                  Text(
                    'Pengumuman Kampus',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...Announcement.demoAnnouncements.map((item) {
                    final isAkademik =
                        item.category.toLowerCase().contains('akademik');
                    final isMahasiswa =
                        item.category.toLowerCase().contains('mahasiswa');
                    final catToken = isAkademik
                        ? colors.violet
                        : (isMahasiswa ? colors.sky : colors.amber);
                    final catIcon = isAkademik
                        ? FLucideIcons.graduationCap
                        : (isMahasiswa
                            ? FLucideIcons.users
                            : FLucideIcons.building2);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colors.border, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: catToken.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                catIcon,
                                size: 22,
                                color: catToken.foreground,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: catToken.background,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: TextStyle(
                                            color: catToken.foreground,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.date,
                                        style: theme.typography.body.xs
                                            .copyWith(
                                          color:
                                              theme.colors.mutedForeground,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.title,
                                    style: theme.typography.body.sm
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.summary,
                                    style: theme.typography.body.xs
                                        .copyWith(
                                      color:
                                          theme.colors.mutedForeground,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
