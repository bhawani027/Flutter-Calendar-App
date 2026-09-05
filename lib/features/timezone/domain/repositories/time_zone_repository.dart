import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/time_zone_option.dart';

abstract interface class TimeZoneRepository {
  /// Every zone in the IANA database.
  Future<Either<Failure, List<TimeZoneOption>>> getAll();
}
