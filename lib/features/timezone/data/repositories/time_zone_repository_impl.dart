import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/time_zone_option.dart';
import '../../domain/repositories/time_zone_repository.dart';
import '../datasources/time_zone_data_source.dart';

class TimeZoneRepositoryImpl implements TimeZoneRepository {
  TimeZoneRepositoryImpl(this._dataSource);

  final TimeZoneDataSource _dataSource;

  /// The zone list is static for a run, so it is built once and reused.
  List<TimeZoneOption>? _cache;

  @override
  Future<Either<Failure, List<TimeZoneOption>>> getAll() async {
    try {
      return Right(_cache ??= _dataSource.loadAll());
    } on TimeZoneException catch (error) {
      return Left(TimeZoneFailure(error.message));
    }
  }
}
