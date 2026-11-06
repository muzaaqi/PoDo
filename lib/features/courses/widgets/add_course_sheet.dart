import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/courses/models/course.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';

/// Modal bottom sheet for adding a new master course (mata kuliah master).
class AddCourseSheet extends StatefulWidget {
  const AddCourseSheet({super.key});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _creditsController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _nameController = TextEditingController();
    _creditsController = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final credits = int.tryParse(_creditsController.text.trim()) ?? 0;

    if (code.isEmpty || name.isEmpty) {
      setState(() => _errorMessage = 'Kode dan nama mata kuliah wajib diisi.');
      return;
    }

    if (credits <= 0 || credits > 6) {
      setState(() => _errorMessage = 'Bobot SKS harus berupa angka antara 1 sampai 6.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await CourseRepository.instance.createCourse(
        Course(
          courseCode: code,
          courseName: name,
          credits: credits,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Gagal menyimpan mata kuliah. Kode mata kuliah mungkin sudah terdaftar.';
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
                          'Tambah Mata Kuliah',
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

              // Scrollable form body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Form(
                    key: _formKey,
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

                        // Kode Mata Kuliah
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
                            controller: _codeController,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nama Mata Kuliah
                        Text(
                          'Nama Mata Kuliah',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FTextField(
                          hint: 'Contoh: Kecerdasan Buatan',
                          control: FTextFieldControl.managed(
                            controller: _nameController,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bobot SKS
                        Text(
                          'Bobot SKS',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FTextField(
                          hint: '3',
                          keyboardType: TextInputType.number,
                          control: FTextFieldControl.managed(
                            controller: _creditsController,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        FButton(
                          onPress: _isSaving ? null : _saveCourse,
                          child: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Mata Kuliah',
                          ),
                        ),
                      ],
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
