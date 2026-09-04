import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/calendar_event.dart';
import '../repositories/event_repository.dart';

/// Validates an edited event and persists it over the stored one.
class UpdateEvent implements UseCase<CalendarEvent, CalendarEvent> {
  const UpdateEvent(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, CalendarEvent>> call(CalendarEvent params) async {
    final failure = params.validate();
    if (failure != null) return Left(failure);

    return _repository.updateEvent(params.normalized());
  }
}
