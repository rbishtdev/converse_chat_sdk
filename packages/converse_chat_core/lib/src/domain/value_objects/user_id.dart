/// Represents a unique user identifier.
///
/// Using a value object instead of a plain string adds type safety
/// and prevents ID mixups across different entities.
class UserId {
  final String value;

  UserId._(this.value);

  factory UserId.fromString(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('UserId cannot be empty.');
    }
    return UserId._(id);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is UserId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
