import 'package:equatable/equatable.dart';

/// A person invited to a [CalendarEvent].
class Attendee extends Equatable {
  const Attendee({required this.name, required this.email});

  final String name;
  final String email;

  @override
  List<Object?> get props => [name, email];
}
