import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/repositories/student_repository.dart';

class StudentBiodataFormScreen extends StatefulWidget {
  final Student? student;

  const StudentBiodataFormScreen({
    this.student,
    super.key,
  });

  @override
  State<StudentBiodataFormScreen> createState() => _StudentBiodataFormScreenState();
}

class _StudentBiodataFormScreenState extends State<StudentBiodataFormScreen> {
  late final TextEditingController _nimController;
  late final TextEditingController _nameController;
  late final TextEditingController _customStudyProgramController;
  late final TextEditingController _departmentController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  late final FocusNode _nimFocusNode;
  late final FocusNode _nameFocusNode;
  late final FocusNode _customStudyProgramFocusNode;
  late final FocusNode _departmentFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _addressFocusNode;

  String? _selectedStudyProgram;
  String? _nimError;
  String? _nameError;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEdit => widget.student != null;

  static const Map<String, String> _studyProgramOptions = {
    'Teknik Informatika': 'Teknik Informatika',
    'Sistem Informasi': 'Sistem Informasi',
    'Teknik Komputer': 'Teknik Komputer',
    'Rekayasa Perangkat Lunak': 'Rekayasa Perangkat Lunak',
    'Sains Data': 'Sains Data',
    'Lainnya (Kustom)': 'Lainnya',
  };

  static const Map<String, String> _defaultDepartments = {
    'Teknik Informatika': 'Teknologi Informasi',
    'Sistem Informasi': 'Sistem Informasi',
    'Teknik Komputer': 'Teknik Komputer',
    'Rekayasa Perangkat Lunak': 'Teknologi Informasi',
    'Sains Data': 'Matematika dan Sains Data',
  };

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nimController = TextEditingController(text: student?.nim ?? '');
    _nameController = TextEditingController(text: student?.fullName ?? '');
    _customStudyProgramController = TextEditingController();
    _departmentController = TextEditingController(text: student?.department ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _addressController = TextEditingController(text: student?.address ?? '');

    _nimFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _customStudyProgramFocusNode = FocusNode();
    _departmentFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _addressFocusNode = FocusNode();

    final initialProdi = student?.studyProgram;
    if (initialProdi != null && initialProdi.isNotEmpty) {
      if (_studyProgramOptions.containsValue(initialProdi)) {
        _selectedStudyProgram = initialProdi;
      } else {
        _selectedStudyProgram = 'Lainnya';
        _customStudyProgramController.text = initialProdi;
      }
    } else {
      _selectedStudyProgram = 'Teknik Informatika';
      if ((student?.department ?? '').isEmpty) {
        _departmentController.text = 'Teknologi Informasi';
      }
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _customStudyProgramController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    _nimFocusNode.dispose();
    _nameFocusNode.dispose();
    _customStudyProgramFocusNode.dispose();
    _departmentFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  String? get _resolvedStudyProgram {
    if (_selectedStudyProgram == 'Lainnya') {
      final custom = _customStudyProgramController.text.trim();
      return custom.isEmpty ? null : custom;
    }
    return _selectedStudyProgram;
  }

  bool get _isDirty {
    final student = widget.student;
    if (student == null) {
      return _nimController.text.trim().isNotEmpty ||
          _nameController.text.trim().isNotEmpty ||
          _phoneController.text.trim().isNotEmpty ||
          _addressController.text.trim().isNotEmpty ||
          _customStudyProgramController.text.trim().isNotEmpty ||
          (_selectedStudyProgram != 'Teknik Informatika');
    }

    final initialProdi = student.studyProgram ?? '';
    final currentProdi = _resolvedStudyProgram ?? '';
    final initialDept = student.department ?? '';
    final currentDept = _departmentController.text.trim();

    return _nameController.text.trim() != student.fullName ||
        currentProdi != initialProdi ||
        currentDept != initialDept ||
        _phoneController.text.trim() != (student.phone ?? '') ||
        _addressController.text.trim() != (student.address ?? '');
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty || _isLoading) return true;

    final discard = await showFDialog<bool>(
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
                'Buang Perubahan?',
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data biodata mahasiswa yang sudah Anda isi belum disimpan dan akan hilang jika Anda keluar.',
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
                    child: const Text('Lanjut Mengisi'),
                  ),
                  const SizedBox(width: 8),
                  FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Buang Perubahan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return discard == true;
  }

  Future<void> _saveStudent() async {
    final nim = _nimController.text.trim();
    final name = _nameController.text.trim();

    String? nimErr;
    String? nameErr;

    if (nim.isEmpty) {
      nimErr = 'NIM wajib diisi';
    }

    if (name.isEmpty) {
      nameErr = 'Nama lengkap wajib diisi';
    }

    if (nimErr != null || nameErr != null) {
      setState(() {
        _nimError = nimErr;
        _nameError = nameErr;
      });
      return;
    }

    setState(() {
      _nimError = null;
      _nameError = null;
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      if (!_isEdit) {
        final exists = await StudentRepository.instance.isNimExists(nim);
        if (exists) {
          setState(() {
            _nimError = 'NIM sudah terdaftar';
            _isLoading = false;
          });
          return;
        }
      }

      final student = Student(
        nim: nim,
        fullName: name,
        studyProgram: _resolvedStudyProgram,
        department: _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );
      if (_isEdit) {
        await StudentRepository.instance.updateStudent(student);
      } else {
        await StudentRepository.instance.createStudent(student);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal menyimpan biodata mahasiswa: ${e.toString().replaceFirst('Exception: ', '')}';
        });
        showFToast(
          context: context,
          title: const Text('Gagal menyimpan biodata mahasiswa'),
        );
      }
    }
  }

