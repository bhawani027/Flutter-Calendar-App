import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/calendar_event.dart';

/// Adapts domain [CalendarEvent]s to the widget's [Appointment] model.
///
/// This is the only place Syncfusion's types meet ours — replacing the calendar
/// package would mean rewriting this file and nothing else.
class EventCalendarDataSource extends CalendarDataSource<Appointment> {
  EventCalendarDataSource(List<CalendarEvent> events) {
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
      );
}
