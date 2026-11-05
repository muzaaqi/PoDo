import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/widgets/stat_card.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/grades/models/enrolled_student.dart';
import 'package:podo/features/grades/repositories/enrollment_repository.dart';
import 'package:podo/features/grades/widgets/grade_input_bottom_sheet.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseOffering? offering;

  const CourseDetailScreen({super.key, this.offering});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  CourseOffering? _offering;
  List<EnrolledStudent> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadStudents() async {
    if (_offering == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final students = await EnrollmentRepository.instance
          .getEnrolledStudentsByOffering(_offering!.offeringId);
      if (mounted) {
        setState(() {
          _students = students;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _students = [];
          _isLoading = false;
        });
      }
    }
  }

  int get _totalStudents => _students.length;
  int get _gradedCount => _students.where((s) => s.isGraded).length;
  int get _ungradedCount => _totalStudents - _gradedCount;

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'M';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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

  Widget _buildStudentCard(BuildContext context, EnrolledStudent student) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FTappable(
        onPress: () => _openGradeSheet(student),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                FAvatar.raw(
                  size: 40,
                  child: Text(
                    _getInitials(student.studentName),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.bold,
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
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NIM: ${student.studentNim}',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      if (student.isGraded) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Rata-rata: ${student.averageScore?.toStringAsFixed(1)} (CPMK: ${student.grade?.cpmk1?.toStringAsFixed(0)}, ${student.grade?.cpmk2?.toStringAsFixed(0)}, ${student.grade?.cpmk3?.toStringAsFixed(0)}, ${student.grade?.cpmk4?.toStringAsFixed(0)})',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FBadge(
                  variant: student.isGraded
                      ? FBadgeVariant.secondary
                      : FBadgeVariant.outline,
                  child: Text(student.isGraded ? 'Sudah Dinilai' : 'Belum Dinilai'),
                ),
                const SizedBox(width: 4),
                Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
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
    final theme = context.theme;
    final offering = _offering;

    return FScaffold(
      header: FHeader.nested(
        title: Text(offering?.courseName ?? 'Detail Perkuliahan'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
        ],
      ),
      child: _isLoading
          ? const Center(child: Text('Memuat data perkuliahan...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offering Info Card
                  if (offering != null)
                    FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${offering.courseCode} • Kelas ${offering.className}',
                                    style: theme.typography.body.sm.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Sudah Dinilai',
                          value: '$_gradedCount',
                          icon: FLucideIcons.checkCircle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: 'Belum Dinilai',
                          value: '$_ungradedCount',
                          icon: FLucideIcons.clock,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Total Mahasiswa',
                    value: '$_totalStudents',
                    icon: FLucideIcons.users,
                  ),

                  const SizedBox(height: 20),

                  // Student Roster Section Title
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

                  // Student Roster List
                  if (_students.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: FCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 32,
                            ),
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
                                  'Belum Ada Mahasiswa',
                                  style: theme.typography.body.md.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tidak ada mahasiswa yang terdaftar pada kelas perkuliahan ini.',
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._students.map(
                      (student) => _buildStudentCard(context, student),
                    ),
                ],
              ),
            ),
    );
  }
}
