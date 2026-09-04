import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/calendar_event.dart';
import '../repositories/event_repository.dart';

/// Validates a draft event, mints an id, and persists it.
///
/// Takes a draft [CalendarEvent] rather than a parallel params class, so there
/// is only one description of what an event is. Whatever `id` the draft
/// carries is ignored.
class CreateEvent implements UseCase<CalendarEvent, CalendarEvent> {
  const CreateEvent(this._repository, this._idGenerator);

  final EventRepository _repository;
  final IdGenerator _idGenerator;

  @override
  Future<Either<Failure, CalendarEvent>> call(CalendarEvent params) async {
    final failure = params.validate();
    if (failure != null) return Left(failure);

    return _repository.createEvent(
      params.normalized().copyWith(id: _idGenerator.newId()),
    );
  }
}
