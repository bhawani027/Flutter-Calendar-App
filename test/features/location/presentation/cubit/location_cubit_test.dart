import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/core/presentation/load_status.dart';
import 'package:mycalendar_app/features/location/domain/entities/place.dart';
import 'package:mycalendar_app/features/location/presentation/cubit/location_cubit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetCurrentPlace getCurrentPlace;

  const place = Place(latitude: 27.7172, longitude: 85.324, address: 'KTM');

  setUpAll(registerCommonFallbacks);

  setUp(() {
    getCurrentPlace = MockGetCurrentPlace();
    when(() => getCurrentPlace(any()))
        .thenAnswer((_) async => const Right(place));
  });

  LocationCubit build() => LocationCubit(getCurrentPlace);

  blocTest<LocationCubit, LocationState>(
    'locate goes loading then ready with the place',
    build: build,
    act: (cubit) => cubit.locate(),
    expect: () => [
      const LocationState(status: LoadStatus.loading),
      const LocationState(status: LoadStatus.ready, place: place),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'a permission failure is surfaced as a message',
    setUp: () => when(() => getCurrentPlace(any()))
        .thenAnswer((_) async => const Left(PermissionFailure('denied'))),
    build: build,
    act: (cubit) => cubit.locate(),
    expect: () => [
      const LocationState(status: LoadStatus.loading),
      const LocationState(
        status: LoadStatus.failure,
        errorMessage: 'denied',
      ),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'retrying after a failure clears the error',
    build: build,
    seed: () => const LocationState(
      status: LoadStatus.failure,
      errorMessage: 'denied',
    ),
    act: (cubit) => cubit.locate(),
    verify: (cubit) => expect(cubit.state.errorMessage, isNull),
  );
}
