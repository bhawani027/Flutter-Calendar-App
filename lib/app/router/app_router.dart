import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../features/calendar/domain/entities/attendee.dart';
import '../../features/calendar/domain/entities/calendar_event.dart';
import '../../features/calendar/presentation/cubit/calendar_cubit.dart';
import '../../features/calendar/presentation/cubit/event_editor_cubit.dart';
import '../../features/calendar/presentation/pages/attendees_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/calendar/presentation/pages/event_editor_page.dart';
import '../../features/location/presentation/cubit/location_cubit.dart';
import '../../features/location/presentation/pages/location_picker_page.dart';
import '../../features/timezone/presentation/cubit/time_zone_cubit.dart';
import '../../features/timezone/presentation/pages/time_zone_picker_page.dart';

abstract final class AppRoutes {
  static const String calendar = '/';
  static const String eventEditor = '/event-editor';
  static const String attendees = '/attendees';
  static const String location = '/location';
  static const String timeZone = '/time-zone';
}

/// Arguments for [AppRoutes.eventEditor]: pass [event] to edit an existing one,
/// or [initialDate] to start a new event on that day.
class EventEditorArgs {
  const EventEditorArgs({this.initialDate, this.event});

  final DateTime? initialDate;
  final CalendarEvent? event;
}

/// Central route table.
///
/// Each route provides its own cubit, so pages never build their dependencies.
abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.calendar:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CalendarPage(),
        );

      case AppRoutes.eventEditor:
        final args = settings.arguments as EventEditorArgs? ??
            const EventEditorArgs();
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (calendarContext) => BlocProvider(
            create: (_) => EventEditorCubit(
              createEvent: sl(),
              updateEvent: sl(),
              existing: args.event,
              initialDate: args.initialDate,
            ),
            child: EventEditorPage(
              onDelete: (id) =>
                  calendarContext.read<CalendarCubit>().deleteEvent(id),
            ),
          ),
        );

      case AppRoutes.attendees:
        final attendees = settings.arguments as List<Attendee>? ?? const [];
        return MaterialPageRoute<List<Attendee>>(
          settings: settings,
          builder: (_) => AttendeesPage(attendees: attendees),
        );

      case AppRoutes.location:
        return MaterialPageRoute<Object?>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<LocationCubit>(),
            child: const LocationPickerPage(),
          ),
        );

      case AppRoutes.timeZone:
        return MaterialPageRoute<String>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<TimeZoneCubit>(),
            child: const TimeZonePickerPage(),
          ),
        );

      default:
        return null;
    }
  }
}
