import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/core/presentation/day_status.dart';

void main() {
  final now = DateTime(2026, 9, 3, 14, 30);

  test('a date before today is past', () {
    expect(DayStatus.of(DateTime(2026, 9, 2), now: now), DayStatus.past);
  });

  test('a date after today is upcoming', () {
    expect(DayStatus.of(DateTime(2026, 9, 4), now: now), DayStatus.upcoming);
  });

  // Classification is by calendar day, so this morning is still "today".
  test('any time on the same day is today', () {
    expect(DayStatus.of(DateTime(2026, 9, 3), now: now), DayStatus.today);
    expect(
      DayStatus.of(DateTime(2026, 9, 3, 23, 59), now: now),
      DayStatus.today,
    );
  });

  test('crossing a month or year boundary still compares by day', () {
    final newYearsEve = DateTime(2026, 12, 31, 23, 59);
    expect(
      DayStatus.of(DateTime(2027, 1, 1), now: newYearsEve),
      DayStatus.upcoming,
    );
    expect(
      DayStatus.of(DateTime(2026, 12, 31), now: newYearsEve),
      DayStatus.today,
    );
  });
}
