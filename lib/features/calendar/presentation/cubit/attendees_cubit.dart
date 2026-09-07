import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attendee.dart';

part 'attendees_state.dart';

/// Holds the guest list while it is being edited.
///
/// The page used to keep the list and the half-typed row in `setState`, which
/// made it the one screen not driven by a cubit — and put the email rule in a
/// widget validator rather than on [Attendee].
class AttendeesCubit extends Cubit<AttendeesState> {
  AttendeesCubit(List<Attendee> initial)
      : super(AttendeesState(attendees: List.unmodifiable(initial)));

  void nameChanged(String value) =>
      emit(state.copyWith(name: value, clearError: true));

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearError: true));

  /// Adds the typed person. Returns true when they were added, so the page
  /// knows whether to clear its fields.
  bool add() {
    final candidate = Attendee(name: state.name, email: state.email);
    final failure = candidate.validate();
    if (failure != null) {
      emit(state.copyWith(errorMessage: failure.message));
      return false;
    }

    emit(
      state.copyWith(
        attendees: List.unmodifiable([
          ...state.attendees,
          candidate.normalized(),
        ]),
        name: '',
        email: '',
        clearError: true,
      ),
    );
    return true;
  }

  void removeAt(int index) {
    final remaining = [...state.attendees]..removeAt(index);
    emit(state.copyWith(attendees: List.unmodifiable(remaining)));
  }
}
