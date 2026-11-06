import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/grades/models/enrolled_student.dart';
import 'package:podo/features/grades/repositories/enrollment_repository.dart';
import 'package:podo/features/grades/widgets/grade_input_bottom_sheet.dart';

enum StudentStatusFilter { all, ungraded, graded }

class CourseDetailScreen extends StatefulWidget {
  final CourseOffering? offering;

  const CourseDetailScreen({super.key, this.offering});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  CourseOffering? _offering;
  List<EnrolledStudent> _students = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  String _searchQuery = '';
  StudentStatusFilter _selectedFilter = StudentStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    _offering = widget.offering;
    if (_offering != null) {
      _loadStudents();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_offering == null) {
      final routeOffering =
          ModalRoute.of(context)?.settings.arguments as CourseOffering?;
      _offering = routeOffering;
      _loadStudents();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  Future<void> _loadStudents() async {
    if (_offering == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    if (!_isLoading && mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final students = await EnrollmentRepository.instance
          .getEnrolledStudentsByOffering(_offering!.offeringId);
      if (mounted) {
        setState(() {
          _students = students;
          _isLoading = false;
          _hasError = false;
          _errorMessage = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _students = [];
          _isLoading = false;
          _hasError = true;
          _errorMessage =
              'Gagal memuat daftar mahasiswa. Silakan periksa koneksi atau coba lagi.';
        });
      }
    }
  }

  int get _totalStudents => _students.length;
  int get _gradedCount => _students.where((s) => s.isGraded).length;
  int get _ungradedCount => _totalStudents - _gradedCount;

  double get _progress =>
      _totalStudents > 0 ? (_gradedCount / _totalStudents).clamp(0.0, 1.0) : 0.0;

  List<EnrolledStudent> get _filteredStudents {
    return _students.where((student) {
      if (_selectedFilter == StudentStatusFilter.ungraded && student.isGraded) {
        return false;
      }
      if (_selectedFilter == StudentStatusFilter.graded && !student.isGraded) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = student.studentName.toLowerCase().contains(query);
        final nimMatch = student.studentNim.toLowerCase().contains(query);
        if (!nameMatch && !nimMatch) return false;
      }
      return true;
    }).toList();
  }

  void _resetFilterAndSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilter = StudentStatusFilter.all;
    });
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'M';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatScore(double? score) {
    if (score == null) return '-';
    return score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1);
  }

  Future<void> _openGradeSheet(EnrolledStudent student) async {
    final result = await showFSheet<bool>(
      context: context,
      side: FLayout.btt,
      builder: (context) => GradeInputBottomSheet(student: student),
    );

    if (result == true) {
      await _loadStudents();
      if (mounted) {
        showFToast(
          context: context,
          title: const Text('Nilai berhasil disimpan'),
        );
      }
    }
  }

  Widget _buildHeroCard(BuildContext context, CourseOffering offering) {
    final theme = context.theme;
    final colors = context.appColors;
    final progress = _progress;
    final isAllGraded = progress == 1.0 && _totalStudents > 0;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Course Code, Class Name, Credits, Academic Year
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${offering.courseCode} • Kelas ${offering.className}',
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tahun Akademik: ${offering.academicYear} (${offering.term})',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FBadge(
                  variant: FBadgeVariant.secondary,
                  child: Text('${offering.credits} SKS'),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Subtle Divider
            Container(
              height: 1,
              color: theme.colors.border,
            ),
            const SizedBox(height: 14),

            // Middle: 3 Stat Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    title: 'Sudah Dinilai',
                    value: '$_gradedCount',
                    icon: FLucideIcons.checkCircle2,
                    iconBg: colors.emerald.background,
                    iconColor: colors.emerald.foreground,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.colors.border,
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    title: 'Belum Dinilai',
                    value: '$_ungradedCount',
                    icon: FLucideIcons.clock,
                    iconBg: colors.amber.background,
                    iconColor: colors.amber.foreground,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.colors.border,
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    title: 'Total Mahasiswa',
                    value: '$_totalStudents',
                    icon: FLucideIcons.users,
                    iconBg: colors.sky.background,
                    iconColor: colors.sky.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Subtle Divider
            Container(
              height: 1,
              color: theme.colors.border,
            ),
            const SizedBox(height: 12),

            // Bottom: Progress Header & Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Penilaian',
                  style: theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}% • $_gradedCount/$_totalStudents Dinilai',
                  style: theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAllGraded
                        ? colors.emerald.foreground
                        : theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FDeterminateProgress(
              value: progress,
            ),

            if (isAllGraded) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.emerald.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FLucideIcons.badgeCheck,
                      size: 14,
                      color: colors.emerald.foreground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Semua nilai mahasiswa telah lengkap',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.emerald.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    final theme = context.theme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: theme.typography.display.sm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int count,
    required StudentStatusFilter filter,
  }) {
    final theme = context.theme;
    final isSelected = _selectedFilter == filter;

    return FTappable(
      onPress: () {
        if (_selectedFilter != filter) {
          setState(() => _selectedFilter = filter);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.primary : theme.colors.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? theme.colors.primary : theme.colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colors.primaryForeground
                    : theme.colors.foreground,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colors.primaryForeground.withValues(alpha: 0.2)
                    : theme.colors.muted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colors.primaryForeground
                      : theme.colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCpmkChip(String label, double? score, FThemeData theme) {
    final hasScore = score != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: hasScore ? theme.colors.muted : const Color(0x08000000),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$label: ${_formatScore(score)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: hasScore
              ? theme.colors.foreground
              : theme.colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, EnrolledStudent student) {
    final theme = context.theme;
    final colors = context.appColors;

    final semanticsLabel =
        'Mahasiswa: ${student.studentName}, NIM ${student.studentNim}, '
        '${student.isGraded ? 'Sudah dinilai, rata-rata ${student.averageScore?.toStringAsFixed(1)}' : 'Belum dinilai'}. '
        'Ketuk untuk membuka penginputan nilai CPMK.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        excludeSemantics: true,
        child: FTappable(
          onPress: () => _openGradeSheet(student),
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: student.isGraded
                              ? colors.emerald.background
                              : colors.amber.background,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getInitials(student.studentName),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: student.isGraded
                                ? colors.emerald.foreground
                                : colors.amber.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIM: ${student.studentNim}',
                              style: theme.typography.body.xs.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FBadge(
                        variant: student.isGraded
                            ? FBadgeVariant.secondary
                            : FBadgeVariant.outline,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (student.isGraded) ...[
                              Icon(
                                FLucideIcons.check,
                                size: 11,
                                color: colors.emerald.foreground,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(student.isGraded
                                ? 'Sudah Dinilai'
                                : 'Belum Dinilai'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                    ],
                  ),

                  // If Graded: Show Average Score Pill and 4 CPMK Micro-Chips
                  if (student.isGraded) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.muted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.emerald.background,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Rata-rata: ${student.averageScore?.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colors.emerald.foreground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              alignment: WrapAlignment.end,
                              children: [
                                _buildCpmkChip('C1', student.grade?.cpmk1, theme),
                                _buildCpmkChip('C2', student.grade?.cpmk2, theme),
                                _buildCpmkChip('C3', student.grade?.cpmk3, theme),
                                _buildCpmkChip('C4', student.grade?.cpmk4, theme),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;
    final hasFilter = _searchQuery.isNotEmpty ||
        _selectedFilter != StudentStatusFilter.all;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.sky.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    hasFilter ? FLucideIcons.searchX : FLucideIcons.users,
                    size: 26,
                    color: colors.sky.foreground,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  hasFilter
                      ? 'Mahasiswa tidak ditemukan'
                      : 'Belum Ada Mahasiswa',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  hasFilter
                      ? 'Tidak ada mahasiswa yang sesuai dengan kata kunci atau filter status.'
                      : 'Tidak ada mahasiswa yang terdaftar pada kelas perkuliahan ini.',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasFilter) ...[
                  const SizedBox(height: 16),
                  FButton(
                    size: FButtonSizeVariant.sm,
                    variant: FButtonVariant.outline,
                    onPress: _resetFilterAndSearch,
                    child: const Text('Reset Filter'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.coral.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    FLucideIcons.circleAlert,
                    size: 26,
                    color: colors.coral.foreground,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Kendala Memuat Data Perkuliahan',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _errorMessage ??
                      'Terjadi kendala saat memuat data perkuliahan.',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FButton(
                  size: FButtonSizeVariant.sm,
                  onPress: _loadStudents,
                  child: const Text('Coba Lagi'),
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
    final offering = _offering;
    final filtered = _filteredStudents;

    return FScaffold(
      header: FHeader.nested(
        title: Text(offering?.courseName ?? 'Detail Perkuliahan'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
        ],
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat data perkuliahan...'))
          : _hasError
              ? _buildErrorView(context)
              : SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unified Hero Card with Class Info, 3 Stats, and Progress Bar
                      if (offering != null) _buildHeroCard(context, offering),

                      const SizedBox(height: 18),

                      // Section Heading
                      Text(
                        'Daftar Mahasiswa Terdaftar',
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ketuk mahasiswa untuk menginput atau mengubah nilai CPMK',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Search Field
                      FTextField(
                        hint: 'Cari nama atau NIM mahasiswa...',
                        clearable: (value) => value.text.isNotEmpty,
                        prefixBuilder: (context, style, variants) =>
                            FTextField.prefixIconBuilder(
                          context,
                          style,
                          variants,
                          const Icon(FLucideIcons.search),
                        ),
                        control: FTextFieldControl.managed(
                          controller: _searchController,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Filter Segment Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: 'Semua',
                              count: _totalStudents,
                              filter: StudentStatusFilter.all,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: 'Belum Dinilai',
                              count: _ungradedCount,
                              filter: StudentStatusFilter.ungraded,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: 'Sudah Dinilai',
                              count: _gradedCount,
                              filter: StudentStatusFilter.graded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Student Roster List or Empty State
                      if (filtered.isEmpty)
                        _buildEmptyState(context)
                      else
                        ...filtered.map(
                          (student) => _buildStudentCard(context, student),
                        ),
                    ],
                  ),
                ),
    );
  }
}
