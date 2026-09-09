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

  group('Bikram Sambat', () {
    String? bsFor(CalendarViewType view, DateTime date) =>
        CalendarPeriodLabel.bs(view, date);

    test('month and schedule views name the BS month that owns the page', () {
      // September 2026 is Bhadra 16-31 and then Ashwin 1-14, so it reads as
      // Bhadra — the month it is mostly in.
      expect(bsFor(CalendarViewType.month, DateTime(2026, 9, 9)), 'भाद्र २०८३');
      expect(
        bsFor(CalendarViewType.schedule, DateTime(2026, 9, 9)),
        'भाद्र २०८३',
      );
    });

    test('day view shows the full BS date', () {
      expect(
        bsFor(CalendarViewType.day, DateTime(2026, 9, 9)),
        'भाद्र २४, २०८३',
      );
    });

    test('a BS month label tracks the AD month it is paired with', () {
      expect(bsFor(CalendarViewType.month, DateTime(2026, 12, 31)), 'पौष २०८३');
      expect(
        bsFor(CalendarViewType.month, DateTime(2026, 4, 14)),
        'बैशाख २०८३',
      );
    });

    group('week view', () {
      test('collapses the month when the week sits inside one', () {
        // 6-12 September 2026 is Bhadra 21-27.
        expect(
          bsFor(CalendarViewType.week, DateTime(2026, 9, 9)),
          'भाद्र २१ – २७, २०८३',
        );
      });

      test('names both months when the week straddles them', () {
        // 13-19 September 2026 crosses from Bhadra into Ashwin.
        expect(
          bsFor(CalendarViewType.week, DateTime(2026, 9, 16)),
          'भाद्र २८ – आश्विन ३, २०८३',
        );
      });

      test('names both years when the week straddles a Nepali new year', () {
        // Baisakh 1, 2083 falls on Tuesday 14 April 2026, so the week
        // Sun 12 - Sat 18 April runs Chaitra 29, 2082 to Baisakh 5, 2083.
        expect(
          bsFor(CalendarViewType.week, DateTime(2026, 4, 14)),
          'चैत्र २९, २०८२ – बैशाख ५, २०८३',
        );
      });

      test('is stable for every day within the same week', () {
        final labels = {
          for (var day = 6; day <= 12; day++)
            bsFor(CalendarViewType.week, DateTime(2026, 9, day)),
        };
        expect(labels, hasLength(1));
      });
    });

    test('the two lines describe the same period', () {
      // Both come off one focused date, so a day that is in the AD label's
      // week has to be in the BS label's week too.
      for (final view in CalendarViewType.values) {
        final focused = DateTime(2026, 9, 9);
        expect(bsFor(view, focused), isNotNull);
        expect(CalendarPeriodLabel.of(view, focused), isNotEmpty);
      }
    });

    test('a date outside the BS table has no BS label', () {
      for (final view in CalendarViewType.values) {
        expect(bsFor(view, DateTime(1800, 1, 1)), isNull);
      }
    });
  });
}
