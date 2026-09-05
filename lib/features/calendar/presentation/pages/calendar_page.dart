import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/presentation/error_snack_bar.dart';
import '../../domain/entities/calendar_event.dart';
import '../cubit/calendar_cubit.dart';
import '../widgets/calendar_view_drawer.dart';
import '../widgets/event_calendar_data_source.dart';

/// The single calendar screen.
///
/// Replaces `calendar.dart`, `dayview.dart`, `weekview.dart`, `monthview.dart`
/// and `schedule.dart`, which were five copies of the same widget tree.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController _controller = CalendarController();

  @override
  void initState() {
    super.initState();
    context.read<CalendarCubit>().start();
  }

  List<CalendarEvent>? _sourceEvents;
  EventCalendarDataSource? _dataSource;

  /// Rebuilds the Syncfusion adapter only when the event list actually
  /// changes, rather than on every frame.
  EventCalendarDataSource _dataSourceFor(List<CalendarEvent> events) {
    if (!identical(_sourceEvents, events) || _dataSource == null) {
      _sourceEvents = events;
      _dataSource = EventCalendarDataSource(events);
    }
    return _dataSource!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static CalendarView _toCalendarView(CalendarViewType type) => switch (type) {
        CalendarViewType.schedule => CalendarView.schedule,
        CalendarViewType.day => CalendarView.day,
        CalendarViewType.week => CalendarView.week,
        CalendarViewType.month => CalendarView.month,
      };

  Future<void> _openEditor({DateTime? date, CalendarEvent? event}) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.eventEditor,
      arguments: EventEditorArgs(initialDate: date, event: event),
    );
  }

  void _onTap(CalendarTapDetails details, List<CalendarEvent> events) {
    switch (details.targetElement) {
      case CalendarElement.calendarCell:
        _openEditor(date: details.date);
      case CalendarElement.appointment:
        final appointment = details.appointments?.firstOrNull;
        if (appointment is! Appointment) return;
        final match = events.where((e) => e.id == appointment.id).firstOrNull;
        if (match != null) _openEditor(event: match);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarCubit, CalendarState>(
      listenWhen: (previous, current) =>
          errorAppeared(previous.errorMessage, current.errorMessage),
      listener: (context, state) {
        showErrorSnackBar(context, state.errorMessage!);
        context.read<CalendarCubit>().clearError();
      },
      builder: (context, state) {
        _controller.view = _toCalendarView(state.view);
        return Scaffold(
          appBar: AppBar(title: Text('${state.view.label} view')),
          drawer: CalendarViewDrawer(
            current: state.view,
            onSelected: context.read<CalendarCubit>().changeView,
          ),
          body: state.isBusy
              ? const Center(child: CircularProgressIndicator())
              : SfCalendar(
                  controller: _controller,
                  dataSource: _dataSourceFor(state.events),
                  cellBorderColor: Colors.transparent,
                  showNavigationArrow: true,
                  monthViewSettings: const MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment,
                    showAgenda: true,
                  ),
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    timeInterval: Duration(hours: 1),
                    timeRulerSize: 56,
                    minimumAppointmentDuration: Duration(minutes: 15),
                  ),
                  onTap: (details) => _onTap(details, state.events),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openEditor(date: _controller.selectedDate),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
