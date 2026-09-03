import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/time_zone_option.dart';
import '../repositories/time_zone_repository.dart';

class SearchTimeZones implements UseCase<List<TimeZoneOption>, String> {
  const SearchTimeZones(this._repository);

  final TimeZoneRepository _repository;

  @override
  Future<Either<Failure, List<TimeZoneOption>>> call(String params) =>
      _repository.search(params);
}
