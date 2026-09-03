import 'package:flutter/material.dart';

import '../../domain/entities/attendee.dart';

/// Add and remove the people invited to an event.
///
/// Pops the edited list; the caller decides what to do with it.
class AttendeesPage extends StatefulWidget {
  const AttendeesPage({required this.attendees, super.key});

  final List<Attendee> attendees;

  @override
  State<AttendeesPage> createState() => _AttendeesPageState();
}

class _AttendeesPageState extends State<AttendeesPage> {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late List<Attendee> _attendees = List.of(widget.attendees);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _add() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _attendees = [
        ..._attendees,
        Attendee(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        ),
      ];
    });
    _nameController.clear();
    _emailController.clear();
    _formKey.currentState?.reset();
  }

  void _removeAt(int index) {
    setState(() {
      _attendees = [..._attendees]..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_attendees);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('People'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_attendees),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Please enter a name'
                              : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      onFieldSubmitted: (_) => _add(),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Please enter an email';
                        if (!_emailPattern.hasMatch(email)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _add,
                      child: const Text('Add person'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _attendees.isEmpty
                    ? const Center(child: Text('Nobody invited yet.'))
                    : ListView.builder(
                        itemCount: _attendees.length,
                        itemBuilder: (context, index) {
                          final attendee = _attendees[index];
                          return ListTile(
                            title: Text(attendee.name),
                            subtitle: Text(attendee.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeAt(index),
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
