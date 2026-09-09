import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mycalendar_app/features/calendar/presentation/widgets/calendar_period_label.dart';

void main() {
  String labelFor(CalendarViewType view, DateTime date) =>
      CalendarPeriodLabel.of(view, date);

  test('month and schedule views show the month and year', () {
    expect(
      labelFor(CalendarViewType.month, DateTime(2026, 9, 3)),
      'September 2026',
    );
    expect(
      labelFor(CalendarViewType.schedule, DateTime(2026, 9, 3)),
      'September 2026',
    );
  });

  test('day view shows the full date', () {
    expect(
      labelFor(CalendarViewType.day, DateTime(2026, 9, 3)),
      'Thu, 3 Sep 2026',
    );
  });

  group('week view', () {
    // 2026-09-03 is a Thursday, so its week runs Sun 30 Aug – Sat 5 Sep.
    test('collapses the month when the week sits inside one', () {
      expect(
        labelFor(CalendarViewType.week, DateTime(2026, 9, 9)),
        '6 – 12 Sep 2026',
      );
    });

    test('names both months when the week straddles them', () {
      expect(
        labelFor(CalendarViewType.week, DateTime(2026, 9, 3)),
        '30 Aug – 5 Sep 2026',
      );
    });

    test('names both years when the week straddles them', () {
      expect(
        labelFor(CalendarViewType.week, DateTime(2026, 12, 31)),
        '27 Dec 2026 – 2 Jan 2027',
      );
    });

    test('is stable for every day within the same week', () {
      final labels = {
        for (var day = 6; day <= 12; day++)
          labelFor(CalendarViewType.week, DateTime(2026, 9, day)),
      };
      expect(labels, hasLength(1));
    });
  });
}
