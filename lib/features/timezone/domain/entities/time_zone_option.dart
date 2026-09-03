import 'package:equatable/equatable.dart';

/// One selectable IANA time zone, e.g. `Asia/Kathmandu` at +05:45.
class TimeZoneOption extends Equatable {
  const TimeZoneOption({
    required this.id,
    required this.offset,
    required this.abbreviation,
  });

  final String id;
  final Duration offset;
  final String abbreviation;

  /// The offset as `UTC+05:45`.
  String get formattedOffset {
    final sign = offset.isNegative ? '-' : '+';
    final absolute = offset.abs();
    final hours = absolute.inHours.toString().padLeft(2, '0');
    final minutes = (absolute.inMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  @override
  List<Object?> get props => [id, offset, abbreviation];
}
