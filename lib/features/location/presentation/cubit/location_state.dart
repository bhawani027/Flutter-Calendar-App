part of 'location_cubit.dart';

class LocationState extends Equatable {
  const LocationState({
    this.status = LoadStatus.initial,
    this.place,
    this.errorMessage,
  });

  final LoadStatus status;
  final Place? place;
  final String? errorMessage;

  bool get isLoading => status == LoadStatus.loading;

  LocationState copyWith({
    LoadStatus? status,
    Place? place,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      place: place ?? this.place,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, place, errorMessage];
}
