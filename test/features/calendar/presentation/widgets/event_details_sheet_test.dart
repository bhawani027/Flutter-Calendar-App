import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/recurrence_rule.dart';
import 'package:mycalendar_app/features/calendar/presentation/widgets/event_details_sheet.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_page.dart';

void main() {
  configureWidgetTests();

  Future<EventDetailsAction?> open(
    WidgetTester tester,
    CalendarEvent event,
  ) async {
    EventDetailsAction? result;
    await tester.pumpPage(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showEventDetailsSheet(context, event: event);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('shows the event and its timing', (tester) async {
    await open(
      tester,
      buildEvent(
        title: 'Architecture review',
        start: DateTime(2026, 9, 3, 14),
        end: DateTime(2026, 9, 3, 15),
      ),
    );

    expect(find.text('Architecture review'), findsOneWidget);
    expect(find.textContaining('Thursday, 3 September 2026'), findsOneWidget);
  });

  testWidgets('labels an all-day event rather than showing times', (
    tester,
  ) async {
    await open(tester, buildEvent(isAllDay: true));

    expect(find.textContaining('All day'), findsOneWidget);
  });

  testWidgets('shows only the details the event actually has', (tester) async {
    await open(tester, buildEvent());

    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    expect(find.byIcon(Icons.people_outline), findsNothing);
    expect(find.byIcon(Icons.repeat), findsNothing);
    expect(find.byIcon(Icons.public), findsNothing);
  });

  testWidgets('shows the optional details when they are set', (tester) async {
    await open(
      tester,
      buildEvent(
        location: 'Kathmandu',
        timeZoneId: 'Asia/Kathmandu',
        recurrence: RecurrenceRule.weekly,
        attendees: const [Attendee(name: 'Asha', email: 'asha@haineo.org')],
        notes: 'Bring the roadmap',
      ),
    );

    expect(find.text('Kathmandu'), findsOneWidget);
    expect(find.text('Asia/Kathmandu'), findsOneWidget);
    expect(find.text('Every week'), findsOneWidget);
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Bring the roadmap'), findsOneWidget);
  });

  testWidgets('Edit resolves to the edit action', (tester) async {
    final event = buildEvent();
    EventDetailsAction? result;

    await tester.pumpPage(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showEventDetailsSheet(context, event: event);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(result, EventDetailsAction.edit);
  });

  testWidgets('Delete resolves to the delete action', (tester) async {
    final event = buildEvent();
    EventDetailsAction? result;

    await tester.pumpPage(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showEventDetailsSheet(context, event: event);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, EventDetailsAction.delete);
  });
}
