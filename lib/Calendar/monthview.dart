import 'package:flutter/material.dart';
import 'package:mycalendar_app/Calendar/calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
class monthview extends StatefulWidget {
  const monthview({super.key});

  @override
  State<monthview> createState() => _monthviewState();
}

class _monthviewState extends State<monthview> {
  CalendarController calendarController = CalendarController();
  CalendarView calendarView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        controller: CalendarController(),
        dataSource: AppointmentDataSource(_appointments),
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell && details.date != null) {
            _calendarController.view = CalendarView.day;
            DateTime selectedDate = details.date!;
            _showAddEventDialog(context, selectedDate);
            _calendarController.displayDate = details.date;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context, _calendarController.selectedDate ?? DateTime.now());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, DateTime selectedDate) {
    TextEditingController _eventController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Event"),
        content: TextField(
          controller: _eventController,
          decoration: InputDecoration(hintText: 'Event Title'),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Ok"),
            onPressed: () {
              if (_eventController.text.isNotEmpty) {
                setState(() {
                  _appointments.add(
                    Appointment(
                      startTime: selectedDate,
                      endTime: selectedDate.add(Duration(hours: 1)),
                      subject: _eventController.text,
                      color: Colors.blue,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
