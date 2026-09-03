import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Asks the user to pick an event colour. Resolves to the chosen ARGB value,
/// or null if dismissed.
Future<int?> showEventColorPicker(
  BuildContext context, {
  required int selectedValue,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Event colour'),
      children: [
        for (final entry in AppColors.eventPalette)
          ListTile(
            leading: Icon(
              entry.value == selectedValue ? Icons.lens : Icons.trip_origin,
              color: entry.color,
            ),
            title: Text(entry.name),
            onTap: () => Navigator.of(context).pop(entry.value),
          ),
      ],
    ),
  );
}
