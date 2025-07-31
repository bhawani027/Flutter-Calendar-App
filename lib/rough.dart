// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:mycalendar_app/iiiii.dart';

import 'Event/event.dart';
// lib/main.dart


void main() {
  runApp(PeopleApp());
}

class PeopleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}








class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      appBar: AppBar(
        title: Text('People List'),
      ),
      body: _people.isEmpty
          ? Center(
          child: GestureDetector(
          onTap: _navigateToAddPerson,
          child: Text(
            'Tap here to add a person',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      )
          : ListView.builder(
        itemCount: _people.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: _navigateToAddPerson,
            child: ListTile(
              title: Text(_people[index].name),
            ),
          );
        },
      ),
    );
  }
}
