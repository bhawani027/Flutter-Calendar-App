import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../location/domain/entities/place.dart';
import '../../domain/entities/attendee.dart';
import '../cubit/event_editor_cubit.dart';
import '../widgets/date_time_field.dart';
import '../widgets/event_color_picker.dart';
import '../widgets/recurrence_picker.dart';

/// Create or edit a single event.
///
/// Every field reads from and writes to [EventEditorCubit]; the widget keeps no
/// state of its own beyond the title's text controller.
class EventEditorPage extends StatefulWidget {
  const EventEditorPage({super.key});

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  late final TextEditingController _titleController =
      TextEditingController(text: context.read<EventEditorCubit>().state.title);

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickAttendees(List<Attendee> current) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.attendees,
      arguments: current,
    );
    if (result is List<Attendee> && mounted) {
      context.read<EventEditorCubit>().attendeesChanged(result);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.location);
    if (result is Place && mounted) {
      context.read<EventEditorCubit>().locationChanged(result.displayName);
    }
  }

  Future<void> _pickTimeZone() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.timeZone);
    if (result is String && mounted) {
      context.read<EventEditorCubit>().timeZoneChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EventEditorCubit>();

    return BlocConsumer<EventEditorCubit, EventEditorState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(state.isEditing ? 'Edit event' : 'Add event'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          final saved = await cubit.submit();
                          if (saved && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  child: Text(state.isEditing ? 'Save' : 'Add'),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: TextField(
                    controller: _titleController,
                    onChanged: cubit.titleChanged,
                    textCapitalization: TextCapitalization.sentences,
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: const InputDecoration(
                      hintText: 'Event title',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.schedule),
                  title: const Text('All day'),
                  value: state.isAllDay,
                  onChanged: cubit.allDayToggled,
                ),
                DateTimeField(
                  label: 'Starts',
                  value: state.start,
                  showTime: !state.isAllDay,
                  onDateChanged: cubit.startDateChanged,
                  onTimeChanged: cubit.startTimeChanged,
                ),
                DateTimeField(
                  label: 'Ends',
                  value: state.end,
                  showTime: !state.isAllDay,
                  onDateChanged: cubit.endDateChanged,
                  onTimeChanged: cubit.endTimeChanged,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.rotateRight, size: 20),
                  title: Text(state.recurrence.label),
                  onTap: () async {
                    final rule = await showRecurrencePicker(
                      context,
                      selected: state.recurrence,
                    );
                    if (rule != null) cubit.recurrenceSelected(rule);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('People'),
                  subtitle: Text(
                    state.attendees.isEmpty
                        ? 'Nobody invited yet'
                        : state.attendees.map((a) => a.name).join(', '),
                  ),
                  onTap: () => _pickAttendees(state.attendees),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Location'),
                  subtitle: Text(state.location ?? 'No location'),
                  onTap: _pickLocation,
                ),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: const Text('Time zone'),
                  subtitle: Text(state.timeZoneId ?? 'Device time zone'),
                  onTap: _pickTimeZone,
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: Color(state.colorValue)),
                  title: const Text('Colour'),
                  subtitle: Text(AppColors.nameOf(state.colorValue)),
                  onTap: () async {
                    final value = await showEventColorPicker(
                      context,
                      selectedValue: state.colorValue,
                    );
                    if (value != null) cubit.colorSelected(value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TextField(
                    onChanged: cubit.notesChanged,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
