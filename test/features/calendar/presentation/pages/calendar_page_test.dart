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
        Right<Failure, List<CalendarEvent>>([buildEvent(title: 'Standup')]),
      ),
    );
  });

  Widget subject() => BlocProvider(
        create: (_) =>
            CalendarCubit(watchEvents: watchEvents, deleteEvent: deleteEvent),
        child: const CalendarPage(),
      );

  testWidgets('opens on the month view', (tester) async {
    await tester.pumpPage(subject());

    expect(find.text('Month view'), findsOneWidget);
    expect(find.byType(SfCalendar), findsOneWidget);
  });

  testWidgets('feeds the streamed events to the calendar', (tester) async {
    await tester.pumpPage(subject());

    final calendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    expect(calendar.dataSource!.appointments, hasLength(1));
    final appointment = calendar.dataSource!.appointments!.single as Appointment;
    expect(appointment.subject, 'Standup');
  });

  testWidgets('shows a spinner until the first result arrives',
      (tester) async {
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

  group('the view drawer', () {
    testWidgets('offers all four views', (tester) async {
      await tester.pumpPage(subject());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      for (final label in ['Schedule', 'Day', 'Week', 'Month']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('switching view keeps the same events on screen',
        (tester) async {
      await tester.pumpPage(subject());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      expect(find.text('Week view'), findsOneWidget);
      final calendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
      expect(calendar.controller!.view, CalendarView.week);
      // The old app pushed a fresh screen per view, each with its own list.
      expect(calendar.dataSource!.appointments, hasLength(1));
    });

    testWidgets('the adapter is reused while the events do not change',
        (tester) async {
      await tester.pumpPage(subject());
      final before =
          tester.widget<SfCalendar>(find.byType(SfCalendar)).dataSource;

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();

      final after =
          tester.widget<SfCalendar>(find.byType(SfCalendar)).dataSource;
      expect(identical(before, after), isTrue);
    });
  });
}
