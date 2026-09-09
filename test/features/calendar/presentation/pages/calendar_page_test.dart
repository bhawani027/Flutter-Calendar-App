import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mycalendar_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_page.dart';

void main() {
  configureWidgetTests();

  late MockWatchEvents watchEvents;
  late MockDeleteEvent deleteEvent;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    watchEvents = MockWatchEvents();
    deleteEvent = MockDeleteEvent();
    when(() => watchEvents(any())).thenAnswer(
      (_) => Stream.value(
        Right<Failure, List<CalendarEvent>>([
          buildEvent(title: 'Standup', start: DateTime.now()),
        ]),
      ),
    );
  });

  Widget subject() => BlocProvider(
    create: (_) =>
        CalendarCubit(watchEvents: watchEvents, deleteEvent: deleteEvent),
    child: const CalendarPage(),
  );

  Future<void> chooseView(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Change view'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  SfCalendar calendarOf(WidgetTester tester) =>
      tester.widget<SfCalendar>(find.byType(SfCalendar));

  testWidgets('opens on the month view, headed by the current month', (
    tester,
  ) async {
    await tester.pumpPage(subject());

    expect(find.byType(SfCalendar), findsOneWidget);
    expect(calendarOf(tester).controller!.view, CalendarView.month);
  });

  testWidgets('feeds the streamed events to the calendar', (tester) async {
    await tester.pumpPage(subject());

    final source = calendarOf(tester).dataSource!;
    expect(source.appointments, hasLength(1));
    expect((source.appointments!.single as Appointment).subject, 'Standup');
  });

  testWidgets('shows a spinner until the first result arrives', (tester) async {
    when(() => watchEvents(any())).thenAnswer(
      (_) => const Stream<Either<Failure, List<CalendarEvent>>>.empty(),
    );

    await tester.pumpPage(subject(), settle: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SfCalendar), findsNothing);
  });

  testWidgets('a stream failure is shown to the user', (tester) async {
    when(() => watchEvents(any())).thenAnswer(
      (_) => Stream.value(
        const Left<Failure, List<CalendarEvent>>(CacheFailure('disk gone')),
      ),
    );

    await tester.pumpPage(subject());

    expect(find.text('disk gone'), findsOneWidget);
  });

  group('the live time indicator', () {
    testWidgets('is enabled so "now" is visible in the time views', (
      tester,
    ) async {
      await tester.pumpPage(subject());
      await chooseView(tester, 'Day');

      expect(calendarOf(tester).showCurrentTimeIndicator, isTrue);
    });
  });

  group('the view switcher', () {
    testWidgets('offers all four views', (tester) async {
      await tester.pumpPage(subject());

      await tester.tap(find.byTooltip('Change view'));
      await tester.pumpAndSettle();

      for (final label in ['Day', 'Week', 'Month', 'Schedule']) {
        expect(find.text(label), findsWidgets, reason: 'missing $label');
      }
    });

    testWidgets('switching to week keeps the same events on screen', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      await chooseView(tester, 'Week');

      final calendar = calendarOf(tester);
      expect(calendar.controller!.view, CalendarView.week);
      // The old app pushed a fresh screen per view, each with its own list.
      expect(calendar.dataSource!.appointments, hasLength(1));
    });

    testWidgets('reaches the day and schedule views too', (tester) async {
      await tester.pumpPage(subject());

      await chooseView(tester, 'Day');
      expect(calendarOf(tester).controller!.view, CalendarView.day);

      await chooseView(tester, 'Schedule');
      expect(calendarOf(tester).controller!.view, CalendarView.schedule);
    });

    testWidgets('the adapter is reused while the events do not change', (
      tester,
    ) async {
      await tester.pumpPage(subject());
      final before = calendarOf(tester).dataSource;

      await chooseView(tester, 'Day');

      expect(identical(before, calendarOf(tester).dataSource), isTrue);
    });
  });

  group('returning to today', () {
    testWidgets('the Today button is hidden while today is already in view', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      expect(find.byTooltip('Go to today'), findsNothing);
    });

    testWidgets('it appears once the user navigates away, and goes back', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      final away = DateTime.now().add(const Duration(days: 90));
      tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>()
          .selectDate(away);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Go to today'), findsOneWidget);

      await tester.tap(find.byTooltip('Go to today'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Go to today'), findsNothing);
    });
  });
}
