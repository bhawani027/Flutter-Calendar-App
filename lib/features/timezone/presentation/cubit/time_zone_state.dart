part of 'time_zone_cubit.dart';

enum TimeZoneStatus { initial, loading, ready, failure }

class TimeZoneState extends Equatable {
  const TimeZoneState({
    this.status = TimeZoneStatus.initial,
    this.zones = const [],
    this.query = '',
    this.errorMessage,
  });

  final TimeZoneStatus status;
  final List<TimeZoneOption> zones;
  final String query;
  final String? errorMessage;

  TimeZoneState copyWith({
    TimeZoneStatus? status,
    List<TimeZoneOption>? zones,
    String? query,
    String? errorMessage,
  }) {
    return TimeZoneState(
      status: status ?? this.status,
      zones: zones ?? this.zones,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, zones, query, errorMessage];
}
