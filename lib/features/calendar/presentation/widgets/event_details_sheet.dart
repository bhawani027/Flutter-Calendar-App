import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_event.dart';

/// What the user chose to do with the event they tapped.
enum EventDetailsAction { edit, delete }

/// A preview of the tapped event, shown as a bottom sheet.
///
/// Google Calendar and Outlook both surface a peek at the event before the
/// full editor, so a stray tap while navigating does not throw the user into
/// an edit screen they have to back out of.
Future<EventDetailsAction?> showEventDetailsSheet(
  BuildContext context, {
  required CalendarEvent event,
}) {
  return showModalBottomSheet<EventDetailsAction>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _EventDetailsSheet(event: event),
  );
}

class _EventDetailsSheet extends StatelessWidget {
  const _EventDetailsSheet({required this.event});

  static final DateFormat _dayLong = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _time = DateFormat.jm();

  final CalendarEvent event;

  String get _when {
    if (event.isAllDay) {
      return event.start.day == event.end.day
          ? '${_dayLong.format(event.start)} · All day'
          : '${_dayLong.format(event.start)} – '
                '${_dayLong.format(event.end)} · All day';
    }
    final sameDay =
        event.start.year == event.end.year &&
        event.start.month == event.end.month &&
        event.start.day == event.end.day;
    if (sameDay) {
      return '${_dayLong.format(event.start)}\n'
          '${_time.format(event.start)} – ${_time.format(event.end)}';
    }
    return '${_dayLong.format(event.start)} ${_time.format(event.start)}\n'
        '${_dayLong.format(event.end)} ${_time.format(event.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: Color(event.colorValue),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(event.title, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Detail(icon: Icons.schedule, text: _when),
            if (event.recurrence.rrule != null)
              _Detail(icon: Icons.repeat, text: event.recurrence.label),
            if (event.location != null && event.location!.isNotEmpty)
              _Detail(icon: Icons.location_on_outlined, text: event.location!),
            if (event.timeZoneId != null)
              _Detail(icon: Icons.public, text: event.timeZoneId!),
            if (event.attendees.isNotEmpty)
              _Detail(
                icon: Icons.people_outline,
                text: event.attendees.map((a) => a.name).join(', '),
              ),
            if (event.notes != null && event.notes!.isNotEmpty)
              _Detail(icon: Icons.notes, text: event.notes!),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(EventDetailsAction.delete),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(EventDetailsAction.edit),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
