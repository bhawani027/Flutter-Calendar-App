part of 'event_editor_cubit.dart';

enum EventEditorStatus { editing, saving, saved, failure }

/// Everything the editor form holds, as data rather than widget state.
class EventEditorState extends Equatable {
  const EventEditorState({
    required this.start,
    required this.end,
    this.id,
    this.title = '',
    this.isAllDay = false,
    this.colorValue = CalendarEvent.defaultColorValue,
    this.attendees = const [],
    this.recurrence = RecurrenceRule.never,
    this.location,
    this.notes,
    this.timeZoneId,
    this.status = EventEditorStatus.editing,
    this.errorMessage,
  });

  /// A blank form starting at the next full hour after [anchor].
  factory EventEditorState.blank(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month, anchor.day, anchor.hour)
        .add(const Duration(hours: 1));
    return EventEditorState(
      start: start,
      end: start.add(const Duration(hours: 1)),
    );
  }

  /// A form pre-filled from an existing event.
  factory EventEditorState.from(CalendarEvent event) => EventEditorState(
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
      );

  final String? id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final int colorValue;
  final List<Attendee> attendees;
  final RecurrenceRule recurrence;
  final String? location;
  final String? notes;
  final String? timeZoneId;
  final EventEditorStatus status;
  final String? errorMessage;

  bool get isEditing => id != null;

  bool get isSaving => status == EventEditorStatus.saving;

  EventEditorState copyWith({
    String? title,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    int? colorValue,
    List<Attendee>? attendees,
    RecurrenceRule? recurrence,
    String? location,
    String? notes,
    String? timeZoneId,
    EventEditorStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EventEditorState(
      id: id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      colorValue: colorValue ?? this.colorValue,
      attendees: attendees ?? this.attendees,
      recurrence: recurrence ?? this.recurrence,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        start,
        end,
        isAllDay,
        colorValue,
        attendees,
        recurrence,
        location,
        notes,
        timeZoneId,
        status,
        errorMessage,
      ];
}
