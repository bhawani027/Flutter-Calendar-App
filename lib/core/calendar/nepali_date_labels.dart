import 'package:nepali_utils/nepali_utils.dart';

/// Nepali-script labels for a BS date.
///
/// Every string the calendar shows in BS is built here, so the numerals and
/// month names stay consistent across the header, the month cells, the
/// selection strip and the event editor.
///
/// Two things about `NepaliDateFormat` shape this file:
///
/// A formatter is single-use. It consumes its own pattern as it walks it and
/// leaves the rendered text in place of it, so a second `format` call returns
/// the *first* date's string — every date in the month grid came out as
/// `भाद्र २९, २०८३` when these were cached in fields. Each call below therefore
/// builds its own, and none of them may be hoisted into a `static final`.
///
/// The language is also passed explicitly rather than left to `NepaliUtils()`,
/// whose language is global mutable state that any other screen could flip to
/// English.
abstract final class NepaliDateLabels {
  static String _format(String pattern, NepaliDateTime date) =>
      NepaliDateFormat(pattern, Language.nepali).format(date);

  /// The day of the month alone — `२४`.
  static String day(NepaliDateTime date) => _format('d', date);

  /// `भाद्र २०८३`.
  static String monthAndYear(NepaliDateTime date) => _format('MMMM yyyy', date);

  /// `भाद्र २४, २०८३`.
  static String fullDate(NepaliDateTime date) => _format('MMMM d, yyyy', date);

  /// `भाद्र २४`, for a range that already carries the year.
  static String dayAndMonth(NepaliDateTime date) => _format('MMMM d', date);

  /// `२०८३`.
  static String year(NepaliDateTime date) => _format('yyyy', date);
}
