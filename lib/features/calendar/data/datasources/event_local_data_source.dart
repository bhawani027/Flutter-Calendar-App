import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/calendar_event.dart';
import '../models/calendar_event_model.dart';

/// Where events physically live.
///
/// Swapping Hive for sqflite, a REST API, or an in-memory fake means writing
/// another implementation of this interface — nothing above it changes.
abstract interface class EventLocalDataSource {
  Future<List<CalendarEvent>> readAll();

  Future<void> write(CalendarEvent event);

  Future<void> delete(String id);

  /// Fires whenever the underlying store is mutated.
  Stream<void> changes();
}

class HiveEventLocalDataSource implements EventLocalDataSource {
  const HiveEventLocalDataSource(this._box);

  /// Name of the Hive box holding one JSON document per event.
  static const String boxName = 'calendar_events';

  /// Events are stored as JSON strings keyed by id, which keeps the schema
  /// readable and avoids a generated `TypeAdapter`.
  final Box<String> _box;

  @override
  Future<List<CalendarEvent>> readAll() async {
    try {
      return _box.values
          .map(
            (raw) => CalendarEventModel.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (error) {
      throw CacheException('Failed to read stored events: $error');
    }
  }

  @override
  Future<void> write(CalendarEvent event) async {
    try {
      await _box.put(event.id, jsonEncode(CalendarEventModel.toJson(event)));
    } catch (error) {
      throw CacheException('Failed to save event ${event.id}: $error');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (error) {
      throw CacheException('Failed to delete event $id: $error');
    }
  }

  @override
  Stream<void> changes() => _box.watch();
}
