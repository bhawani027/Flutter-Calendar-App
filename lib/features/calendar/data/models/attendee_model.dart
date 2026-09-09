import '../../domain/entities/attendee.dart';

/// JSON mapping for [Attendee].
///
/// A pure mapper rather than a subclass — a subclass would not compare equal
/// to the entity it mirrors, since Equatable includes the runtime type.
abstract final class AttendeeModel {
  static Attendee fromJson(Map<String, dynamic> json) => Attendee(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );

  static Map<String, dynamic> toJson(Attendee attendee) => {
    'name': attendee.name,
    'email': attendee.email,
  };
}
