import 'package:intl/intl.dart';

import '../cubit/calendar_cubit.dart';

/// The title shown in the calendar's app bar for the visible period.
///
/// Follows what Google Calendar and Outlook put there: the month for month and
/// schedule views, a date range for a week, and the full date for a single day.
abstract final class CalendarPeriodLabel {
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayOfMonth = DateFormat('d');
  static final DateFormat _dayAndMonth = DateFormat('d MMM');
  static final DateFormat _fullDay = DateFormat('EEE, d MMM yyyy');

  static String of(CalendarViewType view, DateTime focused) {
    return switch (view) {
      CalendarViewType.day => _fullDay.format(focused),
      CalendarViewType.week => _weekLabel(focused),
      CalendarViewType.month ||
      CalendarViewType.schedule => _monthYear.format(focused),
    };
  }

  /// A week reads as `1 – 7 Sep 2026`, collapsing the repeated month, and as
  /// `28 Sep – 4 Oct 2026` when the week straddles two months.
  static String _weekLabel(DateTime focused) {
    final start = DateTime(
      focused.year,
      focused.month,
      focused.day,
    ).subtract(Duration(days: focused.weekday % 7));
    final end = start.add(const Duration(days: 6));

    if (start.year != end.year) {
      return '${_dayAndMonth.format(start)} ${start.year} – '
          '${_dayAndMonth.format(end)} ${end.year}';
    }
    if (start.month != end.month) {
      return '${_dayAndMonth.format(start)} – '
          '${_dayAndMonth.format(end)} ${end.year}';
    }
    return '${_dayOfMonth.format(start)} – '
        '${_dayAndMonth.format(end)} ${end.year}';
  }
}
