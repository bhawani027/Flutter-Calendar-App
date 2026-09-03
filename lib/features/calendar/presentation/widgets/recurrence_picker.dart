import 'package:flutter/material.dart';

import '../../domain/entities/recurrence_rule.dart';

/// Asks the user how often the event repeats.
Future<RecurrenceRule?> showRecurrencePicker(
  BuildContext context, {
  required RecurrenceRule selected,
}) {
  return showDialog<RecurrenceRule>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Repeat'),
      children: [
        for (final rule in RecurrenceRule.values)
          ListTile(
            title: Text(rule.label),
            selected: rule == selected,
            trailing: rule == selected ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(rule),
          ),
      ],
    ),
  );
}
