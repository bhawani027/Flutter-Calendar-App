import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/presentation/day_status.dart';

/// One day in the month grid.
///
/// Google Calendar and Outlook both put the date number above a row of dots,
/// one per event, and grey out days outside the current month. Dots rather
/// than chips keep the cell a fixed height, so a busy day cannot overflow it.
class CalendarMonthCell extends StatelessWidget {
  const CalendarMonthCell({
    required this.details,
    required this.visibleMonth,
    required this.isSelected,
    super.key,
  });

  /// How many dots fit before they are summarised.
  static const int maxDots = 4;

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

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
        color: isSelected ? colors.primary.withValues(alpha: 0.10) : null,
      ),
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: status.isToday ? colors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Text(
                  '${details.date.day}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: numberColor,
                    fontWeight: status.isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: _Dots(
              appointments: details.appointments,
              dimmed: status.isPast || !isCurrentMonth,
            ),
          ),
        ],
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
