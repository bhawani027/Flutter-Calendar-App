import 'package:timezone/data/latest.dart' as tz_data;

/// The IANA time zone database, loaded at most once.
///
/// It is ~600 zones, so it is not loaded during startup. Both the time zone
/// picker and the calendar (which needs it to place an event that carries a
/// zone) call [ensureInitialized] before their first lookup.
abstract final class TimeZoneDb {
  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }
}
