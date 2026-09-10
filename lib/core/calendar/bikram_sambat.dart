import 'package:nepali_utils/nepali_utils.dart';

/// Bikram Sambat (BS) ↔ Gregorian (AD) conversion.
///
/// BS month lengths do not follow a formula — they come from published
/// astronomical data — so the table inside `nepali_utils` is the authority and
/// nothing about the calendar itself is restated here.
///
/// Only one direction of that package is used directly, though. Its BS → AD
/// conversion is pure integer arithmetic: it never consults a time zone, and it
/// is contiguous across the whole table (each successive BS day lands on the
/// next AD day), which makes it a bijection on calendar days. Its AD → BS
/// conversion is not usable: it measures the gap from its epoch with
/// `Duration.inDays` over *local* `DateTime`s, so in any zone whose UTC offset
/// has ever moved — every zone with DST — the truncation loses a day and the
/// result is off. Measured over 1970–2090 it lands on the wrong BS date for
/// 27,440 days in `America/Los_Angeles` and 44,194 in `Pacific/Auckland`.
///
/// [fromGregorian] therefore inverts [toGregorian] rather than calling that
/// direction, indexing whole UTC days — which have no offset to drift — and
/// memoising one BS year at a time.
abstract final class BikramSambat {
  /// The first BS year the underlying table covers.
  static const int minYear = 1970;

  /// The last BS year [fromGregorian] reports. The table reaches 2250, but the
  /// year search reads the following year's start, so it stops one short.
  static const int maxYear = 2249;

  /// BS year → the UTC day index of the 1st of each month, with the start of
  /// the next year in the trailing slot.
  static final Map<int, List<int>> _monthStarts = {};

  /// The whole-day index of [date], read as a calendar date: the time and the
  /// zone are dropped, so the result cannot drift with a UTC offset.
  ///
  /// Every value is an exact multiple of a day, so the truncating division is
  /// exact for pre-epoch dates too.
  static int _dayIndex(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  static List<int> _startsOf(int year) => _monthStarts.putIfAbsent(year, () {
    var day = _dayIndex(NepaliDateTime(year, 1, 1).toDateTime());
    final starts = <int>[day];
    for (var month = 1; month <= 12; month++) {
      day += NepaliDateTime(year, month, 1).totalDays;
      starts.add(day);
    }
    return starts;
  });

  /// The BS date [date] falls on, or null when it sits outside the table.
  ///
  /// Callers that render a date they did not choose should prefer this and fall
  /// back to showing AD alone, rather than risk throwing during a build.
  static NepaliDateTime? tryFromGregorian(DateTime date) {
    final target = _dayIndex(date);
    if (target < _startsOf(minYear).first ||
        target >= _startsOf(maxYear).last) {
      return null;
    }

    // BS leads AD by 56 or 57 years, so this guess is at most one year out.
    var year = (date.year + 56).clamp(minYear, maxYear);
    while (_startsOf(year).first > target) {
      year--;
    }
    while (_startsOf(year).last <= target) {
      year++;
    }

    final starts = _startsOf(year);
    var month = 1;
    while (month < 12 && starts[month] <= target) {
      month++;
    }
    return NepaliDateTime(year, month, target - starts[month - 1] + 1);
  }

  /// The BS date [date] falls on.
  ///
  /// Throws when [date] is outside the table; use [tryFromGregorian] where that
  /// is a possibility.
  static NepaliDateTime fromGregorian(DateTime date) {
    final converted = tryFromGregorian(date);
    if (converted == null) {
      throw ArgumentError.value(
        date,
        'date',
        'outside the BS calendar table (BS $minYear–$maxYear)',
      );
    }
    return converted;
  }

  /// The AD date [date] falls on, keeping its time of day.
  static DateTime toGregorian(NepaliDateTime date) => date.toDateTime();

  /// How many days BS [month] of [year] has — 29 to 32, depending on the year.
  static int daysInMonth(int year, int month) =>
      NepaliDateTime(year, month, 1).totalDays;

  /// Whether [date] can be shown in BS at all.
  static bool covers(DateTime date) => tryFromGregorian(date) != null;

  /// The BS month that owns most of AD [month] in [year], as its 1st.
  ///
  /// A Gregorian month always straddles exactly two BS months, so a page
  /// anchored to one has to pick the one it is mostly in. September 2026 runs
  /// Bhadra 16–31 and then Asoj 1–14, so it reads as Bhadra. A tie goes to the
  /// earlier month, which keeps the label from jumping around mid-month.
  static NepaliDateTime? tryDominantMonth(int year, int month) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final first = tryFromGregorian(DateTime(year, month, 1));
    final last = tryFromGregorian(DateTime(year, month, lastDayOfMonth));
    if (first == null || last == null) return null;

    if (first.year == last.year && first.month == last.month) {
      return NepaliDateTime(first.year, first.month);
    }
    final daysOwnedByFirst =
        daysInMonth(first.year, first.month) - first.day + 1;
    return daysOwnedByFirst * 2 >= lastDayOfMonth
        ? NepaliDateTime(first.year, first.month)
        : NepaliDateTime(last.year, last.month);
  }
}
