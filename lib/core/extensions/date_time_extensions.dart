extension DateTimeX on DateTime {
  /// Midnight on the same calendar day.
  DateTime get startOfDay => DateTime(year, month, day);

  /// The last microsecond of the same calendar day.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Midnight on the Sunday that opens this date's week.
  ///
  /// Counted in calendar days rather than by subtracting a `Duration`: 24 hours
  /// back from a Monday is not always Sunday, since the clocks may have moved
  /// in between.
  DateTime get startOfWeek => DateTime(year, month, day - weekday % 7);

  /// Midnight [days] calendar days after this date.
  DateTime addDays(int days) => DateTime(year, month, day + days);

  /// Replaces the time-of-day while keeping the calendar date.
  DateTime withTime(int hour, int minute) =>
      DateTime(year, month, day, hour, minute);

  /// Replaces the calendar date while keeping the time-of-day.
  DateTime withDate(DateTime date) =>
      DateTime(date.year, date.month, date.day, hour, minute);
}
