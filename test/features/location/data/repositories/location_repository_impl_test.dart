import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/exceptions.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/location/data/repositories/location_repository_impl.dart';
import 'package:mycalendar_app/features/location/domain/entities/place.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDeviceLocationDataSource dataSource;
  late LocationRepositoryImpl repository;

  const place = Place(latitude: 27.7172, longitude: 85.324, address: 'KTM');

  setUp(() {
    dataSource = MockDeviceLocationDataSource();
    repository = LocationRepositoryImpl(dataSource);
  });

  test('returns the place the data source resolved', () async {
    when(dataSource.getCurrentPlace).thenAnswer((_) async => place);

    final result = await repository.getCurrentPlace();

    expect(result.getRight().toNullable(), place);
  });

  // The two device problems are distinguished so the UI can tell the user to
  // grant permission rather than to turn location services on.
  test('a denied permission becomes a PermissionFailure', () async {
    when(
      dataSource.getCurrentPlace,
    ).thenThrow(const LocationPermissionException('denied'));

    final result = await repository.getCurrentPlace();

    expect(result.getLeft().toNullable(), const PermissionFailure('denied'));
  });

  test('a disabled location service becomes a LocationFailure', () async {
    when(
      dataSource.getCurrentPlace,
    ).thenThrow(const LocationServiceException('services off'));

    final result = await repository.getCurrentPlace();

    expect(
      result.getLeft().toNullable(),
      const LocationFailure('services off'),
    );
  });
}
