import '../../domain/entities/attendee.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/recurrence_rule.dart';
import 'attendee_model.dart';

/// Serialisable form of [CalendarEvent].
///
/// Extending the entity means repositories can hand a model straight back as a
/// domain object; only the JSON knowledge is added here.
class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.title,
    required super.start,
    required super.end,
    super.isAllDay,
    super.colorValue,
    super.attendees,
    super.recurrence,
    super.location,
    super.notes,
    super.timeZoneId,
    super.reminderBefore,
  });

  factory CalendarEventModel.fromEntity(CalendarEvent event) =>
      CalendarEventModel(
        id: event.id,
        title: event.title,
        start: event.start,
        end: event.end,
        isAllDay: event.isAllDay,
        colorValue: event.colorValue,
        attendees: event.attendees,
        recurrence: event.recurrence,
        location: event.location,
        notes: event.notes,
        timeZoneId: event.timeZoneId,
        reminderBefore: event.reminderBefore,
      );

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    final reminderMinutes = json['reminderMinutesBefore'] as int?;
    return CalendarEventModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      colorValue:
          json['colorValue'] as int? ?? CalendarEvent.defaultColorValue,
      attendees: (json['attendees'] as List<dynamic>? ?? [])
          .map((item) => AttendeeModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      recurrence: RecurrenceRule.fromName(json['recurrence'] as String?),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      timeZoneId: json['timeZoneId'] as String?,
      reminderBefore:
          reminderMinutes == null ? null : Duration(minutes: reminderMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'isAllDay': isAllDay,
        'colorValue': colorValue,
        'attendees': attendees
            .map((attendee) => AttendeeModel.fromEntity(attendee).toJson())
            .toList(),
        'recurrence': recurrence.name,
        'location': location,
        'notes': notes,
        'timeZoneId': timeZoneId,
        'reminderMinutesBefore': reminderBefore?.inMinutes,
      };

  CalendarEvent toEntity() => CalendarEvent(
        id: id,
        title: title,
        start: start,
        end: end,
        isAllDay: isAllDay,
        colorValue: colorValue,
        // Rebuilt as plain entities so no model type escapes into the domain.
        attendees: List<Attendee>.unmodifiable(
          attendees.map(
            (attendee) =>
                Attendee(name: attendee.name, email: attendee.email),
          ),
        ),
        recurrence: recurrence,
        location: location,
        notes: notes,
        timeZoneId: timeZoneId,
        reminderBefore: reminderBefore,
      );
}
