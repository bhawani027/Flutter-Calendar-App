part of 'location_cubit.dart';

enum LocationStatus { initial, loading, ready, failure }

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.place,
    this.errorMessage,
  });

  final LocationStatus status;
  final Place? place;
  final String? errorMessage;

  bool get isLoading => status == LocationStatus.loading;

  @override
  List<Object?> get props => [status, place, errorMessage];
}