  Future<void> _deleteStudent() async {
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
                'Konfirmasi Hapus',
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus data mahasiswa ini?',
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
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted && widget.student != null) {
      try {
        await StudentRepository.instance.deleteStudent(widget.student!.nim);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Gagal menghapus data mahasiswa: ${e.toString().replaceFirst('Exception: ', '')}';
          });
          showFToast(
            context: context,
            title: const Text('Gagal menghapus mahasiswa'),
          );
        }
      }
    }
  }

  Widget _buildErrorBanner(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.coral.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FLucideIcons.circleAlert,
            size: 16,
            color: colors.coral.foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.coral.foreground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FTappable(
            onPress: () => setState(() => _errorMessage = null),
            child: Icon(
              FLucideIcons.x,
              size: 14,
              color: colors.coral.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    final theme = context.theme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.bold,
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
      ],
    );
  }

  Widget _buildAcademicCard(BuildContext context) {
    final colors = context.appColors;
    final theme = context.theme;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              icon: FLucideIcons.graduationCap,
              iconColor: colors.emerald.foreground,
              iconBg: colors.emerald.background,
              title: 'Data Akademik & Identitas',
              subtitle: 'Informasi pokok mahasiswa dan program studi',
            ),
            const SizedBox(height: 16),
            FTextField(
              label: const Text('Nomor Induk Mahasiswa (NIM)'),
              hint: 'Contoh: 2101001',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              focusNode: _nimFocusNode,
              enabled: !_isEdit,
              error: _nimError != null ? Text(_nimError!) : null,
              description: _isEdit
                  ? const Text('NIM bersifat tetap dan tidak dapat diubah')
                  : null,
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.hash),
              ),
              control: FTextFieldControl.managed(controller: _nimController),
            ),
            const SizedBox(height: 14),
            FTextField(
              label: const Text('Nama Lengkap'),
              hint: 'Contoh: Ahmad Fauzi',
              textInputAction: TextInputAction.next,
              focusNode: _nameFocusNode,
              error: _nameError != null ? Text(_nameError!) : null,
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.user),
              ),
              control: FTextFieldControl.managed(controller: _nameController),
            ),
            const SizedBox(height: 14),
            FSelect<String>(
              items: _studyProgramOptions,
              control: FSelectControl.managed(
                initial: _selectedStudyProgram,
                onChange: (prodi) {
                  if (prodi != null) {
                    setState(() {
                      _selectedStudyProgram = prodi;
                      if (prodi != 'Lainnya' && _defaultDepartments.containsKey(prodi)) {
                        _departmentController.text = _defaultDepartments[prodi]!;
                      }
                    });
                  }
                },
              ),
              label: Text(
                'Program Studi',
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              hint: 'Pilih program studi...',
            ),
            if (_selectedStudyProgram == 'Lainnya') ...[
              const SizedBox(height: 14),
              FTextField(
                label: const Text('Nama Program Studi Kustom'),
                hint: 'Contoh: Manajemen Informatika',
                focusNode: _customStudyProgramFocusNode,
                textInputAction: TextInputAction.next,
                prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const Icon(FLucideIcons.bookOpen),
                ),
                control: FTextFieldControl.managed(controller: _customStudyProgramController),
              ),
            ],
            const SizedBox(height: 14),
            FTextField(
              label: const Text('Jurusan / Departemen'),
              hint: 'Contoh: Teknologi Informasi',
              focusNode: _departmentFocusNode,
              textInputAction: TextInputAction.next,
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.building2),
              ),
              control: FTextFieldControl.managed(controller: _departmentController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final colors = context.appColors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              icon: FLucideIcons.phone,
              iconColor: colors.indigo.foreground,
              iconBg: colors.indigo.background,
              title: 'Kontak & Domisili',
              subtitle: 'Nomor telepon dan alamat tempat tinggal',
            ),
            const SizedBox(height: 16),
            FTextField(
              label: const Text('Nomor Telepon'),
              hint: 'Contoh: 081234567890',
              keyboardType: TextInputType.phone,
              focusNode: _phoneFocusNode,
              textInputAction: TextInputAction.next,
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.phone),
              ),
              control: FTextFieldControl.managed(controller: _phoneController),
            ),
            const SizedBox(height: 14),
            FTextField.multiline(
              label: const Text('Alamat Lengkap'),
              hint: 'Contoh: Jl. Merdeka No. 10, Bandung',
              focusNode: _addressFocusNode,
              textInputAction: TextInputAction.done,
              minLines: 2,
              maxLines: 4,
              control: FTextFieldControl.managed(controller: _addressController),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: FScaffold(
        header: FHeader.nested(
          title: Text(_isEdit ? 'Edit Biodata Mahasiswa' : 'Tambah Mahasiswa'),
          prefixes: [
            FHeaderAction.back(
              semanticsLabel: 'Kembali',
              onPress: () async {
                final canPop = await _onWillPop();
                if (canPop && context.mounted) {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ],
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) _buildErrorBanner(context),
              _buildAcademicCard(context),
              const SizedBox(height: 16),
              _buildContactCard(context),
              const SizedBox(height: 24),
              FButton(
                onPress: _isLoading ? null : _saveStudent,
                child: Text(
                  _isLoading
                      ? 'Menyimpan...'
                      : (_isEdit ? 'Simpan Perubahan' : 'Simpan Mahasiswa'),
                ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 12),
                FButton(
                  variant: FButtonVariant.destructive,
                  onPress: _isLoading ? null : _deleteStudent,
                  child: const Text('Hapus Mahasiswa'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
