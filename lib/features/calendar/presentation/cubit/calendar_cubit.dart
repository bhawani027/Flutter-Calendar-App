import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/watch_events.dart';

part 'calendar_state.dart';

/// Owns the calendar screen's state.
///
/// It only ever talks to use cases — it has no idea Hive exists.
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required WatchEvents watchEvents,
    required DeleteEvent deleteEvent,
  })  : _watchEvents = watchEvents,
        _deleteEvent = deleteEvent,
        super(const CalendarState());

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
