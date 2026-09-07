import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/time/time_zone_db.dart';
import '../../domain/entities/calendar_event.dart';

/// Adapts domain [CalendarEvent]s to the widget's [Appointment] model.
///
/// This is the only place Syncfusion's types meet ours — replacing the calendar
/// package would mean rewriting this file and nothing else.
class EventCalendarDataSource extends CalendarDataSource<Appointment> {
  EventCalendarDataSource(List<CalendarEvent> events) {
    // An event that names a zone is converted into the device's zone by the
    // calendar, which needs the IANA database loaded to resolve the name.
    if (events.any((event) => event.timeZoneId != null)) {
      TimeZoneDb.ensureInitialized();
    }
    appointments = events.map(toAppointment).toList();
  }

  static Appointment toAppointment(CalendarEvent event) => Appointment(
    id: event.id,
    startTime: event.start,
    endTime: event.end,
    subject: event.title,
    color: Color(event.colorValue),
    isAllDay: event.isAllDay,
    recurrenceRule: event.recurrence.rrule,
    location: event.location,
    notes: event.notes,
    // Left null for an event with no zone, which the calendar then treats
    // as already being in the device's zone.
    startTimeZone: event.timeZoneId,
    endTimeZone: event.timeZoneId,
  );
}
