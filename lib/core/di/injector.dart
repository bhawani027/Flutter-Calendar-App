import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/calendar/data/datasources/event_local_data_source.dart';
import '../../features/calendar/data/repositories/event_repository_impl.dart';
import '../../features/calendar/domain/repositories/event_repository.dart';
import '../../features/calendar/domain/usecases/create_event.dart';
import '../../features/calendar/domain/usecases/delete_event.dart';
import '../../features/calendar/domain/usecases/update_event.dart';
import '../../features/calendar/domain/usecases/watch_events.dart';
import '../../features/calendar/presentation/cubit/calendar_cubit.dart';
import '../../features/location/data/datasources/device_location_data_source.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_place.dart';
import '../../features/location/presentation/cubit/location_cubit.dart';
import '../../features/timezone/data/datasources/time_zone_data_source.dart';
import '../../features/timezone/data/repositories/time_zone_repository_impl.dart';
import '../../features/timezone/domain/repositories/time_zone_repository.dart';
import '../../features/timezone/domain/usecases/search_time_zones.dart';
import '../../features/timezone/presentation/cubit/time_zone_cubit.dart';
import '../utils/id_generator.dart';

/// The service locator.
///
/// Wiring lives here so that every other file depends on abstractions only and
/// can be constructed with fakes in a test.
final GetIt sl = GetIt.instance;

/// Opens local storage and registers every dependency. Call once from `main`.
Future<void> configureDependencies() async {
  await Hive.initFlutter();

  final eventBox = await Hive.openBox<String>(HiveEventLocalDataSource.boxName);

  // ---- External -----------------------------------------------------------
  sl
    ..registerLazySingleton<Box<String>>(() => eventBox)
    ..registerLazySingleton<IdGenerator>(() => const UuidIdGenerator(Uuid()));

  // ---- Data sources -------------------------------------------------------
  sl
    ..registerLazySingleton<EventLocalDataSource>(
      () => HiveEventLocalDataSource(sl()),
    )
    ..registerLazySingleton<TimeZoneDataSource>(TzDatabaseDataSource.new)
    ..registerLazySingleton<DeviceLocationDataSource>(
      () => const GeolocatorLocationDataSource(),
    );

  // ---- Repositories -------------------------------------------------------
  sl
    ..registerLazySingleton<EventRepository>(() => EventRepositoryImpl(sl()))
    ..registerLazySingleton<TimeZoneRepository>(
      () => TimeZoneRepositoryImpl(sl()),
    )
    ..registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(sl()),
    );

  // ---- Use cases ----------------------------------------------------------
  sl
    ..registerLazySingleton(() => WatchEvents(sl()))
    ..registerLazySingleton(() => CreateEvent(sl(), sl()))
    ..registerLazySingleton(() => UpdateEvent(sl()))
    ..registerLazySingleton(() => DeleteEvent(sl()))
    ..registerLazySingleton(() => SearchTimeZones(sl()))
    ..registerLazySingleton(() => GetCurrentPlace(sl()));

  // ---- Cubits -------------------------------------------------------------
  // Registered as factories: each screen gets its own instance.
  sl
    ..registerFactory(() => CalendarCubit(watchEvents: sl(), deleteEvent: sl()))
    ..registerFactory(() => TimeZoneCubit(sl()))
    ..registerFactory(() => LocationCubit(sl()));
}
