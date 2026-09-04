part of 'calendar_cubit.dart';

/// The four ways the calendar can be displayed.
///
/// Replaces the four near-identical screens the app used to have.
enum CalendarViewType {
  schedule('Schedule', Icons.schedule),
  day('Day', Icons.calendar_view_day),
  week('Week', Icons.calendar_view_week),
  month('Month', Icons.calendar_view_month);

  const CalendarViewType(this.label, this.icon);

  final String label;
  final IconData icon;
}

class CalendarState extends Equatable {
  const CalendarState({
    this.status = LoadStatus.initial,
    this.events = const [],
    this.view = CalendarViewType.month,
    this.errorMessage,
  });

  final LoadStatus status;
  final List<CalendarEvent> events;
  final CalendarViewType view;
  final String? errorMessage;

  bool get isBusy => status.isBusy;

  CalendarState copyWith({
    LoadStatus? status,
    List<CalendarEvent>? events,
    CalendarViewType? view,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalendarState(
      status: status ?? this.status,
      events: events ?? this.events,
      view: view ?? this.view,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, events, view, errorMessage];
}
