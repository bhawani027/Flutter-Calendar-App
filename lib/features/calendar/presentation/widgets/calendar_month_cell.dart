import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/calendar/bikram_sambat.dart';
import '../../../../core/calendar/nepali_date_labels.dart';
import '../../../../core/presentation/day_status.dart';

/// One day in the month grid, dated in both calendars.
///
/// Hamro Patro leads with the Bikram Sambat day and keeps the Gregorian one as
/// a smaller second line, which is the order here: the BS day in Nepali
/// numerals on top, the AD day beneath it. Under that go the event dots that
/// Google Calendar and Outlook use — dots rather than chips, so the cell keeps
/// a fixed height and a busy day cannot overflow it.
class CalendarMonthCell extends StatelessWidget {
  const CalendarMonthCell({
    required this.details,
    required this.visibleMonth,
    required this.isSelected,
    super.key,
  });

  /// How many dots fit before they are summarised.
  static const int maxDots = 4;

  /// The comfortable diameter of the BS date, and the smallest it shrinks to.
  ///
  /// A month grid divides whatever the agenda leaves over six rows, so cell
  /// height varies a lot: roughly 60px on a tall phone in portrait, and under
  /// 20px on the same phone in landscape. Every size below is derived from the
  /// height the cell is actually given so the column always fits inside it.
  static const double _preferredDiameter = 24;
  static const double _compactDiameter = 19;
  static const double _minDiameter = 11;

  /// Heights of the two lines that give way when there is no room: the AD date
  /// first, then the event dots.
  static const double _secondaryHeight = 11;
  static const double _dotsHeight = 7;

  /// The rule above the cell, which comes out of the height available inside.
  static const double _borderWidth = 0.5;

  final MonthCellDetails details;

  /// The month the grid is showing, so leading and trailing days can be dimmed.
  final int visibleMonth;

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = DayStatus.of(details.date);
    final isCurrentMonth = details.date.month == visibleMonth;

    final Color numberColor;
    if (status.isToday) {
      numberColor = colors.onPrimary;
    } else if (!isCurrentMonth) {
      numberColor = colors.onSurfaceVariant.withValues(alpha: 0.38);
    } else if (status.isPast) {
      numberColor = colors.onSurface.withValues(alpha: 0.55);
    } else {
      numberColor = colors.onSurface;
    }

    // Outside the BS table the cell falls back to the AD day on its own rather
    // than rendering a blank where the primary date should be.
    final bsDate = BikramSambat.tryFromGregorian(details.date);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.outlineVariant, width: _borderWidth),
        ),
        color: isSelected ? colors.primary.withValues(alpha: 0.10) : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxHeight - _borderWidth;

          // The BS date is sized first and capped at what the row actually
          // has, so the column cannot come out taller than the cell however
          // little that is; the lines below only get what is left over.
          final diameter = math.min(
            math.max(
              _minDiameter,
              math.min(
                available >= 46 ? _preferredDiameter : _compactDiameter,
                available - 2,
              ),
            ),
            available,
          );
          final topPadding = math.max(
            0.0,
            math.min(available >= 40 ? 3.0 : 1.0, available - diameter),
          );
          var spare = available - topPadding - diameter;

          // Outside the BS table the cell falls back to the AD day on its own
          // rather than leaving the primary line blank.
          final showSecondary = bsDate != null && spare >= _secondaryHeight;
          if (showSecondary) spare -= _secondaryHeight;
          final showDots = spare >= _dotsHeight;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: topPadding),
              _PrimaryDate(
                label: bsDate == null
                    ? '${details.date.day}'
                    : NepaliDateLabels.day(bsDate),
                isNepali: bsDate != null,
                color: numberColor,
                isToday: status.isToday,
                diameter: diameter,
              ),
              if (showSecondary)
                SizedBox(
                  height: _secondaryHeight,
                  child: _SecondaryDate(
                    // Padded so the line keeps one width all month and the
                    // column below the BS numeral does not shuffle sideways.
                    label: details.date.day.toString().padLeft(2, '0'),
                    dimmed: status.isPast || !isCurrentMonth,
                  ),
                ),
              if (showDots)
                SizedBox(
                  height: _dotsHeight,
                  child: _Dots(
                    appointments: details.appointments,
                    dimmed: status.isPast || !isCurrentMonth,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The Bikram Sambat day, in the today circle when it is today.
class _PrimaryDate extends StatelessWidget {
  const _PrimaryDate({
    required this.label,
    required this.isNepali,
    required this.color,
    required this.isToday,
    required this.diameter,
  });

  final String label;
  final bool isNepali;
  final Color color;
  final bool isToday;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium?.copyWith(
      color: color,
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
      // Devanagari numerals need a little more room than the Latin ones they
      // replace, so the line is pinned rather than left to the font's default.
      height: 1,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isToday
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: isNepali ? AppTheme.nepali(base) : base,
            ),
          ),
        ),
      ),
    );
  }
}

/// The Gregorian day, kept deliberately quieter than the BS one above it.
class _SecondaryDate extends StatelessWidget {
  const _SecondaryDate({required this.label, required this.dimmed});

  final String label;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      label,
      maxLines: 1,
      style: TextStyle(
        fontSize: 9,
        height: 1.1,
        letterSpacing: 0.2,
        color: colors.onSurfaceVariant.withValues(alpha: dimmed ? 0.5 : 0.85),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.appointments, required this.dimmed});

  final List<dynamic> appointments;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) return const SizedBox.shrink();

    final shown = appointments.take(CalendarMonthCell.maxDots).toList();
    final overflow = appointments.length - shown.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final appointment in shown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _Dot(
              color: appointment is Appointment
                  ? appointment.color
                  : Theme.of(context).colorScheme.primary,
              dimmed: dimmed,
            ),
          ),
        if (overflow > 0)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).colorScheme.onSurfaceVariant
                    .withValues(alpha: dimmed ? 0.5 : 1),
              ),
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.dimmed});

  final Color color;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dimmed ? 0.45 : 1),
        shape: BoxShape.circle,
      ),
    );
  }
}
