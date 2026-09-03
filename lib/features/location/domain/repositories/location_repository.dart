import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/place.dart';

abstract interface class LocationRepository {
  /// Resolves the device's current position, reverse-geocoded when possible.
  Future<Either<Failure, Place>> getCurrentPlace();
}
