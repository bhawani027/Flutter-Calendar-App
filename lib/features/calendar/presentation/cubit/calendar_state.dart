part of 'calendar_cubit.dart';

/// The four ways the calendar can be displayed.
///
/// Mirrors the view switcher in Google Calendar and Outlook.
enum CalendarViewType {
  day('Day', Icons.calendar_view_day_outlined),
  week('Week', Icons.calendar_view_week_outlined),
  month('Month', Icons.calendar_view_month_outlined),
  schedule('Schedule', Icons.view_agenda_outlined);

  const CalendarViewType(this.label, this.icon);

  final String label;
  final IconData icon;
}

class CalendarState extends Equatable {
  const CalendarState({
    required this.focusedDate,
    this.status = LoadStatus.initial,
    this.events = const [],
    this.view = CalendarViewType.month,
    this.selectedDate,
    this.errorMessage,
  });

  final LoadStatus status;
  final List<CalendarEvent> events;
  final CalendarViewType view;

  /// The date the calendar is currently showing — the anchor for the header
  /// label. Updated as the user swipes between periods.
  final DateTime focusedDate;

  /// The date the user last tapped, if any.
  final DateTime? selectedDate;

  final String? errorMessage;

  bool get isBusy => status.isBusy;

  /// True when the visible period already contains today, which is what hides
  /// the "jump to today" affordance.
  bool showsToday({DateTime? now}) {
    final today = now ?? DateTime.now();
    return switch (view) {
      CalendarViewType.day => focusedDate.isSameDay(today),
      CalendarViewType.week => _weekContains(focusedDate, today),
      CalendarViewType.month || CalendarViewType.schedule =>
        focusedDate.year == today.year && focusedDate.month == today.month,
    };
  }

  static bool _weekContains(DateTime focused, DateTime day) {
    final start = focused.startOfWeek;
    final end = start.addDays(7);
    return !day.isBefore(start) && day.isBefore(end);
  }

  CalendarState copyWith({
    LoadStatus? status,
    List<CalendarEvent>? events,
    CalendarViewType? view,
    DateTime? focusedDate,
    DateTime? selectedDate,
    bool clearSelection = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalendarState(
      status: status ?? this.status,
      events: events ?? this.events,
      view: view ?? this.view,
      focusedDate: focusedDate ?? this.focusedDate,
      selectedDate: clearSelection ? null : selectedDate ?? this.selectedDate,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    events,
    view,
    focusedDate,
    selectedDate,
    errorMessage,
  ];
}
