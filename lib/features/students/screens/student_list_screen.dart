import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/repositories/student_repository.dart';
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late final TextEditingController _searchController;
  List<Student> _allStudents = [];
  String _selectedProgram = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadStudents() async {
    try {
      final students = await StudentRepository.instance.getAllStudents();
      if (mounted) {
        setState(() {
          _allStudents = students;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data mahasiswa.';
        });
      }
    }
  }

  List<String> get _uniqueStudyPrograms {
    final prodis = <String>{};
    for (final s in _allStudents) {
      final p = s.studyProgram?.trim();
      if (p != null && p.isNotEmpty) {
        prodis.add(p);
      }
    }
    final sorted = prodis.toList()..sort();
    return ['Semua', ...sorted];
  }

  List<Student> get _filteredStudents {
    var list = _allStudents;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((s) {
        final matchesName = s.fullName.toLowerCase().contains(query);
        final matchesNim = s.nim.toLowerCase().contains(query);
        return matchesName || matchesNim;
      }).toList();
    }
    if (_selectedProgram != 'Semua') {
      list = list.where((s) => s.studyProgram == _selectedProgram).toList();
    }
    return list;
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'M';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _navigateToAddStudent() async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, _, _) => const StudentBiodataFormScreen(),
      ),
    );
    if (result == true) {
      _loadStudents();
    }
  }

  Future<void> _navigateToEditStudent(Student student) async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, _, _) => StudentBiodataFormScreen(student: student),
      ),
    );
    if (result == true) {
      _loadStudents();
    }
  }

  Widget _buildHeroOverviewCard(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;
    final totalStudents = _allStudents.length;
    final prodiCount = _uniqueStudyPrograms.where((p) => p != 'Semua').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.indigo.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          FLucideIcons.users,
                          size: 20,
                          color: colors.indigo.foreground,
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
                            '$totalStudents',
                            style: theme.typography.body.lg.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total Mahasiswa',
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: theme.colors.border,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.emerald.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          FLucideIcons.graduationCap,
                          size: 20,
                          color: colors.emerald.foreground,
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
                            '$prodiCount',
                            style: theme.typography.body.lg.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Program Studi',
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: FTextField(
        hint: 'Cari nama atau NIM mahasiswa...',
        clearable: (value) => value.text.isNotEmpty,
        prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
          context,
          style,
          variants,
          const Icon(FLucideIcons.search),
        ),
        control: FTextFieldControl.managed(controller: _searchController),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = context.theme;
    final programs = _uniqueStudyPrograms;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < programs.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _buildFilterChip(context, theme, programs[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, FThemeData theme, String program) {
    final isSelected = _selectedProgram == program;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Filter program studi $program',
      child: FTappable(
        onPress: () {
          setState(() {
            _selectedProgram = program;
          });
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colors.primary : theme.colors.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            program,
            style: theme.typography.body.xs.copyWith(
              color: isSelected
                  ? theme.colors.primaryForeground
                  : theme.colors.secondaryForeground,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final isFiltered = _searchController.text.trim().isNotEmpty || _selectedProgram != 'Semua';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FLucideIcons.users,
                  size: 48,
                  color: theme.colors.mutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mahasiswa tidak ditemukan',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'Tidak ada mahasiswa yang cocok dengan filter atau kata kunci pencarian.'
                      : 'Belum ada data mahasiswa terdaftar. Silakan tambahkan data baru.',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (isFiltered)
                  FButton(
                    onPress: () {
                      _searchController.clear();
                      setState(() {
                        _selectedProgram = 'Semua';
                      });
                    },
                    child: const Text('Reset Filter'),
                  )
                else
                  FButton(
                    onPress: _navigateToAddStudent,
                    child: const Text('Tambah Mahasiswa'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    final theme = context.theme;
    final colors = context.appColors;
    final pastelTokens = [
      colors.indigo,
      colors.emerald,
      colors.amber,
      colors.violet,
      colors.sky,
      colors.coral,
    ];
    final token = pastelTokens[student.nim.hashCode.abs() % pastelTokens.length];
    final initials = _getInitials(student.fullName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: 'Buka biodata ${student.fullName}',
        child: FTappable(
          onPress: () => _navigateToEditStudent(student),
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: token.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: theme.typography.body.sm.copyWith(
                          color: token.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIM: ${student.nim}',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        if (student.studyProgram != null && student.studyProgram!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          FBadge(
                            variant: FBadgeVariant.secondary,
                            child: Text(student.studyProgram!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    FLucideIcons.chevronRight,
                    size: 18,
                    color: theme.colors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Daftar Mahasiswa'),
        prefixes: [
          FHeaderAction.back(
            semanticsLabel: 'Kembali',
            onPress: () => Navigator.of(context).maybePop(),
          ),
        ],
        suffixes: [
          FHeaderAction(
            semanticsLabel: 'Tambah Mahasiswa',
            icon: const Icon(FLucideIcons.userPlus),
            onPress: _navigateToAddStudent,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeroOverviewCard(context),
          _buildSearchBar(context),
          _buildFilterChips(context),
          Expanded(
            child: _isLoading
                ? const Center(child: Text('Memuat data...'))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: FCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: context.theme.typography.body.sm,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  FButton(
                                    onPress: _loadStudents,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : _filteredStudents.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) =>
                                _buildStudentCard(context, _filteredStudents[index]),
                          ),
          ),
        ],
      ),
    );
  }
}
