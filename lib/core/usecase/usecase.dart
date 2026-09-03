import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// A single application operation.
///
/// Use cases are the only thing the presentation layer is allowed to call, and
/// each one does exactly one job. `Right` is success, `Left` is a [Failure].
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// A use case that exposes a continuously updating result.
abstract interface class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Marker for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
