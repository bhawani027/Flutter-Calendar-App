import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/time_zone_option.dart';
import '../../domain/repositories/time_zone_repository.dart';
import '../datasources/time_zone_data_source.dart';

class TimeZoneRepositoryImpl implements TimeZoneRepository {
  TimeZoneRepositoryImpl(this._dataSource);

  final TimeZoneDataSource _dataSource;

  /// The zone list is static for a run, so it is read once and reused.
  List<TimeZoneOption>? _cache;

  @override
  Future<Either<Failure, List<TimeZoneOption>>> search(String query) async {
    try {
      final all = _cache ??= _dataSource.loadAll();
      final needle = query.trim().toLowerCase();
      if (needle.isEmpty) return Right(all);
      return Right(
        all
            .where((zone) => zone.id.toLowerCase().contains(needle))
            .toList(growable: false),
      );
    } on TimeZoneException catch (error) {
      return Left(TimeZoneFailure(error.message));
    }
  }
}
