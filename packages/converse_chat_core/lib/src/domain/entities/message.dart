import 'package:uuid/uuid.dart';
import 'attachment.dart';
import 'message_status.dart';

/// Represents a single chat message within a chat thread.
///
/// This entity is immutable and designed for use with repositories,
/// message pipelines, and UI rendering layers.
///
/// A message can contain either [text] or an [attachment],
/// and maintains a [MessageStatus] to represent its delivery lifecycle.
class Message {
  /// Unique message identifier.
  final String id;

  /// Identifier of the chat this message belongs to.
  final String chatId;

  /// Identifier of the user who sent the message.
  final String senderId;

  /// Text content of the message, if any.
  final String? text;

  /// Media or file attachment, if present.
  final Attachment? attachment;

  /// Unix timestamp (milliseconds since epoch) of message creation.
  final int createdAt;

  /// List of user IDs who have read this message.
  final List<String> readBy;

  /// Current delivery or read status of the message.
  final MessageStatus status;

  /// Creates a new [Message] instance.
  ///
  /// Use the named factories [Message.text] or [Message.attachment]
  /// for convenience.
  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.text,
    this.attachment,
    required this.createdAt,
    this.readBy = const [],
    this.status = MessageStatus.sent,
  });

  // ---------------------------------------------------------------------------
  // FACTORY CONSTRUCTORS
  // ---------------------------------------------------------------------------

  /// Creates a new text message.
  factory Message.text({
    required String chatId,
    required String senderId,
    required String text,
  }) {
    return Message(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: senderId,
      text: text,
      attachment: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      readBy: [],
      status: MessageStatus.sending,
    );
  }

  /// Creates a new attachment message (image, video, etc.).
  factory Message.attachment({
    required String chatId,
    required String senderId,
    required Attachment attachment,
  }) {
    return Message(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: senderId,
      text: null,
      attachment: attachment,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      readBy: [],
      status: MessageStatus.sending,
    );
  }

  // ---------------------------------------------------------------------------
  // COPY AND TRANSFORM
  // ---------------------------------------------------------------------------

  /// Returns a new [Message] with updated values.
  ///
  /// Used for immutability when updating state (e.g., marking as read).
  Message copyWith({
    String? text,
    Attachment? attachment,
    List<String>? readBy,
    MessageStatus? status,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: text ?? this.text,
      attachment: attachment ?? this.attachment,
      createdAt: createdAt,
      readBy: readBy ?? this.readBy,
      status: status ?? this.status,
    );
  }

  // ---------------------------------------------------------------------------
  // UTILITIES
  // ---------------------------------------------------------------------------

  /// Converts this message to a JSON-compatible map for storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'text': text,
    'attachment': attachment?.toJson(),
    'createdAt': createdAt,
    'readBy': readBy,
    'status': status.name,
  };

  /// Creates a [Message] instance from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String?,
      attachment:
          json['attachment'] != null
              ? Attachment.fromJson(
                Map<String, dynamic>.from(json['attachment']),
              )
              : null,
      createdAt: json['createdAt'] as int,
      readBy: List<String>.from(json['readBy'] ?? []),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == (json['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Returns true if the message contains a text body.
  bool get isText => text != null && text!.isNotEmpty;

  /// Returns true if the message contains an attachment.
  bool get hasAttachment => attachment != null;

  /// Returns whether a specific user has read this message.
  bool isReadBy(String userId) => readBy.contains(userId);
}
