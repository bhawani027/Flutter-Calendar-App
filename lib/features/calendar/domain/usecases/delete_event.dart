import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/event_repository.dart';

class DeleteEvent implements UseCase<Unit, String> {
  const DeleteEvent(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String params) =>
      _repository.deleteEvent(params);
}
