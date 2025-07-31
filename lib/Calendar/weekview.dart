import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class weekview extends StatefulWidget {
  const weekview({super.key});

  @override
  State<weekview> createState() => _weekviewState();
}

class _weekviewState extends State<weekview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        cellBorderColor: Colors.black,
        specialRegions: _getTimeRegions(),
        view: CalendarView.week,
        controller: CalendarController(),
    timeSlotViewSettings: TimeSlotViewSettings(
      allDayPanelColor: Colors.green,
      timeInterval: Duration(hours: 1),
      dateFormat: 'd',
      dayFormat: 'EEE',
      timeRulerSize: 50,
    timeIntervalHeight: -1,
      minimumAppointmentDuration: Duration(minutes:5)
      ),
      )
    );
  }

  List<TimeRegion> _getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    regions.add(TimeRegion(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        enablePointerInteraction: false,
        color: Colors.black.withOpacity(0.2),
        text: 'Break'
        ));

    return regions;

  }


}
