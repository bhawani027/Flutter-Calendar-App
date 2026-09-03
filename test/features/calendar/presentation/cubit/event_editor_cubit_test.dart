import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/create_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/update_event.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/event_editor_cubit.dart';

import '../../../../helpers/fixtures.dart';

class MockCreateEvent extends Mock implements CreateEvent {}

class MockUpdateEvent extends Mock implements UpdateEvent {}

void main() {
  late MockCreateEvent createEvent;
  late MockUpdateEvent updateEvent;

  setUpAll(() {
    registerFallbackValue(
      CreateEventParams(
        title: 'x',
        start: DateTime(2026),
        end: DateTime(2026, 1, 1, 1),
      ),
    );
    registerFallbackValue(buildEvent());
  });

  setUp(() {
    createEvent = MockCreateEvent();
    updateEvent = MockUpdateEvent();
  });

  EventEditorCubit build({CalendarEvent? existing, DateTime? initialDate}) =>
      EventEditorCubit(
        createEvent: createEvent,
        updateEvent: updateEvent,
        existing: existing,
        initialDate: initialDate,
      );

  group('initial state', () {
    test('a blank form starts at the next full hour, lasting one hour', () {
      final cubit = build(initialDate: DateTime(2026, 9, 3, 14, 37));

      expect(cubit.state.start, DateTime(2026, 9, 3, 15));
      expect(cubit.state.end, DateTime(2026, 9, 3, 16));
      expect(cubit.state.isEditing, isFalse);
    });

    test('an existing event pre-fills every field', () {
      final event = buildEvent(title: 'Retro', location: 'Pokhara');
      final cubit = build(existing: event);

      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.title, 'Retro');
      expect(cubit.state.location, 'Pokhara');
    });
  });

  group('moving the start', () {
    test('drags the end along, preserving the duration', () {
      final cubit = build(initialDate: DateTime(2026, 9, 3, 9));
      cubit.endTimeChanged(13, 0); // a 3-hour event, 10:00-13:00

      cubit.startTimeChanged(11, 0);

      expect(cubit.state.start, DateTime(2026, 9, 3, 11));
      expect(cubit.state.end, DateTime(2026, 9, 3, 14));
    });

    test('recovers a sane duration if the end was dragged before the start',
        () {
      final cubit = build(initialDate: DateTime(2026, 9, 3, 9));
      cubit.endTimeChanged(8, 0); // end now precedes start

      cubit.startTimeChanged(12, 0);

      expect(cubit.state.end, DateTime(2026, 9, 3, 13));
    });
  });

  group('submit', () {
    blocTest<EventEditorCubit, EventEditorState>(
      'creates a new event and reports saved',
      setUp: () => when(() => createEvent(any()))
          .thenAnswer((_) async => Right(buildEvent())),
      build: () => build(initialDate: DateTime(2026, 9, 3, 9)),
      act: (cubit) async {
        cubit.titleChanged('Standup');
        expect(await cubit.submit(), isTrue);
      },
      verify: (_) {
        verify(() => createEvent(any())).called(1);
        verifyNever(() => updateEvent(any()));
      },
    );

    blocTest<EventEditorCubit, EventEditorState>(
      'updates instead of creating when editing an existing event',
      setUp: () => when(() => updateEvent(any()))
          .thenAnswer((_) async => Right(buildEvent())),
      build: () => build(existing: buildEvent()),
      act: (cubit) async => cubit.submit(),
      verify: (_) {
        verify(() => updateEvent(any())).called(1);
        verifyNever(() => createEvent(any()));
      },
    );

    blocTest<EventEditorCubit, EventEditorState>(
      'surfaces a validation failure and stays on the form',
      setUp: () => when(() => createEvent(any())).thenAnswer(
        (_) async => const Left(ValidationFailure('Give the event a title.')),
      ),
      build: () => build(initialDate: DateTime(2026, 9, 3, 9)),
      act: (cubit) async => expect(await cubit.submit(), isFalse),
      expect: () => [
        isA<EventEditorState>()
            .having((s) => s.status, 'status', EventEditorStatus.saving),
        isA<EventEditorState>()
            .having((s) => s.status, 'status', EventEditorStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Give the event a title.',
            ),
      ],
    );

    test('an all-day event is widened to cover the whole day', () async {
      when(() => createEvent(any()))
          .thenAnswer((_) async => Right(buildEvent()));

      final cubit = build(initialDate: DateTime(2026, 9, 3, 9));
      cubit.titleChanged('Holiday');
      cubit.allDayToggled(true);
      await cubit.submit();

      final params =
          verify(() => createEvent(captureAny())).captured.single
              as CreateEventParams;
      expect(params.start, DateTime(2026, 9, 3));
      expect(params.end.hour, 23);
      expect(params.end.minute, 59);
    });
  });
}
