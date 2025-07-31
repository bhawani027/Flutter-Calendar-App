import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
class scheduleview extends StatefulWidget {
  const scheduleview({super.key});

  @override
  State<scheduleview> createState() => _scheduleviewState();
}

class _scheduleviewState extends State<scheduleview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.schedule,
        controller: CalendarController(),
      ),
    );
  }
}
