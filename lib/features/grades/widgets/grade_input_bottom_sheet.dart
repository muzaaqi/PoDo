import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/grades/models/enrolled_student.dart';
import 'package:podo/features/grades/models/grade.dart';
import 'package:podo/features/grades/repositories/grade_repository.dart';

class GradeInputBottomSheet extends StatefulWidget {
  final EnrolledStudent student;

  const GradeInputBottomSheet({
    required this.student,
    super.key,
  });

  @override
  State<GradeInputBottomSheet> createState() => _GradeInputBottomSheetState();
}

class _GradeInputBottomSheetState extends State<GradeInputBottomSheet> {
  late final TextEditingController _cpmk1Controller;
  late final TextEditingController _cpmk2Controller;
  late final TextEditingController _cpmk3Controller;
  late final TextEditingController _cpmk4Controller;

  String? _cpmk1Error;
  String? _cpmk2Error;
  String? _cpmk3Error;
  String? _cpmk4Error;

  bool _isSaving = false;

  String _formatScore(double? score) {
    if (score == null) return '';
    if (score == score.toInt()) {
      return score.toInt().toString();
    }
    return score.toString();
  }

  @override
  void initState() {
    super.initState();
    final grade = widget.student.grade;
    _cpmk1Controller = TextEditingController(text: _formatScore(grade?.cpmk1));
    _cpmk2Controller = TextEditingController(text: _formatScore(grade?.cpmk2));
    _cpmk3Controller = TextEditingController(text: _formatScore(grade?.cpmk3));
    _cpmk4Controller = TextEditingController(text: _formatScore(grade?.cpmk4));
  }

  @override
  void dispose() {
    _cpmk1Controller.dispose();
    _cpmk2Controller.dispose();
    _cpmk3Controller.dispose();
    _cpmk4Controller.dispose();
    super.dispose();
  }

  String? _validateScore(String text) {
    final trimmed = text.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) {
      return 'Nilai CPMK harus diisi';
    }
    final value = double.tryParse(trimmed);
    if (value == null) {
      return 'Nilai harus berupa angka valid';
    }
    if (value < 0 || value > 100) {
      return 'Nilai harus antara 0 - 100';
    }
    return null;
  }

  Future<void> _saveGrade() async {
    final err1 = _validateScore(_cpmk1Controller.text);
    final err2 = _validateScore(_cpmk2Controller.text);
    final err3 = _validateScore(_cpmk3Controller.text);
    final err4 = _validateScore(_cpmk4Controller.text);

    setState(() {
      _cpmk1Error = err1;
      _cpmk2Error = err2;
      _cpmk3Error = err3;
      _cpmk4Error = err4;
    });

    if (err1 != null || err2 != null || err3 != null || err4 != null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final grade = Grade(
        id: widget.student.grade?.id,
        enrollmentId: widget.student.enrollmentId,
        cpmk1: double.parse(_cpmk1Controller.text.trim().replaceAll(',', '.')),
        cpmk2: double.parse(_cpmk2Controller.text.trim().replaceAll(',', '.')),
        cpmk3: double.parse(_cpmk3Controller.text.trim().replaceAll(',', '.')),
        cpmk4: double.parse(_cpmk4Controller.text.trim().replaceAll(',', '.')),
      );

      await GradeRepository.instance.upsertGrade(grade);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmResetGrade() async {
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
                'Reset Nilai Mahasiswa?',
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Seluruh nilai CPMK untuk ${widget.student.studentName} akan dihapus dan status kembali menjadi Belum Dinilai.',
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
                    child: const Text('Reset Nilai'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      try {
        await GradeRepository.instance.deleteGrade(widget.student.enrollmentId);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isSaving = false);
        }
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
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header row with Icon, Title, Subtitle, and Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.emerald.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            FLucideIcons.award,
                            size: 18,
                            color: colors.emerald.foreground,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penilaian CPMK Mahasiswa',
                                style: theme.typography.body.md.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colors.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.student.studentName} (${widget.student.studentNim})',
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
              const SizedBox(height: 18),
              FTextField(
                label: const Text('CPMK 1'),
                hint: '0 - 100',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                error: _cpmk1Error != null ? Text(_cpmk1Error!) : null,
                control: FTextFieldControl.managed(controller: _cpmk1Controller),
              ),
              const SizedBox(height: 14),
              FTextField(
                label: const Text('CPMK 2'),
                hint: '0 - 100',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                error: _cpmk2Error != null ? Text(_cpmk2Error!) : null,
                control: FTextFieldControl.managed(controller: _cpmk2Controller),
              ),
              const SizedBox(height: 14),
              FTextField(
                label: const Text('CPMK 3'),
                hint: '0 - 100',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                error: _cpmk3Error != null ? Text(_cpmk3Error!) : null,
                control: FTextFieldControl.managed(controller: _cpmk3Controller),
              ),
              const SizedBox(height: 14),
              FTextField(
                label: const Text('CPMK 4'),
                hint: '0 - 100',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                error: _cpmk4Error != null ? Text(_cpmk4Error!) : null,
                control: FTextFieldControl.managed(controller: _cpmk4Controller),
              ),
              const SizedBox(height: 24),
              FButton(
                onPress: _isSaving ? null : _saveGrade,
                child: Text(_isSaving ? 'Menyimpan...' : 'Simpan Nilai'),
              ),
              if (widget.student.isGraded) ...[
                const SizedBox(height: 10),
                FButton(
                  variant: FButtonVariant.destructive,
                  onPress: _isSaving ? null : _confirmResetGrade,
                  child: const Text('Reset Nilai'),
                ),
              ],
              const SizedBox(height: 10),
              FButton(
                variant: FButtonVariant.outline,
                onPress: _isSaving ? null : () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
