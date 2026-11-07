import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';
import 'package:podo/features/schedule/repositories/schedule_repository.dart';

/// Modal bottom sheet for creating or editing a teaching schedule.
class ScheduleFormSheet extends StatefulWidget {
  final TeachingSchedule? initialSchedule;
  final String? initialDay;

  const ScheduleFormSheet({
    this.initialSchedule,
    this.initialDay,
    super.key,
  });

  @override
  State<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<ScheduleFormSheet> {
  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  late final TextEditingController _roomController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;

  List<CourseOffering> _availableOfferings = [];
  CourseOffering? _selectedOffering;
  String _selectedDay = 'Senin';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _roomError;
  String? _startTimeError;
  String? _endTimeError;

  bool get _isEdit => widget.initialSchedule != null;

  int? _parseTimeToMinutes(String time) {
    final parts = time.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSchedule;
    _roomController = TextEditingController(text: initial?.room ?? '');
    _startTimeController =
        TextEditingController(text: initial?.startTime ?? '08:00');
    _endTimeController =
        TextEditingController(text: initial?.endTime ?? '10:30');
    _selectedDay = initial?.dayOfWeek ?? widget.initialDay ?? 'Senin';

    _loadOfferings();
  }

  @override
  void dispose() {
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadOfferings() async {
    final lecturerId = AuthRepository.instance.activeLecturerId;
    if (lecturerId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sesi dosen tidak ditemukan. Silakan login kembali.';
        });
      }
      return;
    }

