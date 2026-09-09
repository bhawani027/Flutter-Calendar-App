import 'package:equatable/equatable.dart';

/// The domain-layer representation of something going wrong.
///
/// Everything that crosses a repository boundary is an `Either<Failure, T>`,
/// so callers handle errors as values instead of catching exceptions.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read or write local data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Could not determine your location.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Location permission was denied.']);
}

class TimeZoneFailure extends Failure {
  const TimeZoneFailure([super.message = 'Could not load time zones.']);
}
