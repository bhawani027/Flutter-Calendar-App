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

  setUpAll(registerCommonFallbacks);

  setUp(() {
    watchEvents = MockWatchEvents();
    deleteEvent = MockDeleteEvent();
  });

  CalendarCubit build() =>
      CalendarCubit(watchEvents: watchEvents, deleteEvent: deleteEvent);

  final events = [buildEvent()];

  void streamsEvents() => when(() => watchEvents(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<CalendarEvent>>(events)),
      );

  blocTest<CalendarCubit, CalendarState>(
    'start() goes loading then ready with the streamed events',
    setUp: streamsEvents,
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => [
      const CalendarState(status: LoadStatus.loading),
      CalendarState(status: LoadStatus.ready, events: events),
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
      const CalendarState(status: LoadStatus.loading),
      const CalendarState(status: LoadStatus.failure, errorMessage: 'boom'),
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

  blocTest<CalendarCubit, CalendarState>(
    'changeView emits the new view',
    build: build,
    act: (cubit) => cubit.changeView(CalendarViewType.week),
    expect: () => [const CalendarState(view: CalendarViewType.week)],
  );

  blocTest<CalendarCubit, CalendarState>(
    'changeView ignores a no-op selection',
    build: build,
    act: (cubit) => cubit.changeView(CalendarViewType.month),
    expect: () => <CalendarState>[],
  );

  blocTest<CalendarCubit, CalendarState>(
    'deleteEvent emits a failure state when the delete fails',
    setUp: () => when(() => deleteEvent(any()))
        .thenAnswer((_) async => const Left(CacheFailure('locked'))),
    build: build,
    act: (cubit) => cubit.deleteEvent('event-1'),
    expect: () => [
      const CalendarState(status: LoadStatus.failure, errorMessage: 'locked'),
    ],
  );

  blocTest<CalendarCubit, CalendarState>(
    'deleteEvent emits nothing on success — the watch stream refreshes the list',
    setUp: () => when(() => deleteEvent(any()))
        .thenAnswer((_) async => const Right(unit)),
    build: build,
    act: (cubit) => cubit.deleteEvent('event-1'),
    expect: () => <CalendarState>[],
  );
}
