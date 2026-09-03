import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A date button and a time button on one row, as used for the event's start
/// and end. Hides the time half when the event is all-day.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    required this.label,
    required this.value,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.showTime = true,
    super.key,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(int hour, int minute) onTimeChanged;
  final bool showTime;

  static final DateFormat _dateFormat = DateFormat('EEE, d MMM yyyy');

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onDateChanged(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked != null) onTimeChanged(picked.hour, picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickDate(context),
              child: Text(_dateFormat.format(value)),
            ),
          ),
          if (showTime) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 104,
              child: OutlinedButton(
                onPressed: () => _pickTime(context),
                child: Text(TimeOfDay.fromDateTime(value).format(context)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
