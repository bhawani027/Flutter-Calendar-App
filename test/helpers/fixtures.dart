import 'package:mycalendar_app/core/utils/id_generator.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/recurrence_rule.dart';

/// Returns the same id every time, so use-case assertions stay deterministic.
class FixedIdGenerator implements IdGenerator {
  const FixedIdGenerator(this.id);

  final String id;

  @override
  String newId() => id;
}

CalendarEvent buildEvent({
  String id = 'event-1',
  String title = 'Standup',
  DateTime? start,
  DateTime? end,
  bool isAllDay = false,
  int colorValue = CalendarEvent.defaultColorValue,
  List<Attendee> attendees = const [],
  RecurrenceRule recurrence = RecurrenceRule.never,
  String? location,
  String? notes,
  String? timeZoneId,
}) {
  final resolvedStart = start ?? DateTime(2026, 9, 3, 9);
  return CalendarEvent(
    id: id,
    title: title,
    start: resolvedStart,
    end: end ?? resolvedStart.add(const Duration(hours: 1)),
    isAllDay: isAllDay,
    colorValue: colorValue,
    attendees: attendees,
    recurrence: recurrence,
    location: location,
    notes: notes,
    timeZoneId: timeZoneId,
  );
}
