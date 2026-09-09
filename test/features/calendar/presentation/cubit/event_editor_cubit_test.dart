import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/core/presentation/load_status.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/event_editor_cubit.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateEvent createEvent;
  late MockUpdateEvent updateEvent;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    createEvent = MockCreateEvent();
    updateEvent = MockUpdateEvent();
    when(() => createEvent(any())).thenAnswer((_) async => Right(buildEvent()));
    when(() => updateEvent(any())).thenAnswer((_) async => Right(buildEvent()));
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

      expect(cubit.state.draft.start, DateTime(2026, 9, 3, 15));
      expect(cubit.state.draft.end, DateTime(2026, 9, 3, 16));
      expect(cubit.state.isEditing, isFalse);
    });

    test('an existing event is edited in place', () {
      final event = buildEvent(title: 'Retro', location: 'Pokhara');
      final cubit = build(existing: event);

      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.draft, event);
    });
  });

  group('moving the start', () {
    test('drags the end along, preserving the duration', () {
      final cubit = build(initialDate: DateTime(2026, 9, 3, 9));
      cubit.endTimeChanged(13, 0); // a 3-hour event, 10:00-13:00

      cubit.startTimeChanged(11, 0);

      expect(cubit.state.draft.start, DateTime(2026, 9, 3, 11));
      expect(cubit.state.draft.end, DateTime(2026, 9, 3, 14));
    });

    test(
      'recovers a sane duration if the end was dragged before the start',
      () {
        final cubit = build(initialDate: DateTime(2026, 9, 3, 9));
        cubit.endTimeChanged(8, 0); // end now precedes start

        cubit.startTimeChanged(12, 0);

        expect(cubit.state.draft.end, DateTime(2026, 9, 3, 13));
      },
    );
  });

  group('editing an existing event', () {
    // The editor used to rebuild the event field by field, so anything it did
    // not render was erased on save. Now it edits the stored event directly.
    test('preserves fields the form never touches', () async {
      final stored = buildEvent(
        attendees: const [Attendee(name: 'Asha', email: 'asha@haineo.org')],
        timeZoneId: 'Asia/Kathmandu',
        notes: 'Bring the roadmap',
      );
      final cubit = build(existing: stored);

      cubit.titleChanged('Retro');
      await cubit.submit();

      final saved =
          verify(() => updateEvent(captureAny())).captured.single
              as CalendarEvent;
      expect(saved.title, 'Retro');
      expect(saved.attendees, stored.attendees);
      expect(saved.timeZoneId, 'Asia/Kathmandu');
      expect(saved.notes, 'Bring the roadmap');
      expect(saved.id, stored.id);
    });
  });

  group('submit', () {
    blocTest<EventEditorCubit, EventEditorState>(
      'creates a new event and reports saved',
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
        isA<EventEditorState>().having(
          (s) => s.status,
          'status',
          LoadStatus.loading,
        ),
        isA<EventEditorState>()
            .having((s) => s.status, 'status', LoadStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Give the event a title.',
            ),
      ],
    );
  });
}
