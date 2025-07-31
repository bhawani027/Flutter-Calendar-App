import 'package:flutter/material.dart';
import 'package:mycalendar_app/Event/eventdata.dart';
import 'package:mycalendar_app/Meeting/meetingeditor.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
class dayview extends StatefulWidget {
  const dayview({super.key});

  @override
  State<dayview> createState() => _dayviewState();
}

class _dayviewState extends State<dayview> {
  final CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = <Appointment>[];
  eventdata _events = eventdata([]);


  void initState() {
    super.initState();
    _events = eventdata(_appointments);
  }

  void _addAppointment(Appointment appointment) {
    setState(() {
      _appointments.add(appointment);
      _events = eventdata(_appointments); // Update the data source
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.day,
        controller: CalendarController(),
        dataSource: eventdata(_appointments),
        resourceViewSettings: ResourceViewSettings(),
        onTap: (CalendarTapDetails details) async {
          if (details.targetElement == CalendarElement.calendarCell) {
            DateTime selectedDate = details.date!;
            final newEvent = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Meetingeditor(
                      selectedDate: selectedDate,
                      addEvent: _addAppointment,
                    ),
              ),
            );
            if (newEvent != null) {
              _addAppointment(newEvent);
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEvent = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Meetingeditor(addEvent: _addAppointment)),
          );
          if (newEvent != null) {
            _addAppointment(newEvent);
          }
        },
        child: Icon(Icons.add),

      )
    );
  }

}



