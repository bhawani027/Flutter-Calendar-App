import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/presentation/error_snack_bar.dart';
import '../../domain/entities/attendee.dart';
import '../../domain/entities/calendar_event.dart';
import '../cubit/event_editor_cubit.dart';
import '../widgets/date_time_field.dart';
import '../widgets/event_color_picker.dart';
import '../widgets/recurrence_picker.dart';

/// Create or edit a single event.
///
/// Every field reads from and writes to [EventEditorCubit]; the widget keeps no
/// state of its own beyond the title's text controller.
class EventEditorPage extends StatefulWidget {
  const EventEditorPage({required this.onDelete, super.key});

  /// Called when the user deletes the event being edited.
  final Future<void> Function(String id) onDelete;

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  late final CalendarEvent _initial =
      context.read<EventEditorCubit>().state.draft;
  late final TextEditingController _titleController =
      TextEditingController(text: _initial.title);
  late final TextEditingController _notesController =
      TextEditingController(text: _initial.notes);

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAttendees(List<Attendee> current) async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.attendees, arguments: current);
    if (result is List<Attendee> && mounted) {
      context.read<EventEditorCubit>().attendeesChanged(result);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.location);
    if (result is String && mounted) {
      context.read<EventEditorCubit>().locationChanged(result);
    }
  }

  Future<void> _pickTimeZone() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.timeZone);
    if (result is String && mounted) {
      context.read<EventEditorCubit>().timeZoneChanged(result);
    }
  }

  Future<void> _confirmDelete(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"$title" will be removed from your calendar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.onDelete(id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EventEditorCubit>();

    return BlocConsumer<EventEditorCubit, EventEditorState>(
      listenWhen: (previous, current) =>
          errorAppeared(previous.errorMessage, current.errorMessage),
      listener: (context, state) =>
          showErrorSnackBar(context, state.errorMessage!),
      builder: (context, state) {
        final draft = state.draft;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(state.isEditing ? 'Edit event' : 'Add event'),
            actions: [
              if (state.isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete event',
                  onPressed: () => _confirmDelete(draft.id, draft.title),
                ),
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
                  value: draft.isAllDay,
                  onChanged: cubit.allDayToggled,
                ),
                DateTimeField(
                  label: 'Starts',
                  value: draft.start,
                  showTime: !draft.isAllDay,
                  onDateChanged: cubit.startDateChanged,
                  onTimeChanged: cubit.startTimeChanged,
                ),
                DateTimeField(
                  label: 'Ends',
                  value: draft.end,
                  showTime: !draft.isAllDay,
                  onDateChanged: cubit.endDateChanged,
                  onTimeChanged: cubit.endTimeChanged,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.rotateRight, size: 20),
                  title: Text(draft.recurrence.label),
                  onTap: () async {
                    final rule = await showRecurrencePicker(
                      context,
                      selected: draft.recurrence,
                    );
                    if (rule != null) cubit.recurrenceSelected(rule);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('People'),
                  subtitle: Text(
                    draft.attendees.isEmpty
                        ? 'Nobody invited yet'
                        : draft.attendees.map((a) => a.name).join(', '),
                  ),
                  onTap: () => _pickAttendees(draft.attendees),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Location'),
                  subtitle: Text(draft.location ?? 'No location'),
                  onTap: _pickLocation,
                ),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: const Text('Time zone'),
                  subtitle: Text(draft.timeZoneId ?? 'Device time zone'),
                  onTap: _pickTimeZone,
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: Color(draft.colorValue)),
                  title: const Text('Colour'),
                  subtitle: Text(AppColors.nameOf(draft.colorValue)),
                  onTap: () async {
                    final value = await showEventColorPicker(
                      context,
                      selectedValue: draft.colorValue,
                    );
                    if (value != null) cubit.colorSelected(value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TextField(
                    controller: _notesController,
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
