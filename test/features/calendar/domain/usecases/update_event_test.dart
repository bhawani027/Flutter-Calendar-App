import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/update_event.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockEventRepository repository;
  late UpdateEvent useCase;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    repository = MockEventRepository();
    useCase = UpdateEvent(repository);
    when(() => repository.updateEvent(any())).thenAnswer(
      (invocation) async =>
          Right(invocation.positionalArguments.first as CalendarEvent),
    );
  });

  // Update used to skip the trimming Create applied, so the same title was
  // stored differently depending on which path you took.
  test('normalises the title exactly like CreateEvent does', () async {
    final result = await useCase(buildEvent(title: '  Retro  '));

    expect(result.getRight().toNullable()!.title, 'Retro');
  });

  test('widens an all-day event to cover its whole day', () async {
    final result = await useCase(buildEvent(isAllDay: true));

    final event = result.getRight().toNullable()!;
    expect(event.start, DateTime(2026, 9, 3));
    expect(event.end.hour, 23);
  });

  test('keeps the existing id', () async {
    final result = await useCase(buildEvent(id: 'event-7'));

    expect(result.getRight().toNullable()!.id, 'event-7');
  });

  test('applies the same validation rules', () async {
    final blank = await useCase(buildEvent(title: '  '));
    final inverted =
        await useCase(buildEvent(end: DateTime(2026, 9, 3, 8)));

    expect(blank.getLeft().toNullable(), isA<ValidationFailure>());
    expect(inverted.getLeft().toNullable(), isA<ValidationFailure>());
    verifyNever(() => repository.updateEvent(any()));
  });
}
