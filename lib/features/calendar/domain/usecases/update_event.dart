import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/calendar_event.dart';
import '../repositories/event_repository.dart';

class UpdateEvent implements UseCase<CalendarEvent, CalendarEvent> {
  const UpdateEvent(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, CalendarEvent>> call(CalendarEvent params) async {
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('Give the event a title.'));
    }
    if (!params.end.isAfter(params.start)) {
      return const Left(
        ValidationFailure('The event must end after it starts.'),
      );
    }
    return _repository.updateEvent(params);
  }
}
