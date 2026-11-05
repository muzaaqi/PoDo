import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/widgets/stat_card.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/models/lecturer_stats.dart';
import 'package:podo/features/lecturers/repositories/lecturer_repository.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Lecturer? _lecturer;
  LecturerStats _stats = const LecturerStats.zero();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndStats();
  }

  Future<void> _loadProfileAndStats() async {
    final activeId = AuthRepository.instance.activeLecturerId;
    if (activeId != null) {
      final lecturer = await LecturerRepository.instance.getLecturerById(activeId);
      final stats = await LecturerRepository.instance.getLecturerStats(activeId);
      if (mounted) {
        setState(() {
          _lecturer = lecturer;
          _stats = stats;
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

  Future<void> _handleLogout() async {
    final confirmed = await showFDialog<bool>(
      context: context,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        builder: (context, dialogStyle) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konfirmasi Keluar',
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin keluar dari akun?',
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await AuthRepository.instance.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colors.mutedForeground),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      header: FHeader(
        title: const Text('Akun Dosen'),
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat profil...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Identity Card
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Center(
                            child: FAvatar.raw(
                              size: 64,
                              child: Text(
                                _getInitials(_lecturer?.fullName),
                                style: theme.typography.display.xl.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _lecturer?.fullName ?? 'Dosen',
                              textAlign: TextAlign.center,
                              style: theme.typography.body.lg.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_lecturer?.title != null) ...[
                            const SizedBox(height: 6),
                            Center(
                              child: FBadge(
                                variant: FBadgeVariant.secondary,
                                child: Text(_lecturer!.title!),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const FDivider(),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            context,
                            icon: FLucideIcons.idCard,
                            label: 'NIDH / NIDN',
                            value: _lecturer?.nidh ?? '-',
                          ),
                          _buildDetailRow(
                            context,
                            icon: FLucideIcons.building2,
                            label: 'Departemen',
                            value: _lecturer?.department ?? '-',
                          ),
                          _buildDetailRow(
                            context,
                            icon: FLucideIcons.mail,
                            label: 'Email',
                            value: _lecturer?.email ?? '-',
                          ),
                          _buildDetailRow(
                            context,
                            icon: FLucideIcons.phone,
                            label: 'Telepon',
                            value: _lecturer?.phone ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Academic Summary Section
                  Text(
                    'Ringkasan Akademik',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Kelas',
                          value: '${_stats.courseCount} Kelas',
                          icon: FLucideIcons.bookOpen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          title: 'Total SKS',
                          value: '${_stats.totalCredits} SKS',
                          icon: FLucideIcons.award,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          title: 'Mahasiswa',
                          value: '${_stats.studentCount} Mahasiswa',
                          icon: FLucideIcons.users,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Logout Action Button
                  FButton(
                    variant: FButtonVariant.destructive,
                    onPress: _handleLogout,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FLucideIcons.logOut, size: 16),
                        SizedBox(width: 8),
                        Text('Keluar dari Akun'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
