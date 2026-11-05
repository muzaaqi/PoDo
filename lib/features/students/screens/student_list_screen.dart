import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
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
  List<Student> _students = [];
  bool _isLoading = true;

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
    _loadStudents(query: _searchController.text);
  }

  Future<void> _loadStudents({String? query}) async {
    final students = await StudentRepository.instance.getAllStudents(query: query);
    if (mounted) {
      setState(() {
        _students = students;
        _isLoading = false;
      });
    }
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
      _loadStudents(query: _searchController.text);
    }
  }

  Future<void> _navigateToEditStudent(Student student) async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, _, _) => StudentBiodataFormScreen(student: student),
      ),
    );
    if (result == true) {
      _loadStudents(query: _searchController.text);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;

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
                  'Coba gunakan kata kunci pencarian lain atau tambahkan data mahasiswa baru.',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FTappable(
        onPress: () => _navigateToEditStudent(student),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                FAvatar.raw(
                  size: 42,
                  child: Text(
                    _getInitials(student.fullName),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.bold,
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
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NIM: ${student.nim}',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      if (student.studyProgram != null) ...[
                        const SizedBox(height: 6),
                        FBadge(
                          variant: FBadgeVariant.secondary,
                          child: Text(student.studyProgram!),
                        ),
                      ],
                    ],
                  ),
                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Daftar Mahasiswa'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.userPlus),
            onPress: _navigateToAddStudent,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: FTextField(
              hint: 'Cari berdasarkan nama atau NIM...',
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.search),
              ),
              control: FTextFieldControl.managed(controller: _searchController),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: Text('Memuat data...'))
                : _students.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: _students.length,
                        itemBuilder: (context, index) =>
                            _buildStudentCard(context, _students[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
