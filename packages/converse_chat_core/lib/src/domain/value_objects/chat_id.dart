import 'package:uuid/uuid.dart';

/// Represents a unique identifier for a chat.
///
/// This value object ensures consistent typing and validation for chat IDs.
/// Internally uses a [String] but provides utility constructors for creation.
class ChatId {
  final String value;

  ChatId._(this.value);

  /// Creates a new random [ChatId] using UUID v4.
  factory ChatId.generate() => ChatId._(const Uuid().v4());

  /// Creates a [ChatId] from an existing string.
  ///
  /// Throws [ArgumentError] if the string is empty.
  factory ChatId.fromString(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('ChatId cannot be empty.');
    }
    return ChatId._(id);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is ChatId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
