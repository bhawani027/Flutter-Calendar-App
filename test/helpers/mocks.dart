import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/usecase/usecase.dart';
import 'package:mycalendar_app/features/calendar/data/datasources/event_local_data_source.dart';
import 'package:mycalendar_app/features/calendar/domain/repositories/event_repository.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/create_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/delete_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/update_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/watch_events.dart';

import 'fixtures.dart';

class MockEventRepository extends Mock implements EventRepository {}

class MockEventLocalDataSource extends Mock implements EventLocalDataSource {}

class MockWatchEvents extends Mock implements WatchEvents {}

class MockCreateEvent extends Mock implements CreateEvent {}

class MockUpdateEvent extends Mock implements UpdateEvent {}

class MockDeleteEvent extends Mock implements DeleteEvent {}

/// Registers the fallbacks every suite needs for `any()` matchers.
void registerCommonFallbacks() {
  registerFallbackValue(buildEvent());
  registerFallbackValue(const NoParams());
}
