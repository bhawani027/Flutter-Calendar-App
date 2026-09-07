import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/exceptions.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/timezone/data/repositories/time_zone_repository_impl.dart';
import 'package:mycalendar_app/features/timezone/domain/entities/time_zone_option.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTimeZoneDataSource dataSource;
  late TimeZoneRepositoryImpl repository;

  const kathmandu = TimeZoneOption(
    id: 'Asia/Kathmandu',
    offset: Duration(hours: 5, minutes: 45),
    abbreviation: '+0545',
  );

  setUp(() {
    dataSource = MockTimeZoneDataSource();
    repository = TimeZoneRepositoryImpl(dataSource);
  });

  test('returns the zones the data source loaded', () async {
    when(dataSource.loadAll).thenReturn([kathmandu]);

    final result = await repository.getAll();

    expect(result.getRight().toNullable(), [kathmandu]);
  });

  test('reads the database once and reuses it', () async {
    when(dataSource.loadAll).thenReturn([kathmandu]);

    await repository.getAll();
    await repository.getAll();
    await repository.getAll();

    verify(dataSource.loadAll).called(1);
  });

  test('turns a TimeZoneException into a TimeZoneFailure', () async {
    when(dataSource.loadAll).thenThrow(const TimeZoneException('no db'));

    final result = await repository.getAll();

    expect(result.getLeft().toNullable(), const TimeZoneFailure('no db'));
  });
}
