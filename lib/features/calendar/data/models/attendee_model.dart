import '../../domain/entities/attendee.dart';

/// Serialisable form of [Attendee].
class AttendeeModel extends Attendee {
  const AttendeeModel({required super.name, required super.email});

  factory AttendeeModel.fromEntity(Attendee attendee) =>
      AttendeeModel(name: attendee.name, email: attendee.email);

  factory AttendeeModel.fromJson(Map<String, dynamic> json) => AttendeeModel(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}
