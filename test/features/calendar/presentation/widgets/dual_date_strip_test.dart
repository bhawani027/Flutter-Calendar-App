import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/presentation/widgets/dual_date_strip.dart';

import '../../../../helpers/pump_page.dart';

void main() {
  configureWidgetTests();

  Future<void> pumpStrip(
    WidgetTester tester,
    DateTime date, {
    double width = 400,
  }) async {
    await tester.pumpPage(
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          child: DualDateStrip(date: date),
        ),
      ),
      size: Size(width, 400),
    );
  }

  testWidgets('names the day in both calendars', (tester) async {
    await pumpStrip(tester, DateTime(2026, 9, 9));

    expect(find.text('भाद्र २४, २०८३'), findsOneWidget);
    expect(find.text('September 9, 2026'), findsOneWidget);
    expect(find.text('BS:'), findsOneWidget);
    expect(find.text('AD:'), findsOneWidget);
  });

  testWidgets('a day where the two months differ', (tester) async {
    await pumpStrip(tester, DateTime(2026, 10, 3));

    expect(find.text('आश्विन १७, २०८३'), findsOneWidget);
    expect(find.text('October 3, 2026'), findsOneWidget);
  });

  testWidgets('a Nepali new year', (tester) async {
    await pumpStrip(tester, DateTime(2026, 4, 14));

    expect(find.text('बैशाख १, २०८३'), findsOneWidget);
    expect(find.text('April 14, 2026'), findsOneWidget);
  });

  testWidgets('the time of day does not change either reading', (tester) async {
    await pumpStrip(tester, DateTime(2026, 9, 9, 23, 45));

    expect(find.text('भाद्र २४, २०८३'), findsOneWidget);
    expect(find.text('September 9, 2026'), findsOneWidget);
  });

  testWidgets('outside the BS table only the AD date is shown', (tester) async {
    await pumpStrip(tester, DateTime(1800, 6, 1));

    expect(find.text('BS:'), findsNothing);
    expect(find.text('AD:'), findsOneWidget);
    expect(find.text('June 1, 1800'), findsOneWidget);
  });

  // The two halves sit side by side when there is room and wrap when there is
  // not, so a narrow phone still shows both in full.
  for (final width in <double>[720, 400, 320, 240]) {
    testWidgets('both dates survive a ${width}px width', (tester) async {
      await pumpStrip(tester, DateTime(2026, 9, 9), width: width);

      expect(tester.takeException(), isNull);
      expect(find.text('भाद्र २४, २०८३'), findsOneWidget);
      expect(find.text('September 9, 2026'), findsOneWidget);
    });
  }
}
