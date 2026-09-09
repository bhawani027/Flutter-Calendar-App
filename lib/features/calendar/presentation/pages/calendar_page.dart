import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/presentation/error_snack_bar.dart';
import '../../domain/entities/calendar_event.dart';
import '../cubit/calendar_cubit.dart';
import '../widgets/calendar_month_cell.dart';
import '../widgets/calendar_period_label.dart';
import '../widgets/calendar_view_menu.dart';
import '../widgets/event_calendar_data_source.dart';
import '../widgets/event_details_sheet.dart';

/// The single calendar screen.
///
/// The calendar widget already handles the mechanics Google Calendar and
/// Outlook share — swiping between periods, vertical time scrolling, laying
/// overlapping events out side by side, the all-day panel and the live
/// current-time line. What this page adds is the shell around it: a header
/// that tracks the visible period, a view switcher, a way back to today, and
/// an event peek that does not interrupt navigation.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController _controller = CalendarController();

  List<CalendarEvent>? _sourceEvents;
  EventCalendarDataSource? _dataSource;

  /// The dates the calendar is currently showing, used to shade past time.
  List<DateTime> _visibleDates = const [];

  /// Redraws the past/upcoming shading as the boundary moves. The current-time
  /// line is animated by the calendar itself; this keeps the shading honest.
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    context.read<CalendarCubit>().start();
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Shades the part of the visible range that has already passed, which is
  /// how Outlook separates spent time from the day ahead.
  List<TimeRegion> _pastRegions(BuildContext context) {
    if (_visibleDates.isEmpty) return const [];
    final now = DateTime.now();
    final shade = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.04);

    final regions = <TimeRegion>[];
    for (final date in _visibleDates) {
      final midnight = DateTime(date.year, date.month, date.day);
      if (midnight.isAfter(now)) continue;
      final end = date.isSameDay(now)
          ? now
          : midnight.add(const Duration(days: 1));
      regions.add(
        TimeRegion(
          startTime: midnight,
          endTime: end,
          color: shade,
          // Still tappable: the user can add an event in the past.
        ),
      );
    }
    return regions;
  }

  /// Rebuilds the Syncfusion adapter only when the event list actually
  /// changes, rather than on every frame.
  EventCalendarDataSource _dataSourceFor(List<CalendarEvent> events) {
    if (!identical(_sourceEvents, events) || _dataSource == null) {
      _sourceEvents = events;
      _dataSource = EventCalendarDataSource(events);
    }
    return _dataSource!;
  }

  static CalendarView _toCalendarView(CalendarViewType type) => switch (type) {
    CalendarViewType.schedule => CalendarView.schedule,
    CalendarViewType.day => CalendarView.day,
    CalendarViewType.week => CalendarView.week,
    CalendarViewType.month => CalendarView.month,
  };

  /// The calendar reports its visible range during layout, so the cubit is
  /// updated after the frame rather than inside it.
  void _onViewChanged(ViewChangedDetails details) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CalendarCubit>().visibleRangeChanged(details.visibleDates);
      if (!_sameRange(_visibleDates, details.visibleDates)) {
        setState(() => _visibleDates = details.visibleDates);
      }
    });
  }

  static bool _sameRange(List<DateTime> a, List<DateTime> b) =>
      a.length == b.length &&
      (a.isEmpty || (a.first == b.first && a.last == b.last));

  void _goTo(DateTime date) {
    _controller.displayDate = date;
    context.read<CalendarCubit>().selectDate(date);
  }

  void _goToToday() => _goTo(DateTime.now());

  Future<void> _pickDate(DateTime focused) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: focused,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) _goTo(picked);
  }

  Future<void> _openEditor({DateTime? date, CalendarEvent? event}) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.eventEditor,
      arguments: EventEditorArgs(initialDate: date, event: event),
    );
  }

  /// Peek first, edit second — a tap while navigating should never drop the
  /// user straight into the editor.
  Future<void> _openEvent(CalendarEvent event) async {
    final action = await showEventDetailsSheet(context, event: event);
    if (!mounted || action == null) return;

    switch (action) {
      case EventDetailsAction.edit:
        await _openEditor(event: event);
      case EventDetailsAction.delete:
        await context.read<CalendarCubit>().deleteEvent(event.id);
    }
  }

  void _onTap(CalendarTapDetails details, CalendarState state) {
    switch (details.targetElement) {
      case CalendarElement.appointment:
        final appointment = details.appointments?.firstOrNull;
        if (appointment is! Appointment) return;
        final match = state.events
            .where((event) => event.id == appointment.id)
            .firstOrNull;
        if (match != null) _openEvent(match);

      case CalendarElement.calendarCell:
        final date = details.date;
        if (date == null) return;
        final cubit = context.read<CalendarCubit>();
        // In month view a tap selects the day and reveals its agenda, the way
        // Google Calendar does. In the time views the cell is a time slot, so
        // it starts a new event there instead.
        if (state.view == CalendarViewType.month) {
          cubit.selectDate(date);
        } else {
          _openEditor(date: date);
        }

      case CalendarElement.viewHeader:
        final date = details.date;
        if (date == null) return;
        // Tapping a weekday drills into that day, as in both reference apps.
        context.read<CalendarCubit>().changeView(CalendarViewType.day);
        _goTo(date);

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalendarCubit>();

    return BlocConsumer<CalendarCubit, CalendarState>(
      listenWhen: (previous, current) =>
          errorAppeared(previous.errorMessage, current.errorMessage),
      listener: (context, state) {
        showErrorSnackBar(context, state.errorMessage!);
        context.read<CalendarCubit>().clearError();
      },
      builder: (context, state) {
        _controller.view = _toCalendarView(state.view);
        final showsToday = state.showsToday();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            centerTitle: false,
            title: _PeriodTitle(
              label: CalendarPeriodLabel.of(state.view, state.focusedDate),
              onTap: () => _pickDate(state.focusedDate),
            ),
            actions: [
              if (!showsToday)
                IconButton(
                  icon: const Icon(Icons.today_outlined),
                  tooltip: 'Go to today',
                  onPressed: _goToToday,
                ),
              CalendarViewMenu(
                current: state.view,
                onSelected: cubit.changeView,
              ),
            ],
          ),
          body: state.isBusy
              ? const Center(child: CircularProgressIndicator())
              : _buildCalendar(state),
          floatingActionButton: FloatingActionButton(
            tooltip: 'New event',
            onPressed: () => _openEditor(
              date: state.selectedDate ?? _controller.selectedDate,
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCalendar(CalendarState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SfCalendar(
      controller: _controller,
      dataSource: _dataSourceFor(state.events),
      // Left unset so the grid renders in the device's zone; events that name
      // a zone carry it on the appointment and are converted into this one.
      showNavigationArrow: false,
      showDatePickerButton: false,
      showCurrentTimeIndicator: true,
      todayHighlightColor: colors.primary,
      cellBorderColor: colors.outlineVariant,
      backgroundColor: colors.surface,
      selectionDecoration: BoxDecoration(
        border: Border.all(color: colors.primary, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      headerHeight: 0,
      viewHeaderHeight: state.view == CalendarViewType.month ? 32 : 62,
      onViewChanged: _onViewChanged,
      onTap: (details) => _onTap(details, state),
      specialRegions: _pastRegions(context),
      viewHeaderStyle: ViewHeaderStyle(
        backgroundColor: colors.surface,
        dayTextStyle: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
        dateTextStyle: theme.textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
        ),
      ),
      todayTextStyle: theme.textTheme.titleMedium?.copyWith(
        color: colors.onPrimary,
        fontWeight: FontWeight.w700,
      ),
      monthCellBuilder: (context, details) => CalendarMonthCell(
        details: details,
        visibleMonth: _visibleMonthOf(details),
        isSelected: state.selectedDate?.isSameDay(details.date) ?? false,
      ),
      monthViewSettings: MonthViewSettings(
        // The cell builder draws the dots itself, capped and with an overflow
        // count; leaving the built-in indicators on would double them up.
        appointmentDisplayMode: MonthAppointmentDisplayMode.none,
        showAgenda: true,
        agendaViewHeight: 240,
        agendaItemHeight: 56,
        dayFormat: 'EEE',
        agendaStyle: AgendaStyle(
          backgroundColor: colors.surface,
          dayTextStyle: theme.textTheme.labelMedium,
          dateTextStyle: theme.textTheme.titleMedium,
          appointmentTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onPrimary,
          ),
        ),
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        timeInterval: const Duration(hours: 1),
        timeIntervalHeight: 56,
        timeRulerSize: 60,
        timeFormat: 'h a',
        minimumAppointmentDuration: const Duration(minutes: 20),
        allDayPanelColor: colors.surfaceContainerLow,
        timeTextStyle: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      scheduleViewSettings: ScheduleViewSettings(
        hideEmptyScheduleWeek: true,
        appointmentItemHeight: 60,
        monthHeaderSettings: MonthHeaderSettings(
          height: 56,
          // Distinct from the app bar, which is also primaryContainer — the
          // two ran together into one green block otherwise.
          backgroundColor: colors.surfaceContainerHighest,
          monthTextStyle: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }

  /// The month the grid is showing, taken from the middle of the visible
  /// range so that leading and trailing days do not win the vote.
  static int _visibleMonthOf(MonthCellDetails details) =>
      details.visibleDates[details.visibleDates.length ~/ 2].month;
}

class _PeriodTitle extends StatelessWidget {
  const _PeriodTitle({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
