import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/core/error/failures.dart';
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

  group('draft', () {
    test('starts at the next full hour and lasts an hour', () {
      final draft = CalendarEvent.draft(DateTime(2026, 9, 3, 14, 37));

      expect(draft.start, DateTime(2026, 9, 3, 15));
      expect(draft.end, DateTime(2026, 9, 3, 16));
      expect(draft.id, isEmpty);
    });
  });

  group('validate', () {
    test('accepts a well-formed event', () {
      expect(buildEvent().validate(), isNull);
    });

    test('rejects a blank or whitespace-only title', () {
      expect(buildEvent(title: '').validate(), isA<ValidationFailure>());
      expect(buildEvent(title: '   ').validate(), isA<ValidationFailure>());
    });

    test('rejects an end that is not after the start', () {
      final start = DateTime(2026, 9, 3, 9);
      expect(
        buildEvent(start: start, end: start).validate(),
        isA<ValidationFailure>(),
      );
    });
  });

  group('normalized', () {
    test('trims the title', () {
      expect(buildEvent(title: '  Standup  ').normalized().title, 'Standup');
    });

    test('widens an all-day event across the whole day', () {
      final normalized = buildEvent(isAllDay: true).normalized();

      expect(normalized.start, DateTime(2026, 9, 3));
      expect(normalized.end.hour, 23);
      expect(normalized.end.minute, 59);
    });

    test('leaves a timed event alone', () {
      final event = buildEvent();
      expect(event.normalized().start, event.start);
      expect(event.normalized().end, event.end);
    });
  });

  test('the default colour is in the picker palette', () {
    // Guards the old bug where the default was a blue the palette did not
    // contain, so a new event showed nothing selected in the colour picker.
    expect(CalendarEvent.defaultColorValue, 0xFF3D4FB5);
  });
}
