part of 'event_editor_cubit.dart';

/// The form's state.
///
/// Holds the [CalendarEvent] being built rather than mirroring its fields.
/// The mirrored version silently dropped anything the form did not know about
/// on every save, and had to be extended by hand for each new event field.
class EventEditorState extends Equatable {
  const EventEditorState({
    required this.draft,
    required this.isNew,
    this.status = LoadStatus.initial,
    this.errorMessage,
  });

  final CalendarEvent draft;
  final bool isNew;
  final LoadStatus status;
  final String? errorMessage;

  bool get isEditing => !isNew;

  bool get isSaving => status == LoadStatus.loading;

  EventEditorState copyWith({
    CalendarEvent? draft,
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EventEditorState(
      draft: draft ?? this.draft,
      isNew: isNew,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [draft, isNew, status, errorMessage];
}
