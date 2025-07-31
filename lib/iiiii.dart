// lib/screens/add_person_screen.dart
import 'package:flutter/material.dart';
import 'Event/event.dart';

class AddPersonScreen extends StatefulWidget {
  final List<Person> people;

  AddPersonScreen({required this.people});

  @override
  _AddPersonScreenState createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Person> _peopleToAdd;
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _peopleToAdd = List.from(widget.people);
  }

  void _addPerson() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _peopleToAdd.add(Person(name: _name, email: _email));
      });
      _formKey.currentState!.reset();
    }
  }

  void _submitAll() {
    Navigator.of(context).pop(_peopleToAdd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add People'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _submitAll,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
                onFieldSubmitted: (_) {
                  _addPerson();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPerson,
                child: Text('Add Person'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _peopleToAdd.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_peopleToAdd[index].name),
                      subtitle: Text(_peopleToAdd[index].email),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _peopleToAdd.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








