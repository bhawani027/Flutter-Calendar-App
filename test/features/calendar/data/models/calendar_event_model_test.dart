import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/data/models/calendar_event_model.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/recurrence_rule.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CalendarEventModel', () {
    test('survives a JSON round trip unchanged', () {
      final original = CalendarEventModel.fromEntity(
        buildEvent(
          attendees: const [Attendee(name: 'Asha', email: 'asha@haineo.org')],
          recurrence: RecurrenceRule.weekly,
          location: 'Kathmandu',
          notes: 'Bring the roadmap',
          timeZoneId: 'Asia/Kathmandu',
        ),
      );

      final restored = CalendarEventModel.fromJson(original.toJson());

      expect(restored.toEntity(), equals(original.toEntity()));
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
      expect(restored.reminderBefore, isNull);
    });

    test('stores a reminder as whole minutes', () {
      final json = CalendarEventModel.fromEntity(
        buildEvent().copyWith(reminderBefore: const Duration(minutes: 15)),
      ).toJson();

      expect(json['reminderMinutesBefore'], 15);
      expect(
        CalendarEventModel.fromJson(json).reminderBefore,
        const Duration(minutes: 15),
      );
    });
  });

  test('RecurrenceRule.fromName falls back to never for unknown values', () {
    expect(RecurrenceRule.fromName('weekly'), RecurrenceRule.weekly);
    expect(RecurrenceRule.fromName('fortnightly'), RecurrenceRule.never);
    expect(RecurrenceRule.fromName(null), RecurrenceRule.never);
  });
}
