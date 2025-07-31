import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mycalendar_app/Meeting/addpeople.dart';
import 'package:mycalendar_app/button.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../Event/event.dart';
import '../Event/task.dart';

class Meetingeditor extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(Appointment) addEvent;

  Meetingeditor({this.selectedDate, required this.addEvent});

  @override
  _MeetingeditorState createState() => _MeetingeditorState();
}

class _MeetingeditorState extends State<Meetingeditor> {
  final _titleController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(hours: 1));
  CalendarController _calendarController = CalendarController();
  String _Addpeople = "No member data";

  @override
  void initState() {
    if (widget.selectedDate != null) {
      _calendarController = CalendarController();
      _startDate = DateTime.now();
      _endDate = _startDate.add(Duration(hours: 1));
      super.initState();
    }
  }

  bool isPressed = false;
  bool isAllDay = false;
  Future<void> _selectDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onDateChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      onDateChanged(picked);
    }
  }
  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, ValueChanged<TimeOfDay> onTimeChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      onTimeChanged(picked);
    }
  }
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, yyyy-MM-dd').format(dateTime);
  }
  String? selectedRadioValue;
  final List <String> radioItems = [
    "Does not repeat",
    "Every Day",
    "Every Week",
    "Every Month",
    "Every Year",
    "Custom recurrence"
  ];

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: radioItems.map((String value) {
              return RadioListTile<String>(
                title: Text(value),
                value: value,
                groupValue: selectedRadioValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRadioValue = newValue;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  List<Person> _people = [];

  void _navigateToAddPerson() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPersonScreen(people: _people)),
    );

    if (result != null) {
      setState(() {
        _people = result;
      });
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar:  AppBar(
          centerTitle: true,
          leading: IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: Icon(Icons.clear,size: 30,color: Colors.black,)),
          title: Text('Add Event'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                style: Addevent,
                onPressed: () {
                  final newAppointment = Appointment(
                    startTime: _startDate,
                    endTime: _endDate,
                    subject: _titleController.text,
                    color: Colors.blue,
                  );
                  widget.addEvent(newAppointment);
                  Navigator.pop(context,newAppointment);
                },
                child: Text('Add'),
              ),
            ),
          ],
        ),
    body: SingleChildScrollView(
      child: Column(
        children: [
      Padding(
        padding: const EdgeInsets.only(right: 40.0,left: 40.0,top:30),
        child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
            hintText: 'Event Title',
        hintStyle: TextStyle(color: Colors.black)),
              ),
      ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0,bottom: 20.0,right: 30,left: 30),
            child: Row(
              children: [
                ElevatedButton(
                  style:ElevatedButton.styleFrom(
                    backgroundColor: isPressed?Colors.green[200]: Colors.white,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4)
                      )
                    )
                  ),
                  onPressed: (){
                    setState(() {
                      isPressed = !isPressed;
                    });
                  },child: Text("Event"),),
                SizedBox(width: 20,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isPressed?Colors.white
                  :Colors.green[200],
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(4)
                          )
                      )),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>task()));
                    setState(() {
                      isPressed = !isPressed;
                    });
                    }, child: Text("Task")),
              ],
            ),
          ),
          SizedBox(height: 20,),
         Column(
           children: [
             ListTile(
               leading: Icon(Icons.schedule,color: Colors.black,) ,
               title: Text("All-Day",style: TextStyle(color: Colors.black),),
               trailing: Switch(
                 value:  isAllDay,
                 onChanged: (bool value){
                   setState(() {
                     isAllDay = value;
                   });
                 },
               ),
             ),
             Padding(
               padding: const EdgeInsets.only(left: 40),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
               Expanded(
                child: ListTile(
                title: Text(
                 _formatDateTime(_startDate),
                ),
                                 onTap: () async {
                 await _selectDate(context, _startDate, (date) {
                   setState(() {
                     _startDate = DateTime(
                       date.year,
                       date.month,
                       date.day,

                     );
                   });
                 });
                                 },
                              ),
                   ),
                   SizedBox(width:20),
                   Expanded(
                     child: Padding(
                       padding: const EdgeInsets.only(left: 80.0),
                       child: ListTile(
                         title: Text(
                           '${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                         ),
                         onTap: () async {
                           await _selectTime(context, TimeOfDay.fromDateTime(_startDate), (time) {
                             setState(() {
                               _startDate = DateTime(
                                 _startDate.year,
                                 _startDate.month,
                                 _startDate.day,
                                 time.hour,
                                 time.minute,
                               );
                               _endDate = _startDate.add(Duration(hours: 1));
                             });
                           });
                         },
                       ),
                     ),
                   ),
                            ],
                          ),
             ),
             Padding(
               padding: const EdgeInsets.only(left: 40.0),
               child: Row(
                 children: [
                   Expanded(
                     child: ListTile(
                       title: Text(
                         _formatDateTime(_endDate),),
                       onTap: () async {
                         await _selectDate(context, _endDate, (date) {
                           setState(() {
                             _endDate = DateTime(
                               date.year,
                               date.month,
                               date.day,

                             );
                           });
                         });
                       },
                     ),
                   ),
                   SizedBox(width: 20,),
                   Expanded(
                     child: Padding(
                       padding: const EdgeInsets.only(left: 80.0),
                       child: ListTile(
                         title: Text(
                           '${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                         ),
                         onTap: () async {
                           await _selectTime(context, TimeOfDay.fromDateTime(_endDate), (time) {
                             setState(() {
                               _endDate = DateTime(
                                 _endDate.year,
                                 _endDate.month,
                                 _endDate.day,
                                 time.hour,
                                 time.minute,
                               );
                             });
                           });
                         },
                       ),
                     ),
                   ),
                          ],
                        ),
             ),

             SizedBox(height:
               20,),
             Padding(
               padding: const EdgeInsets.only(left: 20.0),
               child: Row(
                 children: [
                   Icon(FontAwesomeIcons.rotateRight),
                   SizedBox(width: 20,),
                   GestureDetector(
                     onTap: () => _showDialog(context),
                     child: Text(selectedRadioValue ?? 'Does not repeat',

                       style: GoogleFonts.aBeeZee(
                         color: Colors.black,
                         fontSize: 17,
                       ),),
                   ),
                     ],

                   )

               ),
         SizedBox(height: 20,),
         Row(
            children: [
                   Padding(
                     padding: const EdgeInsets.only(left: 20.0),
                     child: Icon(CupertinoIcons.person_2),
                   ),
                   SizedBox(width: 20,),
                   Expanded(
                     child: GestureDetector(
                     onTap: _navigateToAddPerson,
                      child: Text("Add People",style: GoogleFonts.aBeeZee(
                        color: Colors.black,
                        fontSize: 17
                      ),),
                         ),
                   ),
                    Expanded(
                      child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                       child: Row(
                        children: [
                        for (var person in _people)
                        Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 1.0),
                         child: Container(
                         child:  Text(person.name,style:
                        GoogleFonts.aBeeZee(
                        color: Colors.black,
                       fontSize: 17,
                        ),),
                       ),
                        ),
                       ],
                       )
                                         ),
                    )
                  ],
              ),


          SizedBox(height: 20,),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Icon(CupertinoIcons.location_solid),
              ),
            ],
          )
         ]
         )
        ]
    )
    )
    );

  }

}
