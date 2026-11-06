import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/dashboard/models/announcement.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/models/lecturer_stats.dart';
import 'package:podo/features/lecturers/repositories/lecturer_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lecturer? _lecturer;
  LecturerStats _stats = const LecturerStats.zero();
  TeachingSchedule? _upcomingSchedule;
  bool _isLoading = true;
  late final ScrollController _scrollController;
  bool _showAppbarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadData();
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

  Future<void> _loadData() async {
    final activeId = AuthRepository.instance.activeLecturerId;
    if (activeId != null) {
      try {
        final results = await Future.wait([
          LecturerRepository.instance.getLecturerById(activeId),
          ScheduleRepository.instance.getSchedulesByLecturer(activeId),
          LecturerRepository.instance.getLecturerStats(activeId),
        ]);

        final lecturer = results[0] as Lecturer?;
        final schedules = results[1] as List<TeachingSchedule>;
        final stats = results[2] as LecturerStats;

        if (mounted) {
          setState(() {
            _lecturer = lecturer;
            _stats = stats;
            if (schedules.isNotEmpty) {
              _upcomingSchedule = schedules.first;
            }
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isLoading = false);
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

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ColorToken token,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return Semantics(
      button: true,
      label: label,
      child: FTappable(
        onPress: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: token.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: token.border, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 26,
                color: token.foreground,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 90,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required ColorToken token,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: token.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: token.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: token.foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: token.foreground,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroScheduleCard(BuildContext context, TeachingSchedule schedule) {
    final theme = context.theme;
    final colors = context.appColors;

    return FTappable(
      onPress: () => MainScreenScope.of(context)?.switchToTab(1),
      child: FCard(
        child: Container(
          decoration: BoxDecoration(
            color: colors.amber.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.amber.border, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Book icon, Course title, Class & SKS Badges, Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.amber.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.amber.border),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FLucideIcons.calendarClock,
                      size: 20,
                      color: colors.amber.foreground,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.courseName,
                          style: theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.violet.background,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: colors.violet.border),
                              ),
                              child: Text(
                                'Kelas ${schedule.className}',
                                style: TextStyle(
                                  color: colors.violet.foreground,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.sky.background,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: colors.sky.border),
                              ),
                              child: Text(
                                '${schedule.credits} SKS',
                                style: TextStyle(
                                  color: colors.sky.foreground,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.amber.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.amber.border),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.chevronRight,
                        size: 15,
                        color: colors.amber.foreground,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Container(
                height: 1,
                color: colors.amber.border.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 10),

              // Bottom info row: Day, Time with Clock Icon, Room with MapPin Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.clock,
                        size: 14,
                        color: colors.amber.foreground,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${schedule.dayOfWeek}, ${schedule.startTime} - ${schedule.endTime}',
                        style: theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.mapPin,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.room,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildEmptyScheduleCard(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return FCard(
      child: Container(
        decoration: BoxDecoration(
          color: colors.emerald.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.emerald.border, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.emerald.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.emerald.border),
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
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Semua kelas telah selesai atau belum terjadwal.',
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
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
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone 1: Top Bar (Avatar on left, Notification Bell on right - NO tahun ajaran)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        label: 'Profil ${_lecturer?.fullName ?? "Dosen"}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.violet.border,
                              width: 1.5,
                            ),
                          ),
                          child: FAvatar.raw(
                            size: 44,
                            child: Text(
                              _getInitials(_lecturer?.fullName),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.violet.foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Notifikasi',
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.sky.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.sky.border),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                FLucideIcons.bell,
                                size: 20,
                                color: colors.sky.foreground,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.amber.foreground,
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

                  const SizedBox(height: 12),

                  // Zone 2: Large Greeting Headline & Department Tag
                  Text(
                    'Selamat Datang,',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _lecturer?.fullName ?? 'Dosen',
                          style: theme.typography.display.lg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_lecturer?.department != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.violet.background,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: colors.violet.border),
                          ),
                          child: Text(
                            _lecturer!.department!,
                            style: TextStyle(
                              color: colors.violet.foreground,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Playful Workload Summary Chips Strip (Inspired by playful.png)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMetricChip(
                          icon: FLucideIcons.bookOpen,
                          label: '${_stats.courseCount} Kelas Aktif',
                          token: colors.violet,
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: FLucideIcons.award,
                          label: '${_stats.totalCredits} SKS Total',
                          token: colors.amber,
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: FLucideIcons.users,
                          label: '${_stats.studentCount} Mahasiswa',
                          token: colors.sky,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Zone 3: Upcoming Schedule Hero Card (Jadwal Terdekat)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal Berikutnya',
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
                                color: theme.colors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              FLucideIcons.arrowRight,
                              size: 14,
                              color: theme.colors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_upcomingSchedule != null)
                    _buildHeroScheduleCard(context, _upcomingSchedule!)
                  else
                    _buildEmptyScheduleCard(context),

                  const SizedBox(height: 24),

                  // Zone 4: Menu Utama (Playful Tinted Squircles with Light/Dark borders)
                  Text(
                    'Menu Utama',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActionItem(
                        context,
                        label: 'Isi Biodata',
                        icon: FLucideIcons.clipboardEdit,
                        token: colors.violet,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.studentBiodataForm),
                      ),
                      _buildQuickActionItem(
                        context,
                        label: 'Input Nilai',
                        icon: FLucideIcons.award,
                        token: colors.emerald,
                        onTap: () =>
                            MainScreenScope.of(context)?.switchToTab(2),
                      ),
                      _buildQuickActionItem(
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

                  // Zone 5: Pengumuman Kampus Section (Categorized Playful Cards)
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
                      child: FCard(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colors.border,
                              width: 1,
                            ),
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
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: catToken.border),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  catIcon,
                                  size: 22,
                                  color: catToken.foreground,
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: catToken.background,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            border: Border.all(
                                              color: catToken.border,
                                            ),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: TextStyle(
                                              color: catToken.foreground,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item.date,
                                          style: theme.typography.body.xs
                                              .copyWith(
                                            color:
                                                theme.colors.mutedForeground,
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
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
