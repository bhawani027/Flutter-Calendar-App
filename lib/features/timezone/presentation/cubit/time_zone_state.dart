part of 'time_zone_cubit.dart';

class TimeZoneState extends Equatable {
  const TimeZoneState({
    this.status = LoadStatus.initial,
    this.zones = const [],
    this.query = '',
    this.errorMessage,
  });

  final LoadStatus status;
  final List<TimeZoneOption> zones;
  final String query;
  final String? errorMessage;

  TimeZoneState copyWith({
    LoadStatus? status,
    List<TimeZoneOption>? zones,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TimeZoneState(
      status: status ?? this.status,
      zones: zones ?? this.zones,
      query: query ?? this.query,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, zones, query, errorMessage];
}
