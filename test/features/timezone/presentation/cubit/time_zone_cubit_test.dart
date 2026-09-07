import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/core/presentation/load_status.dart';
import 'package:mycalendar_app/features/timezone/domain/entities/time_zone_option.dart';
import 'package:mycalendar_app/features/timezone/presentation/cubit/time_zone_cubit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSearchTimeZones searchTimeZones;

  const kathmandu = TimeZoneOption(
    id: 'Asia/Kathmandu',
    offset: Duration(hours: 5, minutes: 45),
    abbreviation: '+0545',
  );

  setUp(() {
    searchTimeZones = MockSearchTimeZones();
    when(() => searchTimeZones(any()))
        .thenAnswer((_) async => const Right([kathmandu]));
  });

  TimeZoneCubit build() => TimeZoneCubit(searchTimeZones);

  blocTest<TimeZoneCubit, TimeZoneState>(
    'search goes loading then ready, remembering the query',
    build: build,
    act: (cubit) => cubit.search('kath'),
    expect: () => [
      const TimeZoneState(status: LoadStatus.loading, query: 'kath'),
      const TimeZoneState(
        status: LoadStatus.ready,
        query: 'kath',
        zones: [kathmandu],
      ),
    ],
  );

  blocTest<TimeZoneCubit, TimeZoneState>(
    'search with no argument loads everything',
    build: build,
    act: (cubit) => cubit.search(),
    verify: (_) => verify(() => searchTimeZones('')).called(1),
  );

  blocTest<TimeZoneCubit, TimeZoneState>(
    'a failure is surfaced as a message',
    setUp: () => when(() => searchTimeZones(any()))
        .thenAnswer((_) async => const Left(TimeZoneFailure('no db'))),
    build: build,
    act: (cubit) => cubit.search('kath'),
    expect: () => [
      const TimeZoneState(status: LoadStatus.loading, query: 'kath'),
      const TimeZoneState(
        status: LoadStatus.failure,
        query: 'kath',
        errorMessage: 'no db',
      ),
    ],
  );

  blocTest<TimeZoneCubit, TimeZoneState>(
    'a later successful search clears the previous error',
    build: build,
    seed: () => const TimeZoneState(
      status: LoadStatus.failure,
      errorMessage: 'no db',
    ),
    act: (cubit) => cubit.search('kath'),
    verify: (cubit) => expect(cubit.state.errorMessage, isNull),
  );
}
