import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/calendar/bikram_sambat.dart';
import '../../../../core/calendar/nepali_date_labels.dart';

/// The selected day, spelled out in both calendars.
///
/// The month grid only has room for two numbers per cell, so this is where the
/// selection is named in full — `भाद्र २४, २०८३` over `September 9, 2026`. Both
/// readings come off the same [date], so they cannot drift apart.
///
/// The two halves sit side by side where the width allows and stack when it
/// does not, which keeps a long Nepali month name from squeezing the Gregorian
/// date off a narrow screen.
class DualDateStrip extends StatelessWidget {
  const DualDateStrip({required this.date, super.key});

  static final DateFormat _adFullDate = DateFormat('MMMM d, yyyy');

  /// Below this the two readings stack instead of sharing a line.
  static const double _sideBySideWidth = 480;

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bsDate = BikramSambat.tryFromGregorian(date);

    return Container(
      width: double.infinity,
      color: colors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pairs = <Widget>[
            // Outside the BS table only the Gregorian date is shown, rather
            // than an empty label where the BS one would be.
            if (bsDate != null)
              _DatePair(
                system: 'BS',
                value: NepaliDateLabels.fullDate(bsDate),
                style: AppTheme.nepali(
                  theme.textTheme.titleSmall,
                ).copyWith(color: colors.onSurface),
              ),
            _DatePair(
              system: 'AD',
              value: _adFullDate.format(date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ];

          // Phone widths stack the two readings; a tablet has room for one
          // line.
          if (constraints.maxWidth < _sideBySideWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: pairs,
            );
          }
          // Flexible rather than Expanded: each half takes only the width it
          // needs, so the two readings stay next to each other instead of
          // being pushed to opposite ends of a tablet, while still giving way
          // before they could overflow.
          return Row(
            children: [
              for (final pair in pairs) ...[
                Flexible(child: pair),
                const SizedBox(width: 24),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DatePair extends StatelessWidget {
  const _DatePair({
    required this.system,
    required this.value,
    required this.style,
  });

  final String system;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$system:',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        // Flexible so a long Nepali month name ellipsizes rather than
        // overflowing the strip on the narrowest supported screen.
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
