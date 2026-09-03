import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CalendarEvent', () {
    final event = buildEvent(
      start: DateTime(2026, 9, 3, 9),
      end: DateTime(2026, 9, 3, 10, 30),
    );

    test('reports its duration', () {
      expect(event.duration, const Duration(hours: 1, minutes: 30));
    });

    test('occursOn is true for the day it falls on', () {
      expect(event.occursOn(DateTime(2026, 9, 3)), isTrue);
      expect(event.occursOn(DateTime(2026, 9, 4)), isFalse);
    });

    test('occursOn covers every day a multi-day event spans', () {
      final trip = buildEvent(
        start: DateTime(2026, 9, 3, 18),
        end: DateTime(2026, 9, 5, 9),
      );
      expect(trip.occursOn(DateTime(2026, 9, 4)), isTrue);
      expect(trip.occursOn(DateTime(2026, 9, 5)), isTrue);
      expect(trip.occursOn(DateTime(2026, 9, 6)), isFalse);
    });

    test('overlaps treats the range as half-open', () {
      // An event ending exactly when the range starts does not overlap it.
      expect(
        event.overlaps(DateTime(2026, 9, 3, 10, 30), DateTime(2026, 9, 3, 12)),
        isFalse,
      );
      expect(
        event.overlaps(DateTime(2026, 9, 3, 10), DateTime(2026, 9, 3, 12)),
        isTrue,
      );
    });

    test('copyWith replaces only the named fields', () {
      final renamed = event.copyWith(title: 'Retro');
      expect(renamed.title, 'Retro');
      expect(renamed.id, event.id);
      expect(renamed.start, event.start);
    });

    test('is compared by value', () {
      expect(buildEvent(), equals(buildEvent()));
      expect(buildEvent(), isNot(equals(buildEvent(title: 'Other'))));
    });
  });

  test('the default colour is Material blue', () {
    expect(CalendarEvent.defaultColorValue, 0xFF2196F3);
  });
}
