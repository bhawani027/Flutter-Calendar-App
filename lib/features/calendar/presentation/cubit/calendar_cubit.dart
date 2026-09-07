import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/presentation/load_status.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/watch_events.dart';

part 'calendar_state.dart';

/// Owns the calendar screen's state.
///
/// It only ever talks to use cases — it has no idea Hive exists. Navigation
/// itself is imperative (the widget drives the calendar controller); this holds
/// where the calendar currently *is*, so the header and the Today button can
/// render from state.
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required WatchEvents watchEvents,
    required DeleteEvent deleteEvent,
    DateTime? today,
  }) : _watchEvents = watchEvents,
       _deleteEvent = deleteEvent,
       super(CalendarState(focusedDate: today ?? DateTime.now()));

  final WatchEvents _watchEvents;
  final DeleteEvent _deleteEvent;

  StreamSubscription<void>? _subscription;

  /// Starts listening for events. Safe to call once, from the page's `initState`.
  Future<void> start() async {
    if (_subscription != null) return;
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));

    _subscription = _watchEvents(const NoParams()).listen((result) {
      result.match(
        (failure) => emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (events) => emit(
          state.copyWith(
            status: LoadStatus.ready,
            events: events,
            clearError: true,
          ),
        ),
      );
    });
  }

  void changeView(CalendarViewType view) {
    if (view == state.view) return;
    emit(state.copyWith(view: view));
  }

  /// Called as the user swipes between periods.
  ///
  /// [visibleDates] comes from the calendar widget; the middle one is used so
  /// that a month view padded with leading and trailing days still reports the
  /// month the user is actually looking at.
  void visibleRangeChanged(List<DateTime> visibleDates) {
    if (visibleDates.isEmpty) return;
    final anchor = visibleDates[visibleDates.length ~/ 2];
    if (anchor.isSameDay(state.focusedDate)) return;
    emit(state.copyWith(focusedDate: anchor));
  }

  void selectDate(DateTime date) =>
      emit(state.copyWith(selectedDate: date, focusedDate: date));

  void clearSelection() => emit(state.copyWith(clearSelection: true));

  Future<void> deleteEvent(String id) async {
    final result = await _deleteEvent(id);
    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      // The watch stream pushes the new list, so there is nothing to do here.
      (_) {},
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
