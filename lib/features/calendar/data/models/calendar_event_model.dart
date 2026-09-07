import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/recurrence_rule.dart';
import 'attendee_model.dart';

/// JSON mapping for [CalendarEvent].
///
/// Holds no state and defines no type of its own: entities go in, entities
/// come out, and the storage format is described in exactly one place.
abstract final class CalendarEventModel {
  static CalendarEvent fromJson(Map<String, dynamic> json) => CalendarEvent(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
    isAllDay: json['isAllDay'] as bool? ?? false,
    colorValue: json['colorValue'] as int? ?? CalendarEvent.defaultColorValue,
    attendees: (json['attendees'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              AttendeeModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    recurrence: RecurrenceRule.fromName(json['recurrence'] as String?),
    location: json['location'] as String?,
    notes: json['notes'] as String?,
    timeZoneId: json['timeZoneId'] as String?,
  );

  static Map<String, dynamic> toJson(CalendarEvent event) => {
    'id': event.id,
    'title': event.title,
    'start': event.start.toIso8601String(),
    'end': event.end.toIso8601String(),
    'isAllDay': event.isAllDay,
    'colorValue': event.colorValue,
    'attendees': event.attendees.map(AttendeeModel.toJson).toList(),
    'recurrence': event.recurrence.name,
    'location': event.location,
    'notes': event.notes,
    'timeZoneId': event.timeZoneId,
  };
}
