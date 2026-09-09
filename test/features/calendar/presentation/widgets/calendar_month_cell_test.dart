import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/presentation/widgets/calendar_month_cell.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../helpers/pump_page.dart';

void main() {
  configureWidgetTests();

  Appointment appointmentAt(DateTime day, Color color) => Appointment(
    startTime: day,
    endTime: day.add(const Duration(hours: 1)),
    subject: 'Event',
    color: color,
  );

  Future<void> pumpCell(
    WidgetTester tester, {
    required DateTime date,
    int appointments = 0,
    int? visibleMonth,
    bool isSelected = false,
  }) async {
    await tester.pumpPage(
      Center(
        child: SizedBox(
          width: 60,
          height: 90,
          child: CalendarMonthCell(
            details: MonthCellDetails(
              date,
              List.generate(
                appointments,
                (i) => appointmentAt(date, Colors.blue),
              ),
              [date],
              const Rect.fromLTWH(0, 0, 60, 90),
            ),
            visibleMonth: visibleMonth ?? date.month,
            isSelected: isSelected,
          ),
        ),
      ),
      size: const Size(400, 400),
    );
  }

  testWidgets('renders the day number', (tester) async {
    await pumpCell(tester, date: DateTime(2026, 9, 14));

    expect(find.text('14'), findsOneWidget);
  });

  testWidgets('shows one dot per event', (tester) async {
    await pumpCell(tester, date: DateTime(2026, 9, 14), appointments: 3);

    expect(find.byType(DecoratedBox), findsWidgets);
    // The overflow counter only appears past the cap.
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('caps the dots and counts the remainder', (tester) async {
    await pumpCell(tester, date: DateTime(2026, 9, 14), appointments: 7);

    expect(find.text('+3'), findsOneWidget);
  });

  testWidgets('a day with no events renders no dots or counter', (
    tester,
  ) async {
    await pumpCell(tester, date: DateTime(2026, 9, 14));

    expect(find.textContaining('+'), findsNothing);
  });

  // A cell must never grow with its event count: the month grid gives every
  // cell the same height, so an overflowing one would break the whole row.
  testWidgets('stays within its cell however many events it has', (
    tester,
  ) async {
    await pumpCell(tester, date: DateTime(2026, 9, 14), appointments: 20);

    expect(tester.takeException(), isNull);
  });

  testWidgets('a trailing day from the next month still renders', (
    tester,
  ) async {
    await pumpCell(tester, date: DateTime(2026, 10, 3), visibleMonth: 9);

    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a selected day is tinted', (tester) async {
    await pumpCell(tester, date: DateTime(2026, 9, 14), isSelected: true);

    expect(tester.takeException(), isNull);
    expect(find.text('14'), findsOneWidget);
  });
}
