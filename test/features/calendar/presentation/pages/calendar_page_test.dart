import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mycalendar_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mycalendar_app/features/calendar/presentation/widgets/calendar_period_label.dart';
import 'package:mycalendar_app/features/calendar/presentation/widgets/dual_date_strip.dart';
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

  group('the two calendars', () {
    // The calendar widget also renders the month name inside the grid, so the
    // header assertions look only at the app bar.
    Finder inAppBar(String text) =>
        find.descendant(of: find.byType(AppBar), matching: find.text(text));

    testWidgets('the header carries the BS period over the AD one', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      final now = DateTime.now();
      final bsLabel = CalendarPeriodLabel.bs(CalendarViewType.month, now);
      final adLabel = CalendarPeriodLabel.of(CalendarViewType.month, now);

      expect(inAppBar(bsLabel!), findsOneWidget);
      expect(inAppBar(adLabel), findsOneWidget);
    });

    testWidgets('both header lines move together between months', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      final cubit = tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>();
      final next = DateTime(2026, 12, 15);
      cubit.selectDate(next);
      await tester.pumpAndSettle();

      // Both readings are derived from the one focused date, so the BS header
      // has to follow the AD one rather than lag a month behind.
      expect(
        inAppBar(CalendarPeriodLabel.bs(CalendarViewType.month, next)!),
        findsOneWidget,
      );
      expect(
        inAppBar(CalendarPeriodLabel.of(CalendarViewType.month, next)),
        findsOneWidget,
      );
    });

    testWidgets('no strip is shown until a day is picked', (tester) async {
      await tester.pumpPage(subject());

      expect(find.byType(DualDateStrip), findsNothing);
    });

    testWidgets('picking a day names it in both calendars', (tester) async {
      await tester.pumpPage(subject());

      tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>()
          .selectDate(DateTime(2026, 9, 9));
      await tester.pumpAndSettle();

      expect(find.byType(DualDateStrip), findsOneWidget);
      expect(find.text('भाद्र २४, २०८३'), findsOneWidget);
      expect(find.text('September 9, 2026'), findsOneWidget);
    });

    testWidgets('the strip follows the selection', (tester) async {
      await tester.pumpPage(subject());

      final cubit = tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>();

      cubit.selectDate(DateTime(2026, 9, 9));
      await tester.pumpAndSettle();
      expect(find.text('भाद्र २४, २०८३'), findsOneWidget);

      cubit.selectDate(DateTime(2026, 10, 3));
      await tester.pumpAndSettle();
      expect(find.text('भाद्र २४, २०८३'), findsNothing);
      expect(find.text('आश्विन १७, २०८३'), findsOneWidget);
      expect(find.text('October 3, 2026'), findsOneWidget);
    });

    testWidgets('the events still reach the calendar with the strip up', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>()
          .selectDate(DateTime(2026, 9, 9));
      await tester.pumpAndSettle();

      final source = calendarOf(tester).dataSource!;
      expect(source.appointments, hasLength(1));
      expect((source.appointments!.single as Appointment).subject, 'Standup');
    });

    testWidgets('Today returns to the real date in both calendars', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      final cubit = tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>();
      cubit.selectDate(DateTime(2026, 12, 15));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Go to today'));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      expect(
        inAppBar(CalendarPeriodLabel.bs(CalendarViewType.month, today)!),
        findsOneWidget,
      );
      expect(find.byType(DualDateStrip), findsOneWidget);
    });

    testWidgets('Today moves the calendar\'s own selection with it', (
      tester,
    ) async {
      await tester.pumpPage(subject());

      // Pick a day well away from today, then come back.
      tester
          .element(find.byType(SfCalendar))
          .read<CalendarCubit>()
          .selectDate(DateTime(2026, 12, 15));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Go to today'));
      await tester.pumpAndSettle();

      // Otherwise the outline stays on 15 December while the header and strip
      // read today, and a view switch opens on December.
      final controller = calendarOf(tester).controller!;
      final today = DateTime.now();
      expect(controller.selectedDate!.year, today.year);
      expect(controller.selectedDate!.month, today.month);
      expect(controller.selectedDate!.day, today.day);
    });
  });
}
