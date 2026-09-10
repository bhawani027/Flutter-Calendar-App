import 'package:intl/intl.dart';

import '../../../../core/calendar/bikram_sambat.dart';
import '../../../../core/calendar/nepali_date_labels.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../cubit/calendar_cubit.dart';

/// The titles shown in the calendar's app bar for the visible period.
///
/// [of] follows what Google Calendar and Outlook put there: the month for month
/// and schedule views, a date range for a week, and the full date for a single
/// day. [bs] is the same period in Bikram Sambat, for the second line of the
/// header.
///
/// Both are derived from the one focused `DateTime` the cubit holds, and the
/// week versions share [DateTimeX.startOfWeek], so the two lines always
/// describe the same days — there is no second calendar to fall out of step.
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

  /// The same period in BS, or null for a date outside the BS table — beyond
  /// which the header shows AD alone rather than nothing.
  static String? bs(CalendarViewType view, DateTime focused) {
    return switch (view) {
      CalendarViewType.day => _bsDayLabel(focused),
      CalendarViewType.week => _bsWeekLabel(focused),
      CalendarViewType.month ||
      CalendarViewType.schedule => _bsMonthLabel(focused),
    };
  }

  /// A week reads as `1 – 7 Sep 2026`, collapsing the repeated month, and as
  /// `28 Sep – 4 Oct 2026` when the week straddles two months.
  static String _weekLabel(DateTime focused) {
    final start = focused.startOfWeek;
    final end = start.addDays(6);

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

  static String? _bsDayLabel(DateTime focused) {
    final date = BikramSambat.tryFromGregorian(focused);
    return date == null ? null : NepaliDateLabels.fullDate(date);
  }

  /// A Gregorian month page always covers parts of two BS months, so it is
  /// named after whichever one owns most of it.
  static String? _bsMonthLabel(DateTime focused) {
    final month = BikramSambat.tryDominantMonth(focused.year, focused.month);
    return month == null ? null : NepaliDateLabels.monthAndYear(month);
  }

  /// Mirrors [_weekLabel], over the same seven days.
  static String? _bsWeekLabel(DateTime focused) {
    final adStart = focused.startOfWeek;
    final start = BikramSambat.tryFromGregorian(adStart);
    final end = BikramSambat.tryFromGregorian(adStart.addDays(6));
    if (start == null || end == null) return null;

    if (start.year != end.year) {
      return '${NepaliDateLabels.dayAndMonth(start)}, '
          '${NepaliDateLabels.year(start)} – '
          '${NepaliDateLabels.dayAndMonth(end)}, '
          '${NepaliDateLabels.year(end)}';
    }
    if (start.month != end.month) {
      return '${NepaliDateLabels.dayAndMonth(start)} – '
          '${NepaliDateLabels.dayAndMonth(end)}, '
          '${NepaliDateLabels.year(end)}';
    }
    return '${NepaliDateLabels.dayAndMonth(start)} – '
        '${NepaliDateLabels.day(end)}, ${NepaliDateLabels.year(end)}';
  }
}
