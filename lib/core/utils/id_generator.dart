import 'package:uuid/uuid.dart';

/// Abstracted so use cases stay deterministic under test.
abstract interface class IdGenerator {
  String newId();
}

class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator(this._uuid);

  final Uuid _uuid;

  @override
  String newId() => _uuid.v4();
}
