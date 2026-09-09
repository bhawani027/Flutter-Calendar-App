import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/core/calendar/bikram_sambat.dart';
import 'package:nepali_utils/nepali_utils.dart';

void main() {
  String bs(DateTime date) {
    final converted = BikramSambat.fromGregorian(date);
    return '${converted.year}-${converted.month}-${converted.day}';
  }

  String ad(int year, int month, int day) {
    final converted = BikramSambat.toGregorian(
      NepaliDateTime(year, month, day),
    );
    return '${converted.year}-${converted.month}-${converted.day}';
  }

  // Each of these is checked against a published Nepali calendar; they are the
  // fixed points the rest of the conversion is measured from.
  group('known dates', () {
    test('the table\'s epoch', () {
      expect(bs(DateTime(1913, 4, 13)), '1970-1-1');
      expect(ad(1970, 1, 1), '1913-4-13');
    });

    test('Nepali new year', () {
      expect(bs(DateTime(2024, 4, 13)), '2081-1-1');
      expect(bs(DateTime(2025, 4, 14)), '2082-1-1');
      expect(bs(DateTime(2026, 4, 14)), '2083-1-1');
      expect(bs(DateTime(1990, 4, 14)), '2047-1-1');
    });

    test('the day before a Nepali new year ends the old year', () {
      expect(bs(DateTime(2026, 4, 13)), '2082-12-30');
    });

    test('the AD millennium', () {
      expect(bs(DateTime(2000, 1, 1)), '2056-9-17');
      expect(ad(2056, 9, 17), '2000-1-1');
    });

    test('9 September 2026 is Bhadra 24, 2083', () {
      expect(bs(DateTime(2026, 9, 9)), '2083-5-24');
      expect(ad(2083, 5, 24), '2026-9-9');
    });
  });

  group('round trip', () {
    // These walk calendar days in UTC. Stepping a local `DateTime` by
    // `Duration(days: 1)` would add 24 absolute hours instead, which stalls on
    // the day a zone puts its clocks back and skips the day it puts them
    // forward — a property of the loop, not of the conversion.
    test('every day from 1970 to 2090 survives AD -> BS -> AD', () {
      var date = DateTime.utc(1970, 1, 1);
      final end = DateTime.utc(2090, 12, 31);
      var checked = 0;
      var missingLocally = 0;

      while (date.isBefore(end)) {
        final local = DateTime(date.year, date.month, date.day);
        // A few zones have skipped a calendar day outright — Kiritimati has no
        // 31 December 1994, having crossed the date line that night — and Dart
        // normalises such a date to the next one. There is no local `DateTime`
        // to come back to, so it is counted rather than asserted on.
        if (local.day != date.day || local.month != date.month) {
          missingLocally++;
          date = date.add(const Duration(days: 1));
          continue;
        }

        final converted = BikramSambat.fromGregorian(date);
        final back = BikramSambat.toGregorian(converted);
        expect(
          [back.year, back.month, back.day],
          [date.year, date.month, date.day],
          reason: 'AD ${date.year}-${date.month}-${date.day} came back wrong',
        );
        date = date.add(const Duration(days: 1));
        checked++;
      }

      expect(checked, greaterThan(44000));
      // No zone has skipped more than a day or two in this span.
      expect(missingLocally, lessThan(3));
    });

    test('successive AD days are successive BS days', () {
      var date = DateTime.utc(2020, 1, 1);
      var previous = BikramSambat.fromGregorian(date);

      for (var i = 0; i < 3000; i++) {
        date = date.add(const Duration(days: 1));
        final current = BikramSambat.fromGregorian(date);

        if (current.day != previous.day + 1) {
          // A rollover: the previous day must have ended its BS month.
          expect(current.day, 1);
          expect(
            previous.day,
            BikramSambat.daysInMonth(previous.year, previous.month),
          );
        }
        previous = current;
      }
    });
  });

  group('boundaries', () {
    test('an AD leap day converts and returns', () {
      final leapDay = DateTime(2024, 2, 29);
      final converted = BikramSambat.fromGregorian(leapDay);
      final back = BikramSambat.toGregorian(converted);

      expect([back.year, back.month, back.day], [2024, 2, 29]);
    });

    test('29 February is only offered by AD leap years', () {
      // Feb 29 in a non-leap year rolls to 1 March, and must still convert.
      final rolled = DateTime(2025, 2, 29);
      expect(rolled.month, 3);
      expect(BikramSambat.covers(rolled), isTrue);
    });

    test('AD year end and start are consecutive BS days', () {
      final lastOfYear = BikramSambat.fromGregorian(DateTime(2026, 12, 31));
      final firstOfNext = BikramSambat.fromGregorian(DateTime(2027, 1, 1));
      expect(firstOfNext.day, lastOfYear.day + 1);
      expect(firstOfNext.month, lastOfYear.month);
    });

    test('a BS month runs 29 to 32 days', () {
      for (var year = BikramSambat.minYear; year <= 2100; year++) {
        for (var month = 1; month <= 12; month++) {
          expect(
            BikramSambat.daysInMonth(year, month),
            allOf(greaterThanOrEqualTo(29), lessThanOrEqualTo(32)),
            reason: 'BS $year-$month',
          );
        }
      }
    });

    test('a BS year is 365 or 366 days', () {
      for (var year = BikramSambat.minYear; year <= 2100; year++) {
        final total = List.generate(
          12,
          (index) => BikramSambat.daysInMonth(year, index + 1),
        ).reduce((a, b) => a + b);
        expect(total, anyOf(365, 366), reason: 'BS $year');
      }
    });

    test('the time of day survives BS -> AD', () {
      final converted = BikramSambat.toGregorian(
        NepaliDateTime(2083, 5, 24, 14, 30),
      );
      expect(converted.hour, 14);
      expect(converted.minute, 30);
    });

    test('the time of day does not shift the BS date', () {
      for (final hour in [0, 1, 6, 12, 18, 23]) {
        expect(
          bs(DateTime(2026, 9, 9, hour, 30)),
          '2083-5-24',
          reason: 'at $hour:30',
        );
      }
    });
  });

  group('outside the table', () {
    test('a date before the table has no BS form', () {
      expect(BikramSambat.tryFromGregorian(DateTime(1900, 1, 1)), isNull);
      expect(BikramSambat.covers(DateTime(1900, 1, 1)), isFalse);
    });

    test('a date after the table has no BS form', () {
      expect(BikramSambat.tryFromGregorian(DateTime(2300, 1, 1)), isNull);
    });

    test('fromGregorian reports the range it covers', () {
      expect(
        () => BikramSambat.fromGregorian(DateTime(1900, 1, 1)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('the range the calendar can reach is covered', () {
      // The date pickers run 2000-2100, so every date they offer must convert.
      expect(BikramSambat.covers(DateTime(2000, 1, 1)), isTrue);
      expect(BikramSambat.covers(DateTime(2100, 12, 31)), isTrue);
    });
  });

  group('dominant month', () {
    test('September 2026 reads as Bhadra, which owns most of it', () {
      final month = BikramSambat.tryDominantMonth(2026, 9)!;
      expect([month.year, month.month], [2083, 5]);
    });

    test('every AD month from 2020 to 2050 picks a real BS month', () {
      for (var year = 2020; year <= 2050; year++) {
        for (var month = 1; month <= 12; month++) {
          final dominant = BikramSambat.tryDominantMonth(year, month);
          expect(dominant, isNotNull, reason: 'AD $year-$month');
          expect(dominant!.month, allOf(greaterThan(0), lessThan(13)));

          // It has to be one of the two BS months the page actually touches.
          final first = BikramSambat.fromGregorian(DateTime(year, month, 1));
          final last = BikramSambat.fromGregorian(DateTime(year, month + 1, 0));
          expect(
            dominant.month,
            anyOf(first.month, last.month),
            reason: 'AD $year-$month picked an unrelated BS month',
          );
        }
      }
    });

    test('December pairs without rolling past the table', () {
      expect(BikramSambat.tryDominantMonth(2026, 12), isNotNull);
    });
  });
}
