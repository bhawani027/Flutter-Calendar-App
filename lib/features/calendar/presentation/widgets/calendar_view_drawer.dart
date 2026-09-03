import 'package:flutter/material.dart';

import '../cubit/calendar_cubit.dart';

/// Switches the calendar between its four views.
///
/// The old drawer pushed a whole new screen per view; this just changes state
/// on the one calendar that is already on screen.
class CalendarViewDrawer extends StatelessWidget {
  const CalendarViewDrawer({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final CalendarViewType current;
  final ValueChanged<CalendarViewType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Views',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            for (final view in CalendarViewType.values)
              ListTile(
                leading: Icon(view.icon),
                title: Text(view.label),
                selected: view == current,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(view);
                },
              ),
          ],
        ),
      ),
    );
  }
}
