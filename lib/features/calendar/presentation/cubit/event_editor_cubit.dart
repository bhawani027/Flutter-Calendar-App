import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../domain/entities/attendee.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/update_event.dart';

part 'event_editor_state.dart';

/// Drives the add/edit event form.
///
/// The old `Meetingeditor` did all of this in `setState` across 391 lines; the
/// widget is now purely a rendering of this state.
class EventEditorCubit extends Cubit<EventEditorState> {
  EventEditorCubit({
    required CreateEvent createEvent,
    required UpdateEvent updateEvent,
    CalendarEvent? existing,
    DateTime? initialDate,
  })  : _createEvent = createEvent,
        _updateEvent = updateEvent,
        super(
          existing != null
              ? EventEditorState.from(existing)
              : EventEditorState.blank(initialDate ?? DateTime.now()),
        );

  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;

  void titleChanged(String value) =>
      emit(state.copyWith(title: value, clearError: true));

  void notesChanged(String value) => emit(state.copyWith(notes: value));

  void allDayToggled(bool value) => emit(state.copyWith(isAllDay: value));

  void colorSelected(int colorValue) =>
      emit(state.copyWith(colorValue: colorValue));

  void recurrenceSelected(RecurrenceRule rule) =>
      emit(state.copyWith(recurrence: rule));

  void attendeesChanged(List<Attendee> attendees) =>
      emit(state.copyWith(attendees: attendees));

  void locationChanged(String? location) =>
      emit(state.copyWith(location: location));

  void timeZoneChanged(String? timeZoneId) =>
      emit(state.copyWith(timeZoneId: timeZoneId));

  /// Moves the start, dragging the end along so the duration is preserved.
  void startDateChanged(DateTime date) {
    final start = state.start.withDate(date);
    emit(state.copyWith(start: start, end: start.add(_duration)));
  }

  void startTimeChanged(int hour, int minute) {
    final start = state.start.withTime(hour, minute);
    emit(state.copyWith(start: start, end: start.add(_duration)));
  }

  void endDateChanged(DateTime date) =>
      emit(state.copyWith(end: state.end.withDate(date), clearError: true));

  void endTimeChanged(int hour, int minute) => emit(
        state.copyWith(end: state.end.withTime(hour, minute), clearError: true),
      );

  Duration get _duration {
    final current = state.end.difference(state.start);
    return current > Duration.zero ? current : const Duration(hours: 1);
  }

  /// Saves the form. Returns true when the event was persisted.
  Future<bool> submit() async {
    emit(state.copyWith(status: EventEditorStatus.saving, clearError: true));

    final start = state.isAllDay ? state.start.startOfDay : state.start;
    final end = state.isAllDay ? state.end.endOfDay : state.end;

    final result = state.isEditing
        ? await _updateEvent(
            CalendarEvent(
              id: state.id!,
              title: state.title,
              start: start,
              end: end,
              isAllDay: state.isAllDay,
              colorValue: state.colorValue,
              attendees: state.attendees,
              recurrence: state.recurrence,
              location: state.location,
              notes: state.notes,
              timeZoneId: state.timeZoneId,
            ),
          )
        : await _createEvent(
            CreateEventParams(
              title: state.title,
              start: start,
              end: end,
              isAllDay: state.isAllDay,
              colorValue: state.colorValue,
              attendees: state.attendees,
              recurrence: state.recurrence,
              location: state.location,
              notes: state.notes,
              timeZoneId: state.timeZoneId,
            ),
          );

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: EventEditorStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (_) {
        emit(state.copyWith(status: EventEditorStatus.saved));
        return true;
      },
    );
  }
}
