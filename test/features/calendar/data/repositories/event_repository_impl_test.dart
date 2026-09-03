import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/exceptions.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/data/datasources/event_local_data_source.dart';
import 'package:mycalendar_app/features/calendar/data/models/calendar_event_model.dart';
import 'package:mycalendar_app/features/calendar/data/repositories/event_repository_impl.dart';

import '../../../../helpers/fixtures.dart';

class MockEventLocalDataSource extends Mock implements EventLocalDataSource {}

void main() {
  late MockEventLocalDataSource dataSource;
  late EventRepositoryImpl repository;

  setUpAll(
    () => registerFallbackValue(CalendarEventModel.fromEntity(buildEvent())),
  );

  setUp(() {
    dataSource = MockEventLocalDataSource();
    repository = EventRepositoryImpl(dataSource);
  });

  group('getEvents', () {
    test('returns entities sorted by start time', () async {
      when(dataSource.readAll).thenAnswer(
        (_) async => [
          CalendarEventModel.fromEntity(
            buildEvent(id: 'late', start: DateTime(2026, 9, 3, 15)),
          ),
          CalendarEventModel.fromEntity(
            buildEvent(id: 'early', start: DateTime(2026, 9, 3, 9)),
          ),
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
      verify(() => dataSource.write(any())).called(1);
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
  });

  group('watchEvents', () {
    test('emits the current list, then again on every change', () async {
      final changes = Stream<void>.fromIterable([null, null]);
      when(() => dataSource.changes()).thenAnswer((_) => changes);
      when(dataSource.readAll).thenAnswer(
        (_) async => [CalendarEventModel.fromEntity(buildEvent())],
      );

      final emissions = await repository.watchEvents().toList();

      // One initial emission plus one per change.
      expect(emissions, hasLength(3));
      expect(
        emissions.every((either) => either.isRight()),
        isTrue,
      );
    });
  });
}
