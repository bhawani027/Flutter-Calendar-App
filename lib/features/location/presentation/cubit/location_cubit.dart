import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/get_current_place.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._getCurrentPlace) : super(const LocationState());

  final GetCurrentPlace _getCurrentPlace;

  Future<void> locate() async {
    emit(const LocationState(status: LocationStatus.loading));
    final result = await _getCurrentPlace(const NoParams());
    result.match(
      (failure) => emit(
        LocationState(
          status: LocationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (place) => emit(
        LocationState(status: LocationStatus.ready, place: place),
      ),
    );
  }
}
