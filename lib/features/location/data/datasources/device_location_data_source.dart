import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/place.dart';

abstract interface class DeviceLocationDataSource {
  Future<Place> getCurrentPlace();
}

/// Wraps geolocator/geocoding so the plugin APIs stay out of the rest of the app.
///
/// The original screen requested a position without ever requesting permission
/// when it was denied; the full permission ladder is handled here.
class GeolocatorLocationDataSource implements DeviceLocationDataSource {
  const GeolocatorLocationDataSource();

  @override
  Future<Place> getCurrentPlace() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException(
        'Location services are turned off on this device.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'This app needs location permission to find where you are.',
      );
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (error) {
      throw LocationServiceException('Could not read your position: $error');
    }

    return Place(
      latitude: position.latitude,
      longitude: position.longitude,
      address: await _reverseGeocode(position),
    );
  }

  /// Best-effort: a missing address is not worth failing the whole lookup over.
  Future<String?> _reverseGeocode(Position position) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return null;
      final placemark = placemarks.first;
      final parts = <String?>[
        placemark.name,
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ].whereType<String>().where((part) => part.isNotEmpty).toList();
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
