import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/core/presentation/load_status.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/calendar_cubit.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchEvents watchEvents;
  late MockDeleteEvent deleteEvent;

  /// A fixed "now" so date-relative assertions do not drift.
  final today = DateTime(2026, 9, 3, 10);

  setUpAll(registerCommonFallbacks);

  setUp(() {
    watchEvents = MockWatchEvents();
    deleteEvent = MockDeleteEvent();
  });

  CalendarCubit build() => CalendarCubit(
    watchEvents: watchEvents,
    deleteEvent: deleteEvent,
    today: today,
  );

  final events = [buildEvent()];
  CalendarState base({
    LoadStatus status = LoadStatus.initial,
    List<CalendarEvent> events = const [],
    CalendarViewType view = CalendarViewType.month,
    DateTime? focusedDate,
    DateTime? selectedDate,
    String? errorMessage,
  }) => CalendarState(
    status: status,
    events: events,
    view: view,
    focusedDate: focusedDate ?? today,
    selectedDate: selectedDate,
    errorMessage: errorMessage,
  );

  void streamsEvents() => when(() => watchEvents(any())).thenAnswer(
    (_) => Stream.value(Right<Failure, List<CalendarEvent>>(events)),
  );

  blocTest<CalendarCubit, CalendarState>(
    'start() goes loading then ready with the streamed events',
    setUp: streamsEvents,
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => [
      base(status: LoadStatus.loading),
      base(status: LoadStatus.ready, events: events),
    ],
  );

  blocTest<CalendarCubit, CalendarState>(
    'start() surfaces a stream failure as an error message',
    setUp: () => when(() => watchEvents(any())).thenAnswer(
      (_) => Stream.value(
        const Left<Failure, List<CalendarEvent>>(CacheFailure('boom')),
      ),
    ),
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => [
      base(status: LoadStatus.loading),
      base(status: LoadStatus.failure, errorMessage: 'boom'),
    ],
  );

  blocTest<CalendarCubit, CalendarState>(
    'start() is idempotent — a second call does not resubscribe',
    setUp: streamsEvents,
    build: build,
    act: (cubit) async {
      await cubit.start();
      await cubit.start();
    },
    verify: (_) => verify(() => watchEvents(any())).called(1),
  );

  group('view', () {
    blocTest<CalendarCubit, CalendarState>(
      'changeView emits the new view',
      build: build,
      act: (cubit) => cubit.changeView(CalendarViewType.week),
      expect: () => [base(view: CalendarViewType.week)],
    );

    blocTest<CalendarCubit, CalendarState>(
      'changeView ignores a no-op selection',
      build: build,
      act: (cubit) => cubit.changeView(CalendarViewType.month),
      expect: () => <CalendarState>[],
    );
  });

  group('visibleRangeChanged', () {
    // The calendar pads a month with leading and trailing days, so the middle
    // of the range is what identifies the month actually on screen.
    blocTest<CalendarCubit, CalendarState>(
      'focuses the middle of the reported range',
      build: build,
      act: (cubit) => cubit.visibleRangeChanged([
        DateTime(2026, 9, 27),
        DateTime(2026, 10, 15),
        DateTime(2026, 11, 7),
      ]),
      expect: () => [base(focusedDate: DateTime(2026, 10, 15))],
    );

    blocTest<CalendarCubit, CalendarState>(
      'ignores an empty range',
      build: build,
      act: (cubit) => cubit.visibleRangeChanged([]),
      expect: () => <CalendarState>[],
    );

    blocTest<CalendarCubit, CalendarState>(
      'ignores a range still on the focused day',
      build: build,
      act: (cubit) => cubit.visibleRangeChanged([DateTime(2026, 9, 3, 23)]),
      expect: () => <CalendarState>[],
    );
  });

  group('selectDate', () {
    blocTest<CalendarCubit, CalendarState>(
      'selects and focuses the date',
      build: build,
      act: (cubit) => cubit.selectDate(DateTime(2026, 9, 20)),
      expect: () => [
        base(
          focusedDate: DateTime(2026, 9, 20),
          selectedDate: DateTime(2026, 9, 20),
        ),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'clearSelection drops it again',
      build: build,
      act: (cubit) {
        cubit.selectDate(DateTime(2026, 9, 20));
        cubit.clearSelection();
      },
      verify: (cubit) => expect(cubit.state.selectedDate, isNull),
    );
  });

  group('showsToday', () {
    test('day view: only when focused on today', () {
      expect(base(view: CalendarViewType.day).showsToday(now: today), isTrue);
      expect(
        base(
          view: CalendarViewType.day,
          focusedDate: DateTime(2026, 9, 4),
        ).showsToday(now: today),
        isFalse,
      );
    });

    test('week view: anywhere in the same week', () {
      // 2026-09-03 is a Thursday; its week runs Sun 30 Aug – Sat 5 Sep.
      expect(
        base(
          view: CalendarViewType.week,
          focusedDate: DateTime(2026, 8, 30),
        ).showsToday(now: today),
        isTrue,
      );
      expect(
        base(
          view: CalendarViewType.week,
          focusedDate: DateTime(2026, 9, 6),
        ).showsToday(now: today),
        isFalse,
      );
    });

    test('month and schedule views: anywhere in the same month', () {
      expect(
        base(
          view: CalendarViewType.month,
          focusedDate: DateTime(2026, 9, 28),
        ).showsToday(now: today),
        isTrue,
      );
      expect(
        base(
          view: CalendarViewType.schedule,
          focusedDate: DateTime(2026, 10, 1),
        ).showsToday(now: today),
        isFalse,
      );
    });
  });

  group('deleteEvent', () {
    blocTest<CalendarCubit, CalendarState>(
      'emits a failure state when the delete fails',
      setUp: () => when(
        () => deleteEvent(any()),
      ).thenAnswer((_) async => const Left(CacheFailure('locked'))),
      build: build,
      act: (cubit) => cubit.deleteEvent('event-1'),
      expect: () => [base(status: LoadStatus.failure, errorMessage: 'locked')],
    );

    blocTest<CalendarCubit, CalendarState>(
      'emits nothing on success — the watch stream refreshes the list',
      setUp: () => when(
        () => deleteEvent(any()),
      ).thenAnswer((_) async => const Right(unit)),
      build: build,
      act: (cubit) => cubit.deleteEvent('event-1'),
      expect: () => <CalendarState>[],
    );
  });
}
