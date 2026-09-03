import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/domain/repositories/event_repository.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/create_event.dart';

import '../../../../helpers/fixtures.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late MockEventRepository repository;
  late CreateEvent useCase;

  setUpAll(() => registerFallbackValue(buildEvent()));

  setUp(() {
    repository = MockEventRepository();
    useCase = CreateEvent(repository, const FixedIdGenerator('generated-id'));
    when(() => repository.createEvent(any())).thenAnswer(
      (invocation) async =>
          Right(invocation.positionalArguments.first as CalendarEvent),
    );
  });

  final start = DateTime(2026, 9, 3, 9);

  test('persists the event with a generated id and trimmed title', () async {
    final result = await useCase(
      CreateEventParams(
        title: '  Standup  ',
        start: start,
        end: start.add(const Duration(hours: 1)),
      ),
    );

    final event = result.getRight().toNullable()!;
    expect(event.id, 'generated-id');
    expect(event.title, 'Standup');
    verify(() => repository.createEvent(any())).called(1);
  });

  test('rejects a blank title without touching the repository', () async {
    final result = await useCase(
      CreateEventParams(
        title: '   ',
        start: start,
        end: start.add(const Duration(hours: 1)),
      ),
    );

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    verifyNever(() => repository.createEvent(any()));
  });

  test('rejects an end that is not after the start', () async {
    final result = await useCase(
      CreateEventParams(title: 'Standup', start: start, end: start),
    );

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    verifyNever(() => repository.createEvent(any()));
  });

  test('passes a repository failure straight through', () async {
    when(() => repository.createEvent(any()))
        .thenAnswer((_) async => const Left(CacheFailure('disk full')));

    final result = await useCase(
      CreateEventParams(
        title: 'Standup',
        start: start,
        end: start.add(const Duration(hours: 1)),
      ),
    );

    expect(result.getLeft().toNullable(), const CacheFailure('disk full'));
  });
}
