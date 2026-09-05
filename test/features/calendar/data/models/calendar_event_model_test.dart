import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/data/models/calendar_event_model.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/recurrence_rule.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CalendarEventModel', () {
    test('survives a JSON round trip unchanged', () {
      final original = buildEvent(
        attendees: const [Attendee(name: 'Asha', email: 'asha@haineo.org')],
        recurrence: RecurrenceRule.weekly,
        location: 'Kathmandu',
        notes: 'Bring the roadmap',
        timeZoneId: 'Asia/Kathmandu',
      );

      final restored =
          CalendarEventModel.fromJson(CalendarEventModel.toJson(original));

      expect(restored, equals(original));
    });

    // The mapper returns entities, so a decoded event compares equal to one
    // built directly. A model subclass never would — Equatable includes the
    // runtime type.
    test('decodes to a plain CalendarEvent', () {
      final restored =
          CalendarEventModel.fromJson(CalendarEventModel.toJson(buildEvent()));

      expect(restored.runtimeType, CalendarEvent);
    });

    test('falls back to sane defaults when fields are missing', () {
      final restored = CalendarEventModel.fromJson({
        'id': 'event-9',
        'start': '2026-09-03T09:00:00.000',
        'end': '2026-09-03T10:00:00.000',
      });

      expect(restored.title, '');
      expect(restored.isAllDay, isFalse);
      expect(restored.attendees, isEmpty);
      expect(restored.recurrence, RecurrenceRule.never);
      expect(restored.colorValue, CalendarEvent.defaultColorValue);
    });
  });

  test('RecurrenceRule.fromName falls back to never for unknown values', () {
    expect(RecurrenceRule.fromName('weekly'), RecurrenceRule.weekly);
    expect(RecurrenceRule.fromName('fortnightly'), RecurrenceRule.never);
    expect(RecurrenceRule.fromName(null), RecurrenceRule.never);
  });
}
