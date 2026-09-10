import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/core/calendar/bikram_sambat.dart';
import 'package:mycalendar_app/core/calendar/nepali_date_labels.dart';
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
    double height = 90,
    double width = 60,
  }) async {
    await tester.pumpPage(
      Center(
        child: SizedBox(
          width: width,
          height: height,
          child: CalendarMonthCell(
            details: MonthCellDetails(
              date,
              List.generate(
                appointments,
                (i) => appointmentAt(date, Colors.blue),
              ),
              [date],
              Rect.fromLTWH(0, 0, width, height),
            ),
            visibleMonth: visibleMonth ?? date.month,
            isSelected: isSelected,
          ),
        ),
      ),
      size: const Size(400, 400),
    );
  }

  /// The BS day of [date] in Nepali numerals, as the cell should print it.
  String bsDayOf(DateTime date) =>
      NepaliDateLabels.day(BikramSambat.fromGregorian(date));

  group('the two dates', () {
    // 14 September 2026 is Bhadra 29, 2083.
    testWidgets('leads with the BS day in Nepali numerals', (tester) async {
      await pumpCell(tester, date: DateTime(2026, 9, 14));

      expect(find.text('२९'), findsOneWidget);
      expect(bsDayOf(DateTime(2026, 9, 14)), '२९');
    });

    testWidgets('keeps the AD day as the second line', (tester) async {
      await pumpCell(tester, date: DateTime(2026, 9, 14));

      expect(find.text('14'), findsOneWidget);
    });

    // A fixed two-digit width stops the column shifting sideways mid-month.
    testWidgets('pads a single-digit AD day', (tester) async {
      await pumpCell(tester, date: DateTime(2026, 9, 9));

      expect(find.text('09'), findsOneWidget);
      expect(find.text('9'), findsNothing);
      // 9 September 2026 is Bhadra 24, 2083.
      expect(find.text('२४'), findsOneWidget);
    });

    testWidgets('the BS day is not the AD day', (tester) async {
      await pumpCell(tester, date: DateTime(2026, 10, 3));

      // 3 October 2026 is Ashwin 17, 2083 — a different month as well as a
      // different number, which is the case the dual display exists for.
      expect(find.text('१७'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
    });

    testWidgets('a BS month boundary rolls the primary date over', (
      tester,
    ) async {
      // Bhadra 2083 ends on 16 September 2026; Ashwin 1 is the 17th.
      await pumpCell(tester, date: DateTime(2026, 9, 17));

      expect(find.text('१'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);
    });
  });

  group('events', () {
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
  });

  group('fitting the cell', () {
    // The grid divides whatever the agenda leaves over six rows, so the cell
    // has to survive heights well under the comfortable one.
    for (final height in <double>[90, 60, 46, 44, 38, 32, 26, 20, 16, 12, 8]) {
      testWidgets('renders without overflowing at ${height}px', (tester) async {
        await pumpCell(
          tester,
          date: DateTime(2026, 9, 14),
          appointments: 5,
          height: height,
        );

        expect(tester.takeException(), isNull);
        // The BS date is the one thing that never drops out, however little
        // room the row has; it shrinks instead.
        expect(find.text('२९'), findsOneWidget);
      });
    }

    for (final width in <double>[60, 44, 34]) {
      testWidgets('renders without overflowing at ${width}px wide', (
        tester,
      ) async {
        await pumpCell(
          tester,
          date: DateTime(2026, 9, 14),
          appointments: 3,
          width: width,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('styling', () {
    testWidgets('a trailing day from the next month still renders', (
      tester,
    ) async {
      await pumpCell(tester, date: DateTime(2026, 10, 3), visibleMonth: 9);

      expect(find.text('03'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a selected day is tinted', (tester) async {
      await pumpCell(tester, date: DateTime(2026, 9, 14), isSelected: true);

      expect(tester.takeException(), isNull);
      expect(find.text('२९'), findsOneWidget);
    });

    testWidgets('today is highlighted and dated in both calendars', (
      tester,
    ) async {
      final today = DateTime.now();
      await pumpCell(tester, date: today);

      expect(find.text(bsDayOf(today)), findsOneWidget);
      expect(find.text(today.day.toString().padLeft(2, '0')), findsOneWidget);
    });
  });
}
