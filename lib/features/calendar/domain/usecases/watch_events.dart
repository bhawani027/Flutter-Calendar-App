import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/calendar_event.dart';
import '../repositories/event_repository.dart';

/// Streams every event, re-emitting whenever the store changes.
class WatchEvents implements StreamUseCase<List<CalendarEvent>, NoParams> {
  const WatchEvents(this._repository);

  final EventRepository _repository;

  @override
  Stream<Either<Failure, List<CalendarEvent>>> call(NoParams params) =>
      _repository.watchEvents();
}
