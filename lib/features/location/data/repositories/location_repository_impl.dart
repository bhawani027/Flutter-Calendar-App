import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/device_location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final DeviceLocationDataSource _dataSource;

  @override
  Future<Either<Failure, Place>> getCurrentPlace() async {
    try {
      return Right(await _dataSource.getCurrentPlace());
    } on LocationPermissionException catch (error) {
      return Left(PermissionFailure(error.message));
    } on LocationServiceException catch (error) {
      return Left(LocationFailure(error.message));
    }
  }
}
