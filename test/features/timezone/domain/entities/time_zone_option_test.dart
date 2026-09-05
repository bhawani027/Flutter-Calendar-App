import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/timezone/domain/entities/time_zone_option.dart';

void main() {
  TimeZoneOption zoneAt(Duration offset) =>
      TimeZoneOption(id: 'Test/Zone', offset: offset, abbreviation: 'TST');

  group('formattedOffset', () {
    test('pads hours and minutes to two digits', () {
      expect(zoneAt(const Duration(hours: 1)).formattedOffset, 'UTC+01:00');
    });

    test('renders a 45-minute offset like Kathmandu', () {
      expect(
        zoneAt(const Duration(hours: 5, minutes: 45)).formattedOffset,
        'UTC+05:45',
      );
    });

    test('renders UTC itself without a sign quirk', () {
      expect(zoneAt(Duration.zero).formattedOffset, 'UTC+00:00');
    });

    test('renders negative offsets with the minutes still positive', () {
      expect(
        zoneAt(const Duration(hours: -3, minutes: -30)).formattedOffset,
        'UTC-03:30',
      );
    });

    test('handles offsets past 12 hours', () {
      expect(
        zoneAt(const Duration(hours: 14)).formattedOffset,
        'UTC+14:00',
      );
    });
  });
}
