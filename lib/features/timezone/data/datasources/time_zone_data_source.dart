import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/time_zone_option.dart';

abstract interface class TimeZoneDataSource {
  List<TimeZoneOption> loadAll();
}

/// Reads the zone list out of the bundled IANA database.
///
/// The database is initialised on first use rather than at app startup — it is
/// ~600 zones that only the time zone picker ever needs, so loading it during
/// `main` delayed the first frame for a screen most sessions never open.
class TzDatabaseDataSource implements TimeZoneDataSource {
  TzDatabaseDataSource();

  static bool _initialised = false;

  @override
  List<TimeZoneOption> loadAll() {
    try {
      if (!_initialised) {
        tz_data.initializeTimeZones();
        _initialised = true;
      }

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
