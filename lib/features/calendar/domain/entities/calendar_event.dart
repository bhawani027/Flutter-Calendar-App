import 'package:equatable/equatable.dart';

import 'attendee.dart';
import 'recurrence_rule.dart';

/// A single entry on the calendar.
///
/// Pure Dart on purpose: no Flutter, no Syncfusion, no Hive. The colour is an
/// ARGB `int` rather than a `Color` so the domain stays framework-free.
class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.colorValue = defaultColorValue,
    this.attendees = const [],
    this.recurrence = RecurrenceRule.never,
    this.location,
    this.notes,
    this.timeZoneId,
    this.reminderBefore,
  });

  /// Material blue — the colour the app used before events were configurable.
  static const int defaultColorValue = 0xFF2196F3;

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final int colorValue;
  final List<Attendee> attendees;
  final RecurrenceRule recurrence;
  final String? location;
  final String? notes;
  final String? timeZoneId;
  final Duration? reminderBefore;

  Duration get duration => end.difference(start);

  /// True when this event covers any part of [day].
  bool occursOn(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return start.isBefore(dayEnd) && end.isAfter(dayStart);
  }

  /// True when this event overlaps the half-open range `[from, to)`.
  bool overlaps(DateTime from, DateTime to) =>
      start.isBefore(to) && end.isAfter(from);

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    int? colorValue,
    List<Attendee>? attendees,
    RecurrenceRule? recurrence,
    String? location,
    String? notes,
    String? timeZoneId,
    Duration? reminderBefore,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      colorValue: colorValue ?? this.colorValue,
      attendees: attendees ?? this.attendees,
      recurrence: recurrence ?? this.recurrence,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      reminderBefore: reminderBefore ?? this.reminderBefore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        start,
        end,
        isAllDay,
        colorValue,
        attendees,
        recurrence,
        location,
        notes,
        timeZoneId,
        reminderBefore,
      ];
}
