import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/grades/repositories/enrollment_repository.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/repositories/student_repository.dart';

/// Modal bottom sheet to enroll a student into a specific course offering.
class AddStudentToOfferingSheet extends StatefulWidget {
  final CourseOffering offering;
  final Set<String> enrolledNims;

  const AddStudentToOfferingSheet({
    required this.offering,
    required this.enrolledNims,
    super.key,
  });

  @override
  State<AddStudentToOfferingSheet> createState() =>
      _AddStudentToOfferingSheetState();
}

class _AddStudentToOfferingSheetState extends State<AddStudentToOfferingSheet> {
  List<Student> _availableStudents = [];
  Student? _selectedStudent;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  Future<void> _loadAvailableStudents() async {
    try {
      final allStudents = await StudentRepository.instance.getAllStudents();
      final available = allStudents
          .where((student) => !widget.enrolledNims.contains(student.nim))
          .toList();

      if (mounted) {
        setState(() {
          _availableStudents = available;
          if (available.isNotEmpty) {
            _selectedStudent = available.first;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _availableStudents = [];
          _isLoading = false;
          _errorMessage = 'Gagal memuat data mahasiswa dari database.';
        });
      }
    }
  }

  Future<void> _enrollSelectedStudent() async {
    if (_selectedStudent == null) {
      setState(() => _errorMessage = 'Silakan pilih mahasiswa.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await EnrollmentRepository.instance.enrollStudent(
        offeringId: widget.offering.offeringId,
        studentNim: _selectedStudent!.nim,
      );

      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _navigateToNewStudentForm() async {
    Navigator.of(context).pop(false);
    await Navigator.of(context).pushNamed(AppRoutes.studentBiodataForm);
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'M';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    final studentSelectItems = {
      for (final s in _availableStudents)
        '${s.nim} - ${s.fullName}${s.studyProgram != null ? ' (${s.studyProgram})' : ''}':
            s,
    };

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Fixed Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.sky.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              FLucideIcons.userPlus,
                              size: 18,
                              color: colors.sky.foreground,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tambah Mahasiswa ke Kelas',
                                  style: theme.typography.body.md.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.offering.courseName} (Kelas ${widget.offering.className})',
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
                    const SizedBox(width: 8),
                    FTappable(
                      onPress: () => Navigator.of(context).pop(false),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          FLucideIcons.x,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colors.coral.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FLucideIcons.circleAlert,
                                size: 16,
                                color: colors.coral.foreground,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.coral.foreground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('Memuat data mahasiswa...'),
                          ),
                        )
                      else if (_availableStudents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.sky.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  FLucideIcons.users,
                                  size: 24,
                                  color: colors.sky.foreground,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak Ada Mahasiswa Tersedia',
                                style: theme.typography.body.md.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Semua mahasiswa yang ada di sistem sudah terdaftar pada kelas ini, atau belum ada biodata mahasiswa.',
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FButton(
                                size: FButtonSizeVariant.sm,
                                prefix: const Icon(FLucideIcons.userPlus),
                                onPress: _navigateToNewStudentForm,
                                child: const Text('Buat Biodata Mahasiswa Baru'),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Searchable Dropdown for Student
                        FSelect<Student>.search(
                          items: studentSelectItems,
                          control: FSelectControl.managed(
                            initial: _selectedStudent,
                            onChange: (student) {
                              if (student != null) {
                                setState(() => _selectedStudent = student);
                              }
                            },
                          ),
                          filter: (query) => [
                            for (final s in _availableStudents)
                              if (s.nim
                                      .toLowerCase()
                                      .contains(query.toLowerCase()) ||
                                  s.fullName
                                      .toLowerCase()
                                      .contains(query.toLowerCase()) ||
                                  (s.studyProgram
                                          ?.toLowerCase()
                                          .contains(query.toLowerCase()) ??
                                      false))
                                s,
                          ],
                          label: Text(
                            'Pilih Mahasiswa',
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          hint: 'Cari berdasarkan nama atau NIM...',
                        ),

                        const SizedBox(height: 16),

                        // Selected Student Preview Card
                        if (_selectedStudent != null) ...[
                          Text(
                            'Detail Mahasiswa Terpilih',
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: colors.sky.background,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInitials(_selectedStudent!.fullName),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colors.sky.foreground,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedStudent!.fullName,
                                          style: theme.typography.body.sm
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'NIM: ${_selectedStudent!.nim}${_selectedStudent!.studyProgram != null ? ' (${_selectedStudent!.studyProgram})' : ''}',
                                          style: theme.typography.body.xs
                                              .copyWith(
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
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Action Buttons
                        FButton(
                          prefix: const Icon(FLucideIcons.userPlus),
                          onPress: _isSaving || _selectedStudent == null
                              ? null
                              : _enrollSelectedStudent,
                          child: Text(
                            _isSaving ? 'Menambahkan...' : 'Tambahkan ke Kelas',
                          ),
                        ),
                        const SizedBox(height: 10),
                        FButton(
                          variant: FButtonVariant.ghost,
                          onPress: _isSaving ? null : _navigateToNewStudentForm,
                          child: const Text(
                            'Mahasiswa belum terdaftar? Buat biodata baru',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
