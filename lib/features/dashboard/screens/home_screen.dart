import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/dashboard/models/announcement.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
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
        ]);

        final lecturer = results[0] as Lecturer?;
        final schedules = results[1] as List<TeachingSchedule>;

        if (mounted) {
          setState(() {
            _lecturer = lecturer;
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: token.background,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 24,
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

  Widget _buildHeroScheduleCard(BuildContext context, TeachingSchedule schedule) {
    final theme = context.theme;
    final colors = context.appColors;

    return FTappable(
      onPress: () => MainScreenScope.of(context)?.switchToTab(1),
      child: FCard(
        child: Container(
          decoration: BoxDecoration(
            color: colors.amber.card,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Calendar icon, Course title, Class & SKS Badges, Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.amber.background,
                      borderRadius: BorderRadius.circular(12),
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
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.violet.background,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Kelas ${schedule.className}',
                                style: TextStyle(
                                  color: colors.violet.foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.sky.background,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '${schedule.credits} SKS',
                                style: TextStyle(
                                  color: colors.sky.foreground,
                                  fontSize: 11,
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
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.chevronRight,
                        size: 14,
                        color: colors.amber.foreground,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Container(
                height: 1,
                color: theme.colors.border,
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
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.emerald.background,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                FLucideIcons.calendarCheck,
                size: 20,
                color: colors.emerald.foreground,
              ),
            ),
            const SizedBox(width: 12),
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
                        child: FAvatar.raw(
                          size: 40,
                          child: Text(
                            _getInitials(_lecturer?.fullName),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Notifikasi',
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colors.secondary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            FLucideIcons.bell,
                            size: 18,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Zone 2: Large Greeting Headline
                  Text(
                    'Selamat Datang,',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lecturer?.fullName ?? 'Dosen',
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),

                  const SizedBox(height: 18),

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
                  const SizedBox(height: 8),
                  if (_upcomingSchedule != null)
                    _buildHeroScheduleCard(context, _upcomingSchedule!)
                  else
                    _buildEmptyScheduleCard(context),

                  const SizedBox(height: 20),

                  // Zone 4: Menu Utama (Solid Matte Pastel Squircles)
                  Text(
                    'Menu Utama',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
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

                  const SizedBox(height: 22),

                  // Zone 5: Pengumuman Kampus Section (Solid Matte Pastel Category Badges)
                  Text(
                    'Pengumuman Kampus',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 10),

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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: catToken.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  catIcon,
                                  size: 20,
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
                                    const SizedBox(height: 6),
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
