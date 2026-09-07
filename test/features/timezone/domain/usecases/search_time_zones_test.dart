import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/timezone/domain/entities/time_zone_option.dart';
import 'package:mycalendar_app/features/timezone/domain/usecases/search_time_zones.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTimeZoneRepository repository;
  late SearchTimeZones useCase;

  const kathmandu = TimeZoneOption(
    id: 'Asia/Kathmandu',
    offset: Duration(hours: 5, minutes: 45),
    abbreviation: '+0545',
  );
  const london = TimeZoneOption(
    id: 'Europe/London',
    offset: Duration(hours: 1),
    abbreviation: 'BST',
  );

  setUp(() {
    repository = MockTimeZoneRepository();
    useCase = SearchTimeZones(repository);
    when(
      repository.getAll,
    ).thenAnswer((_) async => const Right([kathmandu, london]));
  });

  test('an empty query returns every zone', () async {
    final result = await useCase('');

    expect(result.getRight().toNullable(), [kathmandu, london]);
  });

  test('a whitespace-only query is treated as empty', () async {
    final result = await useCase('   ');

    expect(result.getRight().toNullable(), hasLength(2));
  });

  test('matches on a substring, ignoring case', () async {
    final result = await useCase('kath');

    expect(result.getRight().toNullable(), [kathmandu]);
  });

  test('matches the region half of the id too', () async {
    final result = await useCase('europe');

    expect(result.getRight().toNullable(), [london]);
  });

  test('returns nothing when no zone matches', () async {
    final result = await useCase('atlantis');

    expect(result.getRight().toNullable(), isEmpty);
  });

  test('propagates a repository failure', () async {
    when(
      repository.getAll,
    ).thenAnswer((_) async => const Left(TimeZoneFailure()));

    final result = await useCase('kath');

    expect(result.getLeft().toNullable(), isA<TimeZoneFailure>());
  });
}
