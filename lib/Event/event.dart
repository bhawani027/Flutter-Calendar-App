import 'package:flutter/material.dart';
import 'dart:ui';

class Event {

  final DateTime startTime;
  final DateTime endTime;
  final String eventName;
  final DateTime from;
  final  DateTime to;
  final List<String> people;
  final int notificationMinutesBefore;
  final Color background;
  final bool isAllDay;
  final String location;

 Event({
   required this.location,
   required this.people,
   required this.notificationMinutesBefore,
   required this.background,
  required this.eventName,
  required this.isAllDay,
  required this.startTime,
  required this.endTime,
   required this.from,
   required this.to,
 });
}

class Person {
  final String name;
  final String email;

 Person({required this.name, required this.email});
}
