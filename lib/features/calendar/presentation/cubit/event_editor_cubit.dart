import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/presentation/load_status.dart';
import '../../domain/entities/attendee.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/update_event.dart';

part 'event_editor_state.dart';

/// Drives the add/edit event form.
///
/// The old `Meetingeditor` did all of this in `setState` across 391 lines; the
/// widget is now purely a rendering of this state. Edits are applied with
/// `copyWith` on the event itself, so fields the form does not show — on an
/// existing event — survive a save untouched.
class EventEditorCubit extends Cubit<EventEditorState> {
  EventEditorCubit({
    required CreateEvent createEvent,
    required UpdateEvent updateEvent,
    CalendarEvent? existing,
    DateTime? initialDate,
  })  : _createEvent = createEvent,
        _updateEvent = updateEvent,
        super(
          EventEditorState(
            draft: existing ?? CalendarEvent.draft(initialDate ?? DateTime.now()),
            isNew: existing == null,
          ),
        );

  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;

  void _edit(CalendarEvent Function(CalendarEvent draft) change) =>
      emit(state.copyWith(draft: change(state.draft), clearError: true));

  void titleChanged(String value) =>
      _edit((draft) => draft.copyWith(title: value));

  void notesChanged(String value) =>
      _edit((draft) => draft.copyWith(notes: value));

  void allDayToggled(bool value) =>
      _edit((draft) => draft.copyWith(isAllDay: value));

  void colorSelected(int colorValue) =>
      _edit((draft) => draft.copyWith(colorValue: colorValue));

  void recurrenceSelected(RecurrenceRule rule) =>
      _edit((draft) => draft.copyWith(recurrence: rule));

  void attendeesChanged(List<Attendee> attendees) =>
      _edit((draft) => draft.copyWith(attendees: attendees));

  void locationChanged(String? location) =>
      _edit((draft) => draft.copyWith(location: location));

  void timeZoneChanged(String? timeZoneId) =>
      _edit((draft) => draft.copyWith(timeZoneId: timeZoneId));

  /// Moves the start, dragging the end along so the duration is preserved.
  void startDateChanged(DateTime date) => _moveStart(state.draft.start.withDate(date));

  void startTimeChanged(int hour, int minute) =>
      _moveStart(state.draft.start.withTime(hour, minute));

  void _moveStart(DateTime start) {
    final current = state.draft.duration;
    final span = current > Duration.zero ? current : const Duration(hours: 1);
    _edit((draft) => draft.copyWith(start: start, end: start.add(span)));
  }

  void endDateChanged(DateTime date) =>
      _edit((draft) => draft.copyWith(end: draft.end.withDate(date)));

  void endTimeChanged(int hour, int minute) =>
      _edit((draft) => draft.copyWith(end: draft.end.withTime(hour, minute)));

  /// Saves the form. Returns true when the event was persisted.
  Future<bool> submit() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));

    final result = state.isNew
        ? await _createEvent(state.draft)
        : await _updateEvent(state.draft);

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (_) {
        emit(state.copyWith(status: LoadStatus.ready));
        return true;
      },
    );
  }
}
