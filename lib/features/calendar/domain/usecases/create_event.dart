import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/attendee.dart';
import '../entities/calendar_event.dart';
import '../entities/recurrence_rule.dart';
import '../repositories/event_repository.dart';

class CreateEventParams extends Equatable {
  const CreateEventParams({
    required this.title,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.colorValue = CalendarEvent.defaultColorValue,
    this.attendees = const [],
    this.recurrence = RecurrenceRule.never,
    this.location,
    this.notes,
    this.timeZoneId,
    this.reminderBefore,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final int colorValue;
  final List<Attendee> attendees;
  final RecurrenceRule recurrence;
  final String? location;
  final String? notes;
  final String? timeZoneId;
  final Duration? reminderBefore;

  @override
  List<Object?> get props => [
        title,
        start,
        end,
        isAllDay,
        colorValue,
        attendees,
        recurrence,
        location,
        notes,
        timeZoneId,
        reminderBefore,
      ];
}

/// Validates the input, mints an id, and persists the event.
///
/// The two rules the old UI never enforced live here: a title is required and
/// an event may not end before it starts.
class CreateEvent implements UseCase<CalendarEvent, CreateEventParams> {
  const CreateEvent(this._repository, this._idGenerator);

  final EventRepository _repository;
  final IdGenerator _idGenerator;

  @override
  Future<Either<Failure, CalendarEvent>> call(CreateEventParams params) async {
    final title = params.title.trim();
    if (title.isEmpty) {
      return const Left(ValidationFailure('Give the event a title.'));
    }
    if (!params.end.isAfter(params.start)) {
      return const Left(
        ValidationFailure('The event must end after it starts.'),
      );
    }

    final event = CalendarEvent(
      id: _idGenerator.newId(),
      title: title,
      start: params.start,
      end: params.end,
      isAllDay: params.isAllDay,
      colorValue: params.colorValue,
      attendees: params.attendees,
      recurrence: params.recurrence,
      location: params.location,
      notes: params.notes,
      timeZoneId: params.timeZoneId,
      reminderBefore: params.reminderBefore,
    );

    return _repository.createEvent(event);
  }
}
