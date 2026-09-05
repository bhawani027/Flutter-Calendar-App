import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/usecase/usecase.dart';
import 'package:mycalendar_app/features/calendar/data/datasources/event_local_data_source.dart';
import 'package:mycalendar_app/features/calendar/domain/repositories/event_repository.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/create_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/delete_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/update_event.dart';
import 'package:mycalendar_app/features/calendar/domain/usecases/watch_events.dart';
import 'package:mycalendar_app/features/location/data/datasources/device_location_data_source.dart';
import 'package:mycalendar_app/features/location/domain/usecases/get_current_place.dart';
import 'package:mycalendar_app/features/timezone/data/datasources/time_zone_data_source.dart';
import 'package:mycalendar_app/features/timezone/domain/repositories/time_zone_repository.dart';
import 'package:mycalendar_app/features/timezone/domain/usecases/search_time_zones.dart';

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

class MockTimeZoneDataSource extends Mock implements TimeZoneDataSource {}

class MockTimeZoneRepository extends Mock implements TimeZoneRepository {}

class MockSearchTimeZones extends Mock implements SearchTimeZones {}

class MockDeviceLocationDataSource extends Mock
    implements DeviceLocationDataSource {}

class MockGetCurrentPlace extends Mock implements GetCurrentPlace {}
