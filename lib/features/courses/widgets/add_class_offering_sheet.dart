import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/courses/widgets/add_course_sheet.dart';

/// Modal bottom sheet for adding a new course offering (kelas perkuliahan)
/// with a searchable dropdown select for picking the master course.
class AddClassOfferingSheet extends StatefulWidget {
  final CourseOffering? initialOffering;

  const AddClassOfferingSheet({this.initialOffering, super.key});

  @override
  State<AddClassOfferingSheet> createState() => _AddClassOfferingSheetState();
}

class _AddClassOfferingSheetState extends State<AddClassOfferingSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _classNameController;
  late final TextEditingController _academicYearController;

  List<Course> _availableCourses = [];
  Course? _selectedCourse;
  String _selectedTerm = 'Ganjil';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEdit => widget.initialOffering != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialOffering;
    _classNameController = TextEditingController(text: initial?.className ?? '');
    _academicYearController = TextEditingController(text: initial?.academicYear ?? '2024/2025');
    if (initial != null) {
      _selectedTerm = initial.term;
    }
    _loadMasterCourses();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterCourses() async {
    try {
      final courses = await CourseRepository.instance.getAllCourses();
      if (mounted) {
        setState(() {
          _availableCourses = courses;
          if (widget.initialOffering != null) {
            _selectedCourse = courses.cast<Course?>().firstWhere(
              (c) => c?.courseCode == widget.initialOffering!.courseCode,
              orElse: () => courses.isNotEmpty ? courses.first : null,
            );
          } else if (courses.isNotEmpty) {
            _selectedCourse = courses.first;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _availableCourses = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddCourseSheet() async {
    final created = await showFSheet<bool>(
      context: context,
      side: FLayout.btt,
      builder: (context) => const AddCourseSheet(),
    );

    if (created == true) {
      await _loadMasterCourses();
    }
  }

  Future<void> _saveOffering() async {
    final className = _classNameController.text.trim();
    final academicYear = _academicYearController.text.trim();

    if (_selectedCourse == null) {
      setState(() => _errorMessage = 'Silakan pilih mata kuliah.');
      return;
    }

    if (className.isEmpty) {
      setState(() => _errorMessage = 'Nama kelas wajib diisi (contoh: IF-44-01).');
      return;
    }

    if (academicYear.isEmpty) {
      setState(() => _errorMessage = 'Tahun akademik wajib diisi.');
      return;
    }

    final lecturerId = AuthRepository.instance.activeLecturerId;
    if (lecturerId == null) {
      setState(() => _errorMessage = 'Sesi dosen tidak valid. Silakan login kembali.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (_isEdit) {
        final updatedOffering = widget.initialOffering!.copyWith(
          courseCode: _selectedCourse!.courseCode,
          className: className,
          academicYear: academicYear,
          term: _selectedTerm,
          courseName: _selectedCourse!.courseName,
          credits: _selectedCourse!.credits,
        );
        await CourseRepository.instance.updateOffering(updatedOffering);
      } else {
        final offeringId =
            'OFF_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
        await CourseRepository.instance.createOffering(
          CourseOffering(
            offeringId: offeringId,
            courseCode: _selectedCourse!.courseCode,
            lecturerId: lecturerId,
            className: className,
            academicYear: academicYear,
            term: _selectedTerm,
            courseName: _selectedCourse!.courseName,
            credits: _selectedCourse!.credits,
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage =
              'Gagal menyimpan kelas. Periksa kelengkapan data atau duplikasi kelas.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    final courseSelectItems = {
      for (final c in _availableCourses)
        '${c.courseCode} - ${c.courseName} (${c.credits} SKS)': c,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Fixed handle bar (does NOT scroll)
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

              // Fixed Header row (does NOT scroll)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                            FLucideIcons.school,
                            size: 18,
                            color: colors.sky.foreground,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEdit ? 'Edit Kelas Perkuliahan' : 'Tambah Kelas Kuliah',
                          style: theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.foreground,
                          ),
                        ),
                      ],
                    ),
                    FTappable(
                      onPress: () => Navigator.of(context).pop(),
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
                            child: Text('Memuat master mata kuliah...'),
                          ),
                        )
                      else if (_availableCourses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(
                                FLucideIcons.bookOpen,
                                size: 40,
                                color: theme.colors.mutedForeground,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada master mata kuliah',
                                style: theme.typography.body.md.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tambahkan master mata kuliah terlebih dahulu sebelum membuka kelas.',
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FButton(
                                size: FButtonSizeVariant.sm,
                                prefix: const Icon(FLucideIcons.plus),
                                onPress: _openAddCourseSheet,
                                child: const Text('Tambah Mata Kuliah'),
                              ),
                            ],
                          ),
                        )
                      else
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Searchable Dropdown Select for Course
                              FSelect<Course>.search(
                                items: courseSelectItems,
                                control: FSelectControl.managed(
                                  initial: _selectedCourse,
                                  onChange: (course) {
                                    if (course != null) {
                                      setState(() => _selectedCourse = course);
                                    }
                                  },
                                ),
                                filter: (query) => [
                                  for (final c in _availableCourses)
                                    if (c.courseCode
                                            .toLowerCase()
                                            .contains(query.toLowerCase()) ||
                                        c.courseName
                                            .toLowerCase()
                                            .contains(query.toLowerCase()))
                                      c,
                                ],
                                label: Text(
                                  'Mata Kuliah',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                hint: 'Pilih mata kuliah...',
                              ),
                              const SizedBox(height: 14),

                              // Row: Class Name & Academic Year
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nama Kelas',
                                          style: theme.typography.body.xs
                                              .copyWith(
                                            color: theme.colors.mutedForeground,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        FTextField(
                                          hint: 'Contoh: IF-44-01',
                                          control: FTextFieldControl.managed(
                                            controller: _classNameController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tahun Akademik',
                                          style: theme.typography.body.xs
                                              .copyWith(
                                            color: theme.colors.mutedForeground,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        FTextField(
                                          hint: '2024/2025',
                                          control: FTextFieldControl.managed(
                                            controller:
                                                _academicYearController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Semester Options
                              Text(
                                'Semester',
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: ['Ganjil', 'Genap'].map((term) {
                                  final isSelected = _selectedTerm == term;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: FTappable(
                                        onPress: () =>
                                            setState(() => _selectedTerm = term),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? colors.sky.background
                                                : theme.colors.card,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected
                                                  ? colors.sky.foreground
                                                  : theme.colors.border,
                                              width: isSelected ? 1.5 : 1,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Semester $term',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? colors.sky.foreground
                                                  : theme.colors.foreground,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),

                              // Submit Button
                              FButton(
                                onPress: _isSaving ? null : _saveOffering,
                                child: Text(
                                  _isSaving
                                      ? 'Menyimpan...'
                                      : (_isEdit
                                          ? 'Simpan Perubahan'
                                          : 'Simpan Kelas'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
