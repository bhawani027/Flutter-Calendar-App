import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import 'attendee.dart';
import 'recurrence_rule.dart';

/// A single entry on the calendar.
///
/// Pure Dart on purpose: no Flutter, no Syncfusion, no Hive. The colour is an
/// ARGB `int` rather than a `Color` so the domain stays framework-free.
///
/// The rules about what makes an event valid, and what `isAllDay` actually
/// means, live here in [validate] and [normalized] — not in whichever screen
/// happens to build one.
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
  });

  /// A blank event starting at the next full hour after [anchor].
  factory CalendarEvent.draft(DateTime anchor) {
    final start = anchor.withTime(anchor.hour, 0).add(const Duration(hours: 1));
    return CalendarEvent(
      id: '',
      title: '',
      start: start,
      end: start.add(const Duration(hours: 1)),
    );
  }

  /// The palette's blue — see `AppColors.eventPalette`.
  static const int defaultColorValue = 0xFF3D4FB5;

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

  Duration get duration => end.difference(start);

  /// True when this event overlaps the half-open range `[from, to)`.
  bool overlaps(DateTime from, DateTime to) =>
      start.isBefore(to) && end.isAfter(from);

  /// True when this event covers any part of [day].
  bool occursOn(DateTime day) =>
      overlaps(day.startOfDay, day.startOfDay.add(const Duration(days: 1)));

  /// The reason this event may not be saved, or null when it is fine.
  ValidationFailure? validate() {
    if (title.trim().isEmpty) {
      return const ValidationFailure('Give the event a title.');
    }
    if (!end.isAfter(start)) {
      return const ValidationFailure('The event must end after it starts.');
    }
    return null;
  }

  /// The form this event takes once stored: the title is trimmed, and an
  /// all-day event is widened to cover its whole day.
  ///
  /// Applied by the save use cases, so it holds no matter which caller built
  /// the event.
  CalendarEvent normalized() {
    return copyWith(
      title: title.trim(),
      start: isAllDay ? start.startOfDay : start,
      end: isAllDay ? end.endOfDay : end,
    );
  }

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
  ];
}
