import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/error_snack_bar.dart';
import '../../domain/entities/attendee.dart';
import '../cubit/attendees_cubit.dart';

/// Add and remove the people invited to an event.
///
/// Pops the edited list; the caller decides what to do with it.
class AttendeesPage extends StatefulWidget {
  const AttendeesPage({super.key});

  @override
  State<AttendeesPage> createState() => _AttendeesPageState();
}

class _AttendeesPageState extends State<AttendeesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _add() {
    if (!context.read<AttendeesCubit>().add()) return;
    _nameController.clear();
    _emailController.clear();
    _nameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttendeesCubit>();

    return BlocConsumer<AttendeesCubit, AttendeesState>(
      listenWhen: (previous, current) =>
          errorAppeared(previous.errorMessage, current.errorMessage),
      listener: (context, state) =>
          showErrorSnackBar(context, state.errorMessage!),
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) Navigator.of(context).pop(state.attendees);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('People'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(state.attendees),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    onChanged: cubit.nameChanged,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    onChanged: cubit.emailChanged,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _add(),
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _add,
                    child: const Text('Add person'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.attendees.isEmpty
                        ? const Center(child: Text('Nobody invited yet.'))
                        : _AttendeeList(
                            attendees: state.attendees,
                            onRemove: cubit.removeAt,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AttendeeList extends StatelessWidget {
  const _AttendeeList({required this.attendees, required this.onRemove});

  final List<Attendee> attendees;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: attendees.length,
      itemBuilder: (context, index) {
        final attendee = attendees[index];
        return ListTile(
          title: Text(attendee.name),
          subtitle: Text(attendee.email),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove ${attendee.name}',
            onPressed: () => onRemove(index),
          ),
        );
      },
    );
  }
}
