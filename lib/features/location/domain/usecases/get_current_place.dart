import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../repositories/location_repository.dart';

class GetCurrentPlace implements UseCase<Place, NoParams> {
  const GetCurrentPlace(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, Place>> call(NoParams params) =>
      _repository.getCurrentPlace();
}
