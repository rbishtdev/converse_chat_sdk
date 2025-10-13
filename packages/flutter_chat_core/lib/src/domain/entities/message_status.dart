/// Represents the lifecycle state of a chat message.
///
/// This value object is used by both the domain layer and
/// repositories to track message progress.
///
/// Common transitions:
/// - [sending] → [sent] → [delivered] → [read]
/// - or [sending] → [failed]
enum MessageStatus {
  /// The message has been created locally but not yet uploaded.
  sending,

  /// Successfully written to the server or backend.
  sent,

  /// Delivered to the recipient’s device(s).
  delivered,

  /// The recipient has opened the chat and read this message.
  read,

  /// (Optional future use) Upload or send failed.
  failed,
}
