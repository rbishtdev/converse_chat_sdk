import 'package:uuid/uuid.dart';

/// Represents a unique message identifier.
///
/// Ensures each message across all chats has a globally unique ID.
class MessageId {
  final String value;

  MessageId._(this.value);

  factory MessageId.generate() => MessageId._(const Uuid().v4());

  factory MessageId.fromString(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('MessageId cannot be empty.');
    }
    return MessageId._(id);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is MessageId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
