import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/time_zone_option.dart';

abstract interface class TimeZoneRepository {
  /// All known zones whose id matches [query] (empty query returns everything).
  Future<Either<Failure, List<TimeZoneOption>>> search(String query);
}
