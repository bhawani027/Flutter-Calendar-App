import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/time_zone_option.dart';
import '../../domain/usecases/search_time_zones.dart';

part 'time_zone_state.dart';

class TimeZoneCubit extends Cubit<TimeZoneState> {
  TimeZoneCubit(this._searchTimeZones) : super(const TimeZoneState());

  final SearchTimeZones _searchTimeZones;

  Future<void> search([String query = '']) async {
    emit(state.copyWith(status: TimeZoneStatus.loading, query: query));
    final result = await _searchTimeZones(query);
    result.match(
      (failure) => emit(
        state.copyWith(
          status: TimeZoneStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (zones) => emit(
        state.copyWith(status: TimeZoneStatus.ready, zones: zones),
      ),
    );
  }
}
