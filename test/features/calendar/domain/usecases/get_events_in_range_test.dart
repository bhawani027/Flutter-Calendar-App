import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/repositories/event_repository.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/get_events_in_range.dart';

import '../../../../helpers/fixtures.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late MockEventRepository repository;
  late GetEventsInRange useCase;

  setUp(() {
    repository = MockEventRepository();
    useCase = GetEventsInRange(repository);
  });

  final inRangeLate = buildEvent(id: 'b', start: DateTime(2026, 9, 3, 15));
  final inRangeEarly = buildEvent(id: 'a', start: DateTime(2026, 9, 3, 9));
  final outOfRange = buildEvent(id: 'c', start: DateTime(2026, 9, 10, 9));

  test('returns only overlapping events, earliest first', () async {
    when(repository.getEvents).thenAnswer(
      (_) async => Right([inRangeLate, outOfRange, inRangeEarly]),
    );

    final result = await useCase(
      DateRange(from: DateTime(2026, 9, 3), to: DateTime(2026, 9, 4)),
    );

    expect(
      result.getRight().toNullable()!.map((event) => event.id),
      ['a', 'b'],
    );
  });

  test('propagates a repository failure', () async {
    when(repository.getEvents)
        .thenAnswer((_) async => const Left(CacheFailure()));

    final result = await useCase(
      DateRange(from: DateTime(2026, 9, 3), to: DateTime(2026, 9, 4)),
    );

    expect(result.getLeft().toNullable(), isA<CacheFailure>());
  });
}
