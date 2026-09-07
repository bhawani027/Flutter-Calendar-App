import 'package:flutter/material.dart';

import '../cubit/calendar_cubit.dart';

/// The Day / Week / Month / Schedule switcher.
///
/// Lives in the app bar rather than behind a drawer, matching Google Calendar
/// and Outlook, where changing view is one tap from the calendar itself.
class CalendarViewMenu extends StatelessWidget {
  const CalendarViewMenu({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final CalendarViewType current;
  final ValueChanged<CalendarViewType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CalendarViewType>(
      icon: Icon(current.icon),
      tooltip: 'Change view',
      initialValue: current,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final view in CalendarViewType.values)
          PopupMenuItem(
            value: view,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(view.icon),
              title: Text(view.label),
              trailing: view == current ? const Icon(Icons.check) : null,
            ),
          ),
      ],
    );
  }
}
