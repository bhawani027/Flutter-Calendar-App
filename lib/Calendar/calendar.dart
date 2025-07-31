import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mycalendar_app/Event/eventdata.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../Event/event.dart';
import '../NavBAr/navbar.dart';
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {


  CalendarView calendarView = CalendarView.month;
  @override
  Widget build(BuildContext context) {
    CalendarController calendarController = CalendarController();
    return Scaffold(
        drawer: Navbar(),
      appBar: AppBar(

        actions: [
          IconButton(onPressed: (){},
          icon: Icon(Icons.search),)
        ],
        backgroundColor: Colors.greenAccent,
        title: Text("Calendar"),
        centerTitle: true,
      ),

      body:Column(
        children: [


          Expanded(
            child: SfCalendar(
              view: CalendarView.day,
              cellBorderColor: Colors.transparent,

              selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.blue,width: 2)
              ),
              blackoutDates: [
                DateTime.now().subtract(Duration(hours:24)),
                DateTime.now().subtract(Duration(hours:48)),
              ],
            ),
          ),
        ],
    )
    );
  }
}


