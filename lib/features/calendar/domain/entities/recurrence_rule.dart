/// How often an event repeats.
///
/// [rrule] is the RFC 5545 recurrence string (the same format the calendar
/// widget and every major calendar server speak), or `null` for a one-off.
enum RecurrenceRule {
  never('Does not repeat', null),
  daily('Every day', 'FREQ=DAILY;INTERVAL=1'),
  weekly('Every week', 'FREQ=WEEKLY;INTERVAL=1'),
  monthly('Every month', 'FREQ=MONTHLY;INTERVAL=1'),
  yearly('Every year', 'FREQ=YEARLY;INTERVAL=1');

  const RecurrenceRule(this.label, this.rrule);

  final String label;
  final String? rrule;

  /// Parses a stored rule name, falling back to [never] for unknown values.
  static RecurrenceRule fromName(String? name) =>
      values.firstWhere((rule) => rule.name == name, orElse: () => never);
}
