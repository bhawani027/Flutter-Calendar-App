import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/exceptions.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/data/repositories/event_repository_impl.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockEventLocalDataSource dataSource;
  late EventRepositoryImpl repository;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    dataSource = MockEventLocalDataSource();
    repository = EventRepositoryImpl(dataSource);
  });

  group('getEvents', () {
    test('returns events sorted by start time', () async {
      when(dataSource.readAll).thenAnswer(
        (_) async => [
          buildEvent(id: 'late', start: DateTime(2026, 9, 3, 15)),
          buildEvent(id: 'early', start: DateTime(2026, 9, 3, 9)),
        ],
      );

      final result = await repository.getEvents();

      expect(
        result.getRight().toNullable()!.map((event) => event.id),
        ['early', 'late'],
      );
    });

    test('turns a CacheException into a CacheFailure', () async {
      when(dataSource.readAll).thenThrow(const CacheException('corrupt box'));

      final result = await repository.getEvents();

      expect(result.getLeft().toNullable(), const CacheFailure('corrupt box'));
    });
  });

  group('createEvent', () {
    test('writes the event and echoes it back', () async {
      when(() => dataSource.write(any())).thenAnswer((_) async {});

      final event = buildEvent();
      final result = await repository.createEvent(event);

      expect(result.getRight().toNullable(), event);
      verify(() => dataSource.write(event)).called(1);
    });

    test('turns a write failure into a CacheFailure', () async {
      when(() => dataSource.write(any()))
          .thenThrow(const CacheException('read-only'));

      final result = await repository.createEvent(buildEvent());

      expect(result.getLeft().toNullable(), isA<CacheFailure>());
    });
  });

  group('deleteEvent', () {
    test('delegates to the data source', () async {
      when(() => dataSource.delete(any())).thenAnswer((_) async {});

      final result = await repository.deleteEvent('event-1');

      expect(result.isRight(), isTrue);
      verify(() => dataSource.delete('event-1')).called(1);
    });

    test('turns a delete failure into a CacheFailure', () async {
      when(() => dataSource.delete(any()))
          .thenThrow(const CacheException('locked'));

      final result = await repository.deleteEvent('event-1');

      expect(result.getLeft().toNullable(), isA<CacheFailure>());
    });
  });

  group('watchEvents', () {
    test('emits the current list, then again on every change', () async {
      when(() => dataSource.changes())
          .thenAnswer((_) => Stream<void>.fromIterable([null, null]));
      when(dataSource.readAll).thenAnswer((_) async => [buildEvent()]);

      final emissions = await repository.watchEvents().toList();

      // One initial emission plus one per change.
      expect(emissions, hasLength(3));
      expect(emissions.every((either) => either.isRight()), isTrue);
    });
  });
}
