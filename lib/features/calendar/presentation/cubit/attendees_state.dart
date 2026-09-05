part of 'attendees_cubit.dart';

class AttendeesState extends Equatable {
  const AttendeesState({
    this.attendees = const [],
    this.name = '',
    this.email = '',
    this.errorMessage,
  });

  final List<Attendee> attendees;

  /// The half-filled row at the top of the screen.
  final String name;
  final String email;
  final String? errorMessage;

  AttendeesState copyWith({
    List<Attendee>? attendees,
    String? name,
    String? email,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AttendeesState(
      attendees: attendees ?? this.attendees,
      name: name ?? this.name,
      email: email ?? this.email,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [attendees, name, email, errorMessage];
}
