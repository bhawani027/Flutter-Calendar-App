import 'package:timezone/timezone.dart' as tz;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/time_zone_option.dart';

abstract interface class TimeZoneDataSource {
  List<TimeZoneOption> loadAll();
}

/// Reads the zone list out of the bundled IANA database.
///
/// Assumes `tz.initializeTimeZones()` has already run — see `main.dart`.
class TzDatabaseDataSource implements TimeZoneDataSource {
  const TzDatabaseDataSource();

  @override
  List<TimeZoneOption> loadAll() {
    try {
      final now = DateTime.now();
      return tz.timeZoneDatabase.locations.keys.map((id) {
        final location = tz.getLocation(id);
        final localNow = tz.TZDateTime.from(now, location);
        return TimeZoneOption(
          id: id,
          offset: localNow.timeZoneOffset,
          abbreviation: localNow.timeZoneName,
        );
      }).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
    } catch (error) {
      throw TimeZoneException('Failed to load the time zone database: $error');
    }
  }
}
