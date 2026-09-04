/// The lifecycle every loaded screen shares.
///
/// Previously each feature declared its own identical copy of this, and the
/// three `copyWith`s disagreed about whether an error message survived — one
/// cleared it on any copy, one kept it, one had no `copyWith` at all.
enum LoadStatus {
  initial,
  loading,
  ready,
  failure;

  /// True before the first result has arrived.
  bool get isBusy => this == initial || this == loading;
}
