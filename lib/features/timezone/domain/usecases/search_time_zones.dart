import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/time_zone_option.dart';
import '../repositories/time_zone_repository.dart';

/// Finds the zones whose id contains [params]; an empty query returns all.
///
/// The matching rule lives here rather than in the repository, so that "how
/// searching works" sits in the domain like the calendar's rules do.
class SearchTimeZones implements UseCase<List<TimeZoneOption>, String> {
  const SearchTimeZones(this._repository);

  final TimeZoneRepository _repository;

  @override
  Future<Either<Failure, List<TimeZoneOption>>> call(String params) async {
    final result = await _repository.getAll();
    final needle = params.trim().toLowerCase();
    if (needle.isEmpty) return result;

    return result.map(
      (zones) => zones
          .where((zone) => zone.id.toLowerCase().contains(needle))
          .toList(growable: false),
    );
  }
}
