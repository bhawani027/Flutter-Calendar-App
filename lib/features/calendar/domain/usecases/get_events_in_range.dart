import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/calendar_event.dart';
import '../repositories/event_repository.dart';

class DateRange extends Equatable {
  const DateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [from, to];
}

/// Returns the events overlapping `[from, to)`, earliest first.
class GetEventsInRange implements UseCase<List<CalendarEvent>, DateRange> {
  const GetEventsInRange(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, List<CalendarEvent>>> call(DateRange params) async {
    final result = await _repository.getEvents();
    return result.map((events) {
      final matching = events
          .where((event) => event.overlaps(params.from, params.to))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      return matching;
    });
  }
}
