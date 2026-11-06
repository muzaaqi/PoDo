import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/core/theme/app_theme_controller.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/lecturers/models/lecturer.dart';
import 'package:podo/features/lecturers/repositories/lecturer_repository.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Lecturer? _lecturer;
  bool _isLoading = true;
  late final ScrollController _scrollController;
  bool _showAppbarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadProfile();
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

  Future<void> _loadProfile() async {
    final activeId = AuthRepository.instance.activeLecturerId;
    if (activeId != null) {
      try {
        final lecturer =
            await LecturerRepository.instance.getLecturerById(activeId);
        if (mounted) {
          setState(() {
            _lecturer = lecturer;
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

  void _showFeatureNotice(String title, String message) {
    showFToast(
      context: context,
      title: Text(title),
      description: Text(message),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    final theme = context.theme;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) ...[
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Container(
                height: 1,
                color: theme.colors.border,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    final theme = context.theme;

    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: Column(
        children: [
          FTappable(
            onPress: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 18, color: iconColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing,
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (!isLast) ...[
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Container(
                height: 1,
                color: theme.colors.border,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;
    final lecturer = _lecturer;
    final isDark = theme.colors.brightness == Brightness.dark;

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
                'Akun Dosen',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const SizedBox.shrink(),
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat profil...'))
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akun Dosen',
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Part 1: Hero Identity Card (Playful & Executive)
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Semantics(
                              label:
                                  'Avatar inisial ${lecturer?.fullName ?? "Dosen"}',
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: colors.indigo.background,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getInitials(lecturer?.fullName),
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: colors.indigo.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              lecturer?.fullName ?? 'Dosen',
                              textAlign: TextAlign.center,
                              style: theme.typography.body.lg.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (lecturer?.title != null) ...[
                            const SizedBox(height: 6),
                            Center(
                              child: FBadge(
                                variant: FBadgeVariant.secondary,
                                child: Text(lecturer!.title!),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colors.muted,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'NIDN ${lecturer?.nidh ?? "-"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.emerald.background,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      FLucideIcons.checkCircle2,
                                      size: 12,
                                      color: colors.emerald.foreground,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dosen Aktif',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colors.emerald.foreground,
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
                  ),

                  const SizedBox(height: 16),

                  // Part 2: Department & Contact Information Card
                  Text(
                    'Informasi Kontak & Unit',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            icon: FLucideIcons.building2,
                            iconBg: colors.sky.background,
                            iconColor: colors.sky.foreground,
                            label: 'Departemen / Program Studi',
                            value: lecturer?.department ?? '-',
                          ),
                          _buildInfoRow(
                            context,
                            icon: FLucideIcons.mail,
                            iconBg: colors.emerald.background,
                            iconColor: colors.emerald.foreground,
                            label: 'Email Resmi Kampus',
                            value: lecturer?.email ?? '-',
                          ),
                          _buildInfoRow(
                            context,
                            icon: FLucideIcons.phone,
                            iconBg: colors.amber.background,
                            iconColor: colors.amber.foreground,
                            label: 'Nomor Telepon / Kontak',
                            value: lecturer?.phone ?? '-',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Part 3: Settings & Application Utilities
                  Text(
                    'Pengaturan & Utilitas',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            context,
                            icon: isDark
                                ? FLucideIcons.moon
                                : FLucideIcons.sun,
                            iconBg: colors.violet.background,
                            iconColor: colors.violet.foreground,
                            title: 'Mode Tampilan',
                            subtitle: isDark
                                ? 'Mode gelap aktif'
                                : 'Mode terang aktif',
                            trailing: FSwitch(
                              value: isDark,
                              onChange: (val) {
                                AppThemeController.instance.toggleTheme(val);
                                _showFeatureNotice(
                                  'Tema Tampilan',
                                  val
                                      ? 'Mode gelap diaktifkan'
                                      : 'Mode terang diaktifkan',
                                );
                              },
                            ),
                          ),
                          _buildSettingsTile(
                            context,
                            icon: FLucideIcons.helpCircle,
                            iconBg: colors.sky.background,
                            iconColor: colors.sky.foreground,
                            title: 'Pusat Bantuan Dosen',
                            subtitle: 'FAQ & panduan penginputan nilai CPMK',
                            trailing: Icon(
                              FLucideIcons.chevronRight,
                              size: 18,
                              color: theme.colors.mutedForeground,
                            ),
                            onTap: () => _showFeatureNotice(
                              'Pusat Bantuan',
                              'Panduan operasional dan hotline akademik tersedia di podo.campus.id',
                            ),
                          ),
                          _buildSettingsTile(
                            context,
                            icon: FLucideIcons.shieldCheck,
                            iconBg: colors.emerald.background,
                            iconColor: colors.emerald.foreground,
                            title: 'Privasi & Keamanan',
                            subtitle: 'Kebijakan perlindungan data institusi',
                            trailing: Icon(
                              FLucideIcons.chevronRight,
                              size: 18,
                              color: theme.colors.mutedForeground,
                            ),
                            onTap: () => _showFeatureNotice(
                              'Privasi & Keamanan',
                              'Seluruh data perkuliahan tersimpan aman dan terenkripsi secara lokal.',
                            ),
                          ),
                          _buildSettingsTile(
                            context,
                            icon: FLucideIcons.info,
                            iconBg: colors.coral.background,
                            iconColor: colors.coral.foreground,
                            title: 'Tentang Aplikasi',
                            subtitle: 'PoDo Mobile v1.0.0 (Build 2026)',
                            trailing: FBadge(
                              variant: FBadgeVariant.outline,
                              child: const Text('Terbaru'),
                            ),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Part 4: Logout Action
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
