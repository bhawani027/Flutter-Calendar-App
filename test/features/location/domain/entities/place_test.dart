import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/location/domain/entities/place.dart';

void main() {
  test('coordinates are rendered to five decimal places', () {
    const place = Place(latitude: 27.7172, longitude: 85.324);

    expect(place.coordinates, '27.71720, 85.32400');
  });

  test('displayName prefers the address when one was resolved', () {
    const place = Place(
      latitude: 27.7172,
      longitude: 85.324,
      address: 'Kathmandu, Nepal',
    );

    expect(place.displayName, 'Kathmandu, Nepal');
  });

  test('displayName falls back to coordinates without an address', () {
    const place = Place(latitude: 27.7172, longitude: 85.324);

    expect(place.displayName, place.coordinates);
  });
}
