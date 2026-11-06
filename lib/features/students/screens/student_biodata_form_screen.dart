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
  late final TextEditingController _studyProgramController;
  late final TextEditingController _departmentController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _nimError;
  String? _nameError;
  bool _isLoading = false;

  bool get _isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nimController = TextEditingController(text: student?.nim ?? '');
    _nameController = TextEditingController(text: student?.fullName ?? '');
    _studyProgramController = TextEditingController(text: student?.studyProgram ?? '');
    _departmentController = TextEditingController(text: student?.department ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _addressController = TextEditingController(text: student?.address ?? '');
  }

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _studyProgramController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    final nim = _nimController.text.trim();
    final name = _nameController.text.trim();

    String? nimErr;
    String? nameErr;

    if (nim.isEmpty) {
      nimErr = 'NIM wajib diisi';
    } else if (!_isEdit) {
      final exists = await StudentRepository.instance.isNimExists(nim);
      if (exists) {
        nimErr = 'NIM sudah terdaftar';
      }
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
      _isLoading = true;
    });

    final student = Student(
      nim: nim,
      fullName: name,
      studyProgram: _studyProgramController.text.trim().isEmpty ? null : _studyProgramController.text.trim(),
      department: _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
    );

    try {
      if (_isEdit) {
        await StudentRepository.instance.updateStudent(student);
      } else {
        await StudentRepository.instance.createStudent(student);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      await StudentRepository.instance.deleteStudent(widget.student!.nim);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
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
            FTextField(
              label: const Text('Program Studi'),
              hint: 'Contoh: Teknik Informatika',
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const Icon(FLucideIcons.bookOpen),
              ),
              control: FTextFieldControl.managed(controller: _studyProgramController),
            ),
            const SizedBox(height: 14),
            FTextField(
              label: const Text('Jurusan / Departemen'),
              hint: 'Contoh: Teknologi Informasi',
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
              control: FTextFieldControl.managed(controller: _addressController),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Text(_isEdit ? 'Edit Biodata Mahasiswa' : 'Tambah Mahasiswa'),
        prefixes: [
          FHeaderAction.back(
            semanticsLabel: 'Kembali',
            onPress: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
    );
  }
}
