import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

/// A person invited to a `CalendarEvent`.
class Attendee extends Equatable {
  const Attendee({required this.name, required this.email});

  /// Deliberately permissive: enough to catch a typo, not so strict that it
  /// rejects an address a mail server would accept.
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final String name;
  final String email;

  /// The reason this person cannot be invited, or null when they can.
  ValidationFailure? validate() {
    if (name.trim().isEmpty) {
      return const ValidationFailure('Please enter a name.');
    }
    if (!_emailPattern.hasMatch(email.trim())) {
      return const ValidationFailure('Please enter a valid email address.');
    }
    return null;
  }

  /// The form this person takes once added: surrounding space removed.
  Attendee normalized() =>
      Attendee(name: name.trim(), email: email.trim());

  @override
  List<Object?> get props => [name, email];
}
