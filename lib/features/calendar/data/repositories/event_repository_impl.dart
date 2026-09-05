import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_data_source.dart';

/// Translates data-source exceptions into domain [Failure]s.
class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl(this._localDataSource);

  final EventLocalDataSource _localDataSource;

  @override
  Stream<Either<Failure, List<CalendarEvent>>> watchEvents() async* {
    yield await getEvents();
    await for (final _ in _localDataSource.changes()) {
      yield await getEvents();
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents() async {
    try {
      final events = await _localDataSource.readAll()
        ..sort((a, b) => a.start.compareTo(b.start));
      return Right(events);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> createEvent(
    CalendarEvent event,
  ) async {
    return _save(event);
  }

  @override
  Future<Either<Failure, CalendarEvent>> updateEvent(
    CalendarEvent event,
  ) async {
    return _save(event);
  }

  @override
  Future<Either<Failure, Unit>> deleteEvent(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(unit);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  Future<Either<Failure, CalendarEvent>> _save(CalendarEvent event) async {
    try {
      await _localDataSource.write(event);
      return Right(event);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }
}
