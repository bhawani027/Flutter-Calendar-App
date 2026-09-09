/// Where a date sits relative to today.
///
/// Drives the past / current / upcoming styling that Google Calendar and
/// Outlook both use to make the current day obvious at a glance.
enum DayStatus {
  past,
  today,
  upcoming;

  /// Classifies [day] against [now] (defaults to the current moment).
  ///
  /// Comparison is by calendar day, so a meeting earlier this morning is still
  /// [today] rather than [past].
  static DayStatus of(DateTime day, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final a = DateTime(day.year, day.month, day.day);
    final b = DateTime(today.year, today.month, today.day);
    if (a.isBefore(b)) return DayStatus.past;
    if (a.isAfter(b)) return DayStatus.upcoming;
    return DayStatus.today;
  }

  bool get isToday => this == DayStatus.today;

  bool get isPast => this == DayStatus.past;
}
