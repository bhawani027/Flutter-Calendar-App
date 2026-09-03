/// Low-level errors thrown by the data layer.
///
/// Data sources throw these; repositories catch them and translate them into
/// [Failure]s so that the domain layer never sees an exception.
class CacheException implements Exception {
  const CacheException(this.message);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}

class LocationPermissionException implements Exception {
  const LocationPermissionException(this.message);

  final String message;

  @override
  String toString() => 'LocationPermissionException: $message';
}

class TimeZoneException implements Exception {
  const TimeZoneException(this.message);

  final String message;

  @override
  String toString() => 'TimeZoneException: $message';
}
