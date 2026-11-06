import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';

/// Modal bottom sheet for adding a new course offering (kelas perkuliahan).
class AddCourseOfferingSheet extends StatefulWidget {
  const AddCourseOfferingSheet({super.key});

  @override
  State<AddCourseOfferingSheet> createState() => _AddCourseOfferingSheetState();
}

class _AddCourseOfferingSheetState extends State<AddCourseOfferingSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _classNameController;
  late final TextEditingController _academicYearController;

  // New course controllers (if creating new course code)
  late final TextEditingController _newCodeController;
  late final TextEditingController _newNameController;
  late final TextEditingController _newCreditsController;

  List<Course> _availableCourses = [];
  Course? _selectedCourse;
  bool _isCreatingNewCourse = false;
  String _selectedTerm = 'Ganjil';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController();
    _academicYearController = TextEditingController(text: '2024/2025');
    _newCodeController = TextEditingController();
    _newNameController = TextEditingController();
    _newCreditsController = TextEditingController(text: '3');
    _loadMasterCourses();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _academicYearController.dispose();
    _newCodeController.dispose();
    _newNameController.dispose();
    _newCreditsController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterCourses() async {
    try {
      final courses = await CourseRepository.instance.getAllCourses();
      if (mounted) {
        setState(() {
          _availableCourses = courses;
          if (courses.isNotEmpty) {
            _selectedCourse = courses.first;
          } else {
            _isCreatingNewCourse = true;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCreatingNewCourse = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveOffering() async {
    if (_isSaving) return;

    final className = _classNameController.text.trim();
    final academicYear = _academicYearController.text.trim();

    if (className.isEmpty) {
      setState(() => _errorMessage = 'Nama kelas wajib diisi (contoh: IF-44-01).');
      return;
    }
    if (academicYear.isEmpty) {
      setState(() => _errorMessage = 'Tahun akademik wajib diisi (contoh: 2024/2025).');
      return;
    }

    final String courseCode;
    final String courseName;
    final int credits;

    if (_isCreatingNewCourse) {
      final code = _newCodeController.text.trim();
      final name = _newNameController.text.trim();
      final cr = int.tryParse(_newCreditsController.text.trim()) ?? 0;

      if (code.isEmpty || name.isEmpty) {
        setState(() => _errorMessage = 'Kode dan nama mata kuliah baru wajib diisi.');
        return;
      }
      if (cr <= 0 || cr > 6) {
        setState(() => _errorMessage = 'SKS harus berupa angka antara 1 sampai 6.');
        return;
      }

      courseCode = code;
      courseName = name;
      credits = cr;
    } else {
      if (_selectedCourse == null) {
        setState(() => _errorMessage = 'Silakan pilih mata kuliah.');
        return;
      }
      courseCode = _selectedCourse!.courseCode;
      courseName = _selectedCourse!.courseName;
      credits = _selectedCourse!.credits;
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
      if (_isCreatingNewCourse) {
        await CourseRepository.instance.createCourse(Course(
          courseCode: courseCode,
          courseName: courseName,
          credits: credits,
        ));
      }

      final offeringId = 'OFF_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
      await CourseRepository.instance.createOffering(CourseOffering(
        offeringId: offeringId,
        courseCode: courseCode,
        lecturerId: lecturerId,
        className: className,
        academicYear: academicYear,
        term: _selectedTerm,
        courseName: courseName,
        credits: credits,
      ));

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Gagal menyimpan kelas. Periksa kelengkapan data atau duplikasi kelas.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.violet.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.bookPlus,
                        size: 18,
                        color: colors.violet.foreground,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tambah Kelas Kuliah',
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
                    child: Icon(FLucideIcons.x, size: 20, color: theme.colors.mutedForeground),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.coral.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(FLucideIcons.circleAlert, size: 16, color: colors.coral.foreground),
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
                child: Center(child: Text('Memuat master mata kuliah...')),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toggle Choose Existing vs New Course
                    if (_availableCourses.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: FTappable(
                              onPress: () => setState(() => _isCreatingNewCourse = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isCreatingNewCourse ? theme.colors.primary : theme.colors.card,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: !_isCreatingNewCourse ? theme.colors.primary : theme.colors.border,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Pilih Mata Kuliah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: !_isCreatingNewCourse ? const Color(0xFFFFFFFF) : theme.colors.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FTappable(
                              onPress: () => setState(() => _isCreatingNewCourse = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isCreatingNewCourse ? theme.colors.primary : theme.colors.card,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isCreatingNewCourse ? theme.colors.primary : theme.colors.border,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+ Mata Kuliah Baru',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isCreatingNewCourse ? const Color(0xFFFFFFFF) : theme.colors.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Section 1: Course Selection or Creation
                    if (!_isCreatingNewCourse && _availableCourses.isNotEmpty) ...[
                      Text(
                        'Pilih Mata Kuliah Tersedia',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableCourses.map((c) {
                          final isSelected = _selectedCourse?.courseCode == c.courseCode;
                          return FTappable(
                            onPress: () => setState(() => _selectedCourse = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.violet.background : theme.colors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? colors.violet.foreground : theme.colors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${c.courseCode} - ${c.courseName}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? colors.violet.foreground : theme.colors.foreground,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colors.card,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      '${c.credits} SKS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? colors.violet.foreground : theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      // Create new course inputs
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kode Mata Kuliah',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FTextField(
                                  hint: 'Contoh: IF104',
                                  control: FTextFieldControl.managed(
                                    controller: _newCodeController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SKS',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FTextField(
                                  hint: '3',
                                  control: FTextFieldControl.managed(
                                    controller: _newCreditsController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nama Mata Kuliah Baru',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FTextField(
                        hint: 'Contoh: Kecerdasan Buatan',
                        control: FTextFieldControl.managed(
                          controller: _newNameController,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Section 2: Offering details (Class Name, Academic Year, Term)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama Kelas',
                                style: theme.typography.body.xs.copyWith(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tahun Akademik',
                                style: theme.typography.body.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              FTextField(
                                hint: '2024/2025',
                                control: FTextFieldControl.managed(
                                  controller: _academicYearController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

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
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FTappable(
                              onPress: () => setState(() => _selectedTerm = term),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.sky.background : theme.colors.card,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? colors.sky.foreground : theme.colors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Semester $term',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? colors.sky.foreground : theme.colors.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Submit Button
                    FButton(
                      onPress: _isSaving ? null : _saveOffering,
                      child: Text(_isSaving ? 'Menyimpan...' : 'Simpan Kelas'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
