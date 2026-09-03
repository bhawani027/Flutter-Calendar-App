import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/calendar_event.dart';

/// The contract the domain layer depends on.
///
/// Declared here, implemented in `data/` — that inversion is what keeps the
/// domain independent of Hive, JSON, or any other storage detail.
abstract interface class EventRepository {
  /// Emits the full event list, and again every time it changes.
  Stream<Either<Failure, List<CalendarEvent>>> watchEvents();

  Future<Either<Failure, List<CalendarEvent>>> getEvents();

  Future<Either<Failure, CalendarEvent>> createEvent(CalendarEvent event);

  Future<Either<Failure, CalendarEvent>> updateEvent(CalendarEvent event);

  Future<Either<Failure, Unit>> deleteEvent(String id);
}
