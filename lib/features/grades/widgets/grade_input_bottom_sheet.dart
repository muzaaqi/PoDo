import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
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
    final trimmed = text.trim();
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
        cpmk1: double.parse(_cpmk1Controller.text.trim()),
        cpmk2: double.parse(_cpmk2Controller.text.trim()),
        cpmk3: double.parse(_cpmk3Controller.text.trim()),
        cpmk4: double.parse(_cpmk4Controller.text.trim()),
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colors.mutedForeground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Penilaian CPMK Mahasiswa',
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.student.studentName} • NIM: ${widget.student.studentNim}',
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 10),
          FButton(
            variant: FButtonVariant.outline,
            onPress: _isSaving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}
