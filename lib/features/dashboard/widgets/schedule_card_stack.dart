import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/schedule/models/teaching_schedule.dart';

/// Swipeable infinite stacked card deck for teaching schedules.
///
/// Supports infinite swiping backward and forward to view next/previous courses.
/// When tapped, delegates to [onScheduleTap] (typically navigating to course detail).
class ScheduleCardStack extends StatefulWidget {
  final List<TeachingSchedule> schedules;
  final DateTime? currentDateTime;
  final ValueChanged<TeachingSchedule> onScheduleTap;

  const ScheduleCardStack({
    super.key,
    required this.schedules,
    this.currentDateTime,
    required this.onScheduleTap,
  });

  @override
  State<ScheduleCardStack> createState() => _ScheduleCardStackState();
}

class _ScheduleCardStackState extends State<ScheduleCardStack>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  double _dragStartX = 0.0;

  late final AnimationController _animController;
  Animation<double>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = _findInitialIndex();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        if (_offsetAnimation != null) {
          setState(() {
            _dragOffset = _offsetAnimation!.value;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant ScheduleCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schedules.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= widget.schedules.length) {
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int _findInitialIndex() {
    if (widget.schedules.isEmpty) return 0;

    final now = widget.currentDateTime ?? DateTime.now();
    final dayName = _getDayName(now.weekday);
    final currentMinutes = now.hour * 60 + now.minute;

    // 1. Ongoing schedule today
    for (int i = 0; i < widget.schedules.length; i++) {
      final s = widget.schedules[i];
      if (s.dayOfWeek.trim().toLowerCase() == dayName.toLowerCase()) {
        final start = _parseTimeToMinutes(s.startTime);
        final end = _parseTimeToMinutes(s.endTime);
        if (start != null &&
            end != null &&
            currentMinutes >= start &&
            currentMinutes <= end) {
          return i;
        }
      }
    }

    // 2. Next upcoming schedule today
    for (int i = 0; i < widget.schedules.length; i++) {
      final s = widget.schedules[i];
      if (s.dayOfWeek.trim().toLowerCase() == dayName.toLowerCase()) {
        final start = _parseTimeToMinutes(s.startTime);
        if (start != null && currentMinutes < start) {
          return i;
        }
      }
    }

    // 3. Any schedule today
    for (int i = 0; i < widget.schedules.length; i++) {
      final s = widget.schedules[i];
      if (s.dayOfWeek.trim().toLowerCase() == dayName.toLowerCase()) {
        return i;
      }
    }

    return 0;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      default:
        return 'Minggu';
    }
  }

  int? _parseTimeToMinutes(String time) {
    try {
      final parts = time.trim().split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (_) {}
    return null;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (widget.schedules.length <= 1) return;
    _dragStartX = details.globalPosition.dx;
    _isDragging = false;
    _animController.stop();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.schedules.length <= 1) return;
    final delta = details.globalPosition.dx - _dragStartX;
    if (delta.abs() > 8) {
      _isDragging = true;
    }
    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.schedules.length <= 1) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final distance = _dragOffset;

    if (velocity < -300 || distance < -70) {
      // Swiping left -> Go to Next schedule
      _animateCardExit(toLeft: true);
    } else if (velocity > 300 || distance > 70) {
      // Swiping right -> Go to Previous schedule
      _animateCardExit(toLeft: false);
    } else {
      // Spring back to center
      _animateSpringBack();
    }
  }

  void _animateCardExit({required bool toLeft}) {
    if (_animController.isAnimating) return;

    final targetOffset = toLeft ? -360.0 : 360.0;
    _offsetAnimation = Tween<double>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          final count = widget.schedules.length;
          if (toLeft) {
            _currentIndex = (_currentIndex + 1) % count;
          } else {
            _currentIndex = (_currentIndex - 1 + count) % count;
          }
          _dragOffset = 0.0;
          _offsetAnimation = null;
          _isDragging = false;
        });
        _animController.reset();
      }
    });
  }

  void _animateSpringBack() {
    if (_animController.isAnimating) return;

    _offsetAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = 0.0;
          _offsetAnimation = null;
          _isDragging = false;
        });
        _animController.reset();
      }
    });
  }

  void _swipeNext() {
    if (widget.schedules.length <= 1 || _animController.isAnimating) return;
    _animateCardExit(toLeft: true);
  }

  void _swipePrev() {
    if (widget.schedules.length <= 1 || _animController.isAnimating) return;
    _animateCardExit(toLeft: false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedules.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = widget.schedules.length;
    final currentSchedule = widget.schedules[_currentIndex % total];

    if (total == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _ScheduleCardItem(
          schedule: currentSchedule,
          currentDateTime: widget.currentDateTime,
          onTap: () => widget.onScheduleTap(currentSchedule),
        ),
      );
    }

    // Multi-card Stack
    final dragFraction = (_dragOffset / 200).clamp(-1.0, 1.0);

    // Determine underneath card:
    // When dragging left (< 0): preview next card
    // When dragging right (> 0): preview previous card
    // When resting (= 0): preview next card
    final peekNextIndex = (_currentIndex + 1) % total;
    final peekPrevIndex = (_currentIndex - 1 + total) % total;
    final underIndex = _dragOffset >= 0 && _isDragging ? peekPrevIndex : peekNextIndex;
    final underSchedule = widget.schedules[underIndex];

    final peekThirdIndex = (_currentIndex + 2) % total;
    final hasThirdCard = total >= 3;
    final thirdSchedule = hasThirdCard ? widget.schedules[peekThirdIndex] : null;

    final underScale = 0.94 + (0.06 * dragFraction.abs());
    final underOffsetY = -8.0 + (8.0 * dragFraction.abs());

    final thirdScale = 0.88 + (0.06 * dragFraction.abs());
    final thirdOffsetY = -16.0 + (8.0 * dragFraction.abs());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card Deck Stack Area
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: GestureDetector(
            onTap: () {
              if (!_isDragging && _dragOffset.abs() < 10) {
                widget.onScheduleTap(currentSchedule);
              }
            },
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Layer 2: Deep background card (if >= 3 cards)
                if (hasThirdCard && thirdSchedule != null)
                  Transform.translate(
                    offset: Offset(0, thirdOffsetY),
                    child: Transform.scale(
                      scale: thirdScale,
                      child: Opacity(
                        opacity: 0.6,
                        child: IgnorePointer(
                          child: _ScheduleCardItem(
                            schedule: thirdSchedule,
                            currentDateTime: widget.currentDateTime,
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                  ),

                // Layer 1: Peeking Underneath Card (middle)
                Transform.translate(
                  offset: Offset(0, underOffsetY),
                  child: Transform.scale(
                    scale: underScale,
                    child: Opacity(
                      opacity: 0.88 + (0.12 * dragFraction.abs()),
                      child: IgnorePointer(
                        child: _ScheduleCardItem(
                          schedule: underSchedule,
                          currentDateTime: widget.currentDateTime,
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 0: Front Interactive Card
                Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: Transform.rotate(
                    angle: (_dragOffset / 1000).clamp(-0.15, 0.15),
                    child: _ScheduleCardItem(
                      schedule: currentSchedule,
                      currentDateTime: widget.currentDateTime,
                      onTap: () {
                        if (!_isDragging && _dragOffset.abs() < 10) {
                          widget.onScheduleTap(currentSchedule);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bottom Deck Navigation & Page Indicator Dots
        _buildStackControls(context, total),
      ],
    );
  }

  Widget _buildStackControls(BuildContext context, int total) {
    final theme = context.theme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          label: 'Jadwal sebelumnya',
          child: FTappable(
            onPress: _swipePrev,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                FLucideIcons.chevronLeft,
                size: 18,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (index) {
            final isSelected = index == (_currentIndex % total);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colors.primary
                    : theme.colors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
        const SizedBox(width: 4),
        Semantics(
          button: true,
          label: 'Jadwal berikutnya',
          child: FTappable(
            onPress: _swipeNext,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                FLucideIcons.chevronRight,
                size: 18,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders a single schedule card matching PoDo's design system.
class _ScheduleCardItem extends StatelessWidget {
  final TeachingSchedule schedule;
  final DateTime? currentDateTime;
  final VoidCallback onTap;

  const _ScheduleCardItem({
    required this.schedule,
    this.currentDateTime,
    required this.onTap,
  });

  int? _parseTimeToMinutes(String time) {
    try {
      final parts = time.trim().split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (_) {}
    return null;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      default:
        return 'Minggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    final now = currentDateTime ?? DateTime.now();
    final todayName = _getDayName(now.weekday);
    final isToday = schedule.dayOfWeek.trim().toLowerCase() == todayName.toLowerCase();

    final startMinutes = _parseTimeToMinutes(schedule.startTime) ?? 0;
    final endMinutes = _parseTimeToMinutes(schedule.endTime) ?? 0;
    final currentMinutes = now.hour * 60 + now.minute;

    final isOngoing = isToday && (currentMinutes >= startMinutes && currentMinutes <= endMinutes);
    final isUpcomingToday = isToday && (currentMinutes < startMinutes);
    final isPastToday = isToday && (currentMinutes > endMinutes);

    final totalDuration = (endMinutes - startMinutes).clamp(1, 1440);
    final elapsedMinutes = (currentMinutes - startMinutes).clamp(0, totalDuration);
    final remainingMinutes = (endMinutes - currentMinutes).clamp(0, totalDuration);
    final progress = (elapsedMinutes / totalDuration).clamp(0.0, 1.0);

    // Pick token based on status
    final cardToken = isOngoing
        ? colors.amber
        : (isUpcomingToday
            ? colors.sky
            : (isPastToday ? colors.emerald : colors.violet));

    final semanticsLabel = isOngoing
        ? 'Jadwal sekarang: ${schedule.courseName}, Kelas ${schedule.className}, ${schedule.credits} SKS, '
            'Ruangan ${schedule.room}, pukul ${schedule.startTime} sampai ${schedule.endTime}. '
            'Tersisa $remainingMinutes menit. Geser untuk melihat jadwal lain, ketuk untuk membuka detail mata kuliah.'
        : 'Jadwal: ${schedule.courseName}, Kelas ${schedule.className}, ${schedule.credits} SKS, '
            'Hari ${schedule.dayOfWeek}, pukul ${schedule.startTime} sampai ${schedule.endTime}, Ruangan ${schedule.room}. '
            'Geser untuk melihat jadwal lain, ketuk untuk membuka detail mata kuliah.';

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: FTappable(
        onPress: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardToken.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0A000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Calendar icon container, Course title, Class & SKS Pills, Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isOngoing
                          ? FLucideIcons.calendarClock
                          : (isToday ? FLucideIcons.calendarDays : FLucideIcons.calendar),
                      size: 22,
                      color: cardToken.foreground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.courseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cardToken.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.card,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Kelas ${schedule.className}',
                                style: TextStyle(
                                  color: cardToken.foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.card,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '${schedule.credits} SKS',
                                style: TextStyle(
                                  color: cardToken.foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: theme.colors.card,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: cardToken.foreground,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom info row: Day & Time with Clock Icon, Room with MapPin Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.clock,
                        size: 15,
                        color: cardToken.foreground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${schedule.dayOfWeek}, ${schedule.startTime} - ${schedule.endTime}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cardToken.foreground,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.mapPin,
                        size: 15,
                        color: cardToken.foreground,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        schedule.room,
                        style: TextStyle(
                          fontSize: 12,
                          color: cardToken.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Lower section: Real-time progress bar (if ongoing) OR contextual status banner
              if (isOngoing)
                _buildOngoingProgress(
                  context,
                  progress: progress,
                  remainingMinutes: remainingMinutes,
                  cardToken: cardToken,
                  now: now,
                )
              else
                _buildContextualBanner(
                  context,
                  isUpcomingToday: isUpcomingToday,
                  isPastToday: isPastToday,
                  cardToken: cardToken,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingProgress(
    BuildContext context, {
    required double progress,
    required int remainingMinutes,
    required ColorToken cardToken,
    required DateTime now,
  }) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FLucideIcons.timer,
                size: 13,
                color: remainingMinutes <= 15
                    ? context.appColors.coral.foreground
                    : cardToken.foreground,
              ),
              const SizedBox(width: 5),
              Text(
                remainingMinutes > 0
                    ? 'Tersisa $remainingMinutes mnt'
                    : 'Waktu Habis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: remainingMinutes <= 15
                      ? context.appColors.coral.foreground
                      : cardToken.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                // Forui Determinate Progress
                FDeterminateProgress(
                  value: progress,
                  style: FDeterminateProgressStyle(
                    constraints: const BoxConstraints.tightFor(height: 6),
                    trackDecoration: BoxDecoration(
                      color: cardToken.background,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fillDecoration: BoxDecoration(
                      color: cardToken.foreground,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                // Real-time current position dot showing percentage
                Align(
                  alignment: Alignment(
                    (-1.0 + 2.0 * progress).clamp(-1.0, 1.0),
                    0.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cardToken.foreground,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: theme.colors.card,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFFFFF),
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                schedule.startTime,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Pukul ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: cardToken.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                schedule.endTime,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContextualBanner(
    BuildContext context, {
    required bool isUpcomingToday,
    required bool isPastToday,
    required ColorToken cardToken,
  }) {
    final theme = context.theme;

    final IconData bannerIcon;
    final String bannerTitle;
    final String bannerSubtitle;

    if (isUpcomingToday) {
      bannerIcon = FLucideIcons.calendarClock;
      bannerTitle = 'Jadwal Mendatang Hari Ini';
      bannerSubtitle = 'Perkuliahan dimulai pukul ${schedule.startTime} di ${schedule.room}';
    } else if (isPastToday) {
      bannerIcon = FLucideIcons.circleCheck;
      bannerTitle = 'Perkuliahan Hari Ini Selesai';
      bannerSubtitle = 'Jadwal berakhir pukul ${schedule.endTime}';
    } else {
      bannerIcon = FLucideIcons.calendar;
      bannerTitle = 'Jadwal Hari ${schedule.dayOfWeek}';
      bannerSubtitle = 'Pukul ${schedule.startTime} - ${schedule.endTime} di ${schedule.room}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            bannerIcon,
            size: 16,
            color: cardToken.foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bannerTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cardToken.foreground,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  bannerSubtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
