import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
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
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _loadData() async {
    final activeId = AuthRepository.instance.activeLecturerId;
    if (activeId != null) {
      try {
        final lecturer =
            await LecturerRepository.instance.getLecturerById(activeId);
        final schedules =
            await ScheduleRepository.instance.getSchedulesByLecturer(activeId);

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
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return FTappable(
      onPress: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 24,
              color: theme.colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.typography.body.xs.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final filteredAnnouncements = Announcement.demoAnnouncements.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.title.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery) ||
          item.summary.toLowerCase().contains(_searchQuery);
    }).toList();

    return FScaffold(
      header: FHeader(
        title: const Text('Portal Dosen'),
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat data...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone 1: Top Bar (Avatar, Semester Context Pill, Notification)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FAvatar.raw(
                        size: 38,
                        child: Text(
                          _getInitials(_lecturer?.fullName),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FBadge(
                        variant: FBadgeVariant.secondary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _upcomingSchedule != null
                                  ? '${_upcomingSchedule!.academicYear} (${_upcomingSchedule!.term})'
                                  : 'Ganjil 2024/2025',
                              style: theme.typography.body.xs.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              FLucideIcons.chevronDown,
                              size: 14,
                              color: theme.colors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
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
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Zone 2: Large Greeting Headline
                  Text(
                    'Selamat Datang,',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_lecturer?.fullName ?? 'Dosen'} 🎓',
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Zone 3: Search Bar with filter icon
                  Row(
                    children: [
                      Expanded(
                        child: FTextField(
                          hint: 'Cari pengumuman atau info...',
                          control: FTextFieldControl.managed(
                            controller: _searchController,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          FLucideIcons.slidersHorizontal,
                          size: 20,
                          color: theme.colors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Zone 4: Upcoming Schedule Hero Card (layout from home.jpg)
                  if (_upcomingSchedule != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jadwal Berikutnya',
                          style: theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FTappable(
                          onPress: () =>
                              MainScreenScope.of(context)?.switchToTab(1),
                          child: Text(
                            'Lihat Semua',
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FTappable(
                      onPress: () =>
                          MainScreenScope.of(context)?.switchToTab(1),
                      child: FCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.colors.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      FLucideIcons.bookOpen,
                                      size: 22,
                                      color: theme.colors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _upcomingSchedule!.courseName,
                                          style: theme.typography.body.sm
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kelas ${_upcomingSchedule!.className} • ${_upcomingSchedule!.credits} SKS',
                                          style: theme.typography.body.xs
                                              .copyWith(
                                            color: theme.colors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: theme.colors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      FLucideIcons.arrowUpRight,
                                      size: 18,
                                      color: theme.colors.primaryForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                height: 1,
                                color: theme.colors.border,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FLucideIcons.calendar,
                                        size: 14,
                                        color: theme.colors.mutedForeground,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _upcomingSchedule!.dayOfWeek,
                                        style:
                                            theme.typography.body.xs.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FLucideIcons.clock,
                                        size: 14,
                                        color: theme.colors.mutedForeground,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_upcomingSchedule!.startTime} - ${_upcomingSchedule!.endTime} (${_upcomingSchedule!.room})',
                                        style:
                                            theme.typography.body.xs.copyWith(
                                          color: theme.colors.mutedForeground,
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
                    const SizedBox(height: 24),
                  ],

                  // Zone 5: Quick Action Grid (Horizontal 4 circular buttons with labels and dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menu Utama',
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Aksi Cepat',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
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
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.studentBiodataForm),
                      ),
                      _buildQuickActionItem(
                        context,
                        label: 'Input Nilai',
                        icon: FLucideIcons.award,
                        onTap: () =>
                            MainScreenScope.of(context)?.switchToTab(2),
                      ),
                      _buildQuickActionItem(
                        context,
                        label: 'Informasi Mahasiswa',
                        icon: FLucideIcons.users,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.studentList),
                      ),
                      _buildQuickActionItem(
                        context,
                        label: 'Jadwal Mengajar',
                        icon: FLucideIcons.calendarDays,
                        onTap: () =>
                            MainScreenScope.of(context)?.switchToTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Pagination indicator dots matching home.jpg
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.colors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              theme.colors.mutedForeground.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              theme.colors.mutedForeground.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Zone 6: Pengumuman Kampus Feed (layout from home.jpg)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pengumuman Kampus',
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FBadge(
                        variant: FBadgeVariant.outline,
                        child: Text('${filteredAnnouncements.length} Informasi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (filteredAnnouncements.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Tidak ada pengumuman yang sesuai.',
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredAnnouncements.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: theme.colors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    FLucideIcons.newspaper,
                                    size: 20,
                                    color: theme.colors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          FBadge(
                                            variant: FBadgeVariant.secondary,
                                            child: Text(item.category),
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
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.summary,
                                        style: theme.typography.body.xs
                                            .copyWith(
                                          color:
                                              theme.colors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