    try {
      final offerings =
          await CourseRepository.instance.getOfferingsByLecturer(lecturerId);
      if (mounted) {
        setState(() {
          _availableOfferings = offerings;
          if (widget.initialSchedule != null) {
            _selectedOffering = offerings.cast<CourseOffering?>().firstWhere(
                  (o) => o?.offeringId == widget.initialSchedule!.offeringId,
                  orElse: () => offerings.isNotEmpty ? offerings.first : null,
                );
          } else if (offerings.isNotEmpty) {
            _selectedOffering = offerings.first;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _availableOfferings = [];
          _isLoading = false;
          _errorMessage = 'Gagal memuat data kelas perkuliahan.';
        });
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (_isSaving) return;

    String? generalErr;
    String? roomErr;
    String? startTimeErr;
    String? endTimeErr;

    if (_selectedOffering == null) {
      generalErr = 'Pilih kelas perkuliahan terlebih dahulu.';
    }

    final room = _roomController.text.trim();
    if (room.isEmpty) {
      roomErr = 'Ruangan kuliah wajib diisi.';
    }

    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();

    final startMinutes = _parseTimeToMinutes(startTime);
    final endMinutes = _parseTimeToMinutes(endTime);

    if (startTime.isEmpty) {
      startTimeErr = 'Jam mulai wajib diisi.';
    } else if (startMinutes == null) {
      startTimeErr = 'Format jam harus HH:MM (contoh: 08:00).';
    }

    if (endTime.isEmpty) {
      endTimeErr = 'Jam selesai wajib diisi.';
    } else if (endMinutes == null) {
      endTimeErr = 'Format jam harus HH:MM (contoh: 10:30).';
    } else if (startMinutes != null && endMinutes <= startMinutes) {
      endTimeErr = 'Jam selesai harus lebih akhir daripada jam mulai.';
    }

    if (generalErr != null ||
        roomErr != null ||
        startTimeErr != null ||
        endTimeErr != null) {
      setState(() {
        _roomError = roomErr;
        _startTimeError = startTimeErr;
        _endTimeError = endTimeErr;
        _errorMessage = generalErr ?? roomErr ?? startTimeErr ?? endTimeErr;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _roomError = null;
      _startTimeError = null;
      _endTimeError = null;
      _errorMessage = null;
    });

    try {
      if (_isEdit) {
        final updated = widget.initialSchedule!.copyWith(
          offeringId: _selectedOffering!.offeringId,
          dayOfWeek: _selectedDay,
          room: room,
          startTime: startTime,
          endTime: endTime,
        );
        await ScheduleRepository.instance.updateSchedule(updated);
      } else {
        await ScheduleRepository.instance.createSchedule(
          offeringId: _selectedOffering!.offeringId,
          dayOfWeek: _selectedDay,
          room: room,
          startTime: startTime,
          endTime: endTime,
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
              'Gagal menyimpan jadwal. Periksa kelengkapan data atau bentrok jadwal.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    final offeringSelectItems = {
      for (final o in _availableOfferings)
        '${o.courseName} (${o.className})': o,
    };

    final daySelectItems = {
      for (final day in _days) day: day,
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
                          FLucideIcons.calendar,
                          size: 18,
                          color: colors.sky.foreground,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isEdit ? 'Edit Jadwal Kuliah' : 'Tambah Jadwal Kuliah',
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
                          child: Text('Memuat data kelas perkuliahan...'),
                        ),
                      )
                    else if (_availableOfferings.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(
                              FLucideIcons.school,
                              size: 40,
                              color: theme.colors.mutedForeground,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum Ada Kelas Perkuliahan',
                              style: theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tambahkan kelas perkuliahan terlebih dahulu pada menu Mata Kuliah.',
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Select Offering
                      FSelect<CourseOffering>.search(
                        items: offeringSelectItems,
                        control: FSelectControl.managed(
                          initial: _selectedOffering,
                          onChange: (offering) {
                            if (offering != null) {
                              setState(() => _selectedOffering = offering);
                            }
                          },
                        ),
                        filter: (query) => [
                          for (final o in _availableOfferings)
                            if (o.courseName
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                o.className
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                o.courseCode
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                              o,
                        ],
                        label: Text(
                          'Kelas Perkuliahan',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        hint: 'Pilih kelas...',
                      ),
                      const SizedBox(height: 14),

                      // Select Day
                      FSelect<String>(
                        items: daySelectItems,
                        control: FSelectControl.managed(
                          initial: _selectedDay,
                          onChange: (day) {
                            if (day != null) {
                              setState(() => _selectedDay = day);
                            }
                          },
                        ),
                        label: Text(
                          'Hari Perkuliahan',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        hint: 'Pilih hari...',
                      ),
                      const SizedBox(height: 14),

                      // Room Field
                      Text(
                        'Ruangan Kuliah',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FTextField(
                        hint: 'Contoh: KU3.01 / LAB-02',
                        error: _roomError != null ? Text(_roomError!) : null,
                        prefixBuilder: (context, style, variants) =>
                            FTextField.prefixIconBuilder(
                          context,
                          style,
                          variants,
                          const Icon(FLucideIcons.mapPin),
                        ),
                        control: FTextFieldControl.managed(
                          controller: _roomController,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Times row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Mulai (HH:mm)',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FTextField(
                                  hint: '07:00',
                                  error: _startTimeError != null
                                      ? Text(_startTimeError!)
                                      : null,
                                  prefixBuilder: (context, style, variants) =>
                                      FTextField.prefixIconBuilder(
                                    context,
                                    style,
                                    variants,
                                    const Icon(FLucideIcons.clock),
                                  ),
                                  control: FTextFieldControl.managed(
                                    controller: _startTimeController,
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
                                  'Jam Selesai (HH:mm)',
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FTextField(
                                  hint: '09:30',
                                  error: _endTimeError != null
                                      ? Text(_endTimeError!)
                                      : null,
                                  prefixBuilder: (context, style, variants) =>
                                      FTextField.prefixIconBuilder(
                                    context,
                                    style,
                                    variants,
                                    const Icon(FLucideIcons.clock),
                                  ),
                                  control: FTextFieldControl.managed(
                                    controller: _endTimeController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      FButton(
                        onPress: _isSaving ? null : _saveSchedule,
                        child: Text(
                          _isSaving
                              ? 'Menyimpan...'
                              : (_isEdit
                                  ? 'Simpan Perubahan'
                                  : 'Simpan Jadwal'),
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
    );
  }
}
