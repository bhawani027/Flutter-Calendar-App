extension DateTimeX on DateTime {
  /// Midnight on the same calendar day.
  DateTime get startOfDay => DateTime(year, month, day);

  /// The last microsecond of the same calendar day.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Replaces the time-of-day while keeping the calendar date.
  DateTime withTime(int hour, int minute) =>
      DateTime(year, month, day, hour, minute);

  /// Replaces the calendar date while keeping the time-of-day.
  DateTime withDate(DateTime date) =>
      DateTime(date.year, date.month, date.day, hour, minute);
}
