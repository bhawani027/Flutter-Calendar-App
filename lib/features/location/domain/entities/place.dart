import 'package:equatable/equatable.dart';

/// A resolved position on the map, with a human-readable address when one
/// could be looked up.
class Place extends Equatable {
  const Place({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  String get coordinates =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  String get displayName => address ?? coordinates;

  @override
  List<Object?> get props => [latitude, longitude, address];
}
