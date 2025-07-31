import 'package:flutter/material.dart';
import 'package:mycalendar_app/Calendar/dayview.dart';
import 'package:mycalendar_app/Calendar/monthview.dart';
import 'package:mycalendar_app/Calendar/schedule.dart';
import 'package:mycalendar_app/Calendar/weekview.dart';
class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text("Schedule"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>scheduleview()));
            },
          ),
          ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>monthview()));
            },
            leading: Icon(Icons.calendar_view_month),
            title: Text("Month View")),

          ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>weekview()));
            },
            leading: Icon(Icons.calendar_view_week),
            title: Text("Week View"),
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_day),
            title: Text("Day View"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>dayview()));
            },
          )
        ],
      ),
    );
  }
}
