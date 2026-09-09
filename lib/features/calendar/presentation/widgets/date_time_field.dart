import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/calendar/bikram_sambat.dart';
import '../../../../core/calendar/nepali_date_labels.dart';

/// A date button and a time button on one row, as used for the event's start
/// and end. Hides the time half when the event is all-day.
///
/// The button carries the Bikram Sambat date under the Gregorian one, so a
/// date picked here can be read in either calendar. Only the display is dual:
/// [value] and [onDateChanged] stay Gregorian, which is what the event itself
/// is stored in.
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
              child: _DateLabel(value: value),
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

/// The Gregorian date with its BS reading beneath.
class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.value});

  final DateTime value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bsDate = BikramSambat.tryFromGregorian(value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateTimeField._dateFormat.format(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (bsDate != null)
          Text(
            NepaliDateLabels.fullDate(bsDate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.nepali(
              theme.textTheme.labelSmall,
            ).copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }
}
