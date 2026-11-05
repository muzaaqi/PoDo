import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/dashboard/models/announcement.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/repositories/lecturer_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lecturer? _lecturer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLecturer();
  }

  Future<void> _loadLecturer() async {
    final activeId = AuthRepository.instance.activeLecturerId;
    if (activeId != null) {
      final lecturer = await LecturerRepository.instance.getLecturerById(activeId);
      if (mounted) {
        setState(() {
          _lecturer = lecturer;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'DS';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return FTappable(
      onPress: onTap,
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: theme.colors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
                  // Sapaan Dosen Banner
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          FAvatar.raw(
                            size: 48,
                            child: Text(
                              _getInitials(_lecturer?.fullName),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang,',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _lecturer?.fullName ?? 'Dosen',
                                  style: theme.typography.body.md.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_lecturer?.nidh != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'NIDH: ${_lecturer!.nidh}',
                                    style: theme.typography.body.xs.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Actions Section
                  Text(
                    'Aksi Cepat',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          label: 'Isi Biodata',
                          icon: FLucideIcons.clipboardEdit,
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.studentBiodataForm),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          label: 'Input Nilai',
                          icon: FLucideIcons.award,
                          onTap: () => MainScreenScope.of(context)?.switchToTab(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          label: 'Informasi Mahasiswa',
                          icon: FLucideIcons.users,
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.studentList),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pengumuman Kampus Section
                  Text(
                    'Pengumuman Kampus',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...Announcement.demoAnnouncements.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FBadge(
                                    variant: FBadgeVariant.secondary,
                                    child: Text(item.category),
                                  ),
                                  Text(
                                    item.date,
                                    style: theme.typography.body.xs.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                style: theme.typography.body.sm.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.summary,
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
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
