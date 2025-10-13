import '../domain/entities/message.dart';

/// Contract for managing chat message data sources.
///
/// This is the **primary data port** between the chat domain and any external
/// storage (Firestore, Supabase, REST API, local DB, etc.).
///
/// All implementations of [IChatRepository] must guarantee:
/// - Messages are stored and retrieved consistently.
/// - Message order is preserved based on server timestamps.
/// - Real-time updates (if supported) are emitted via streams.
abstract class IChatRepository {
  /// Watches messages for a specific [chatId] in real time.
  ///
  /// The returned [Stream] should emit the entire ordered list of messages
  /// whenever new messages are added, updated, or deleted.
  ///
  /// Implementations may apply pagination limits (default [limit] = 50).
  Stream<List<Message>> watchMessages(
      String chatId, {
        int limit = 50,
      });

  /// Sends a new [message] to the chat.
  ///
  /// Implementations should:
  /// - Use server timestamps to prevent client clock drift.
  /// - Optionally update local cache for optimistic UI.
  Future<void> sendMessage(Message message);

  /// Fetches older messages for pagination.
  ///
  /// - [beforeMessageId] indicates the starting point for pagination.
  /// - Returns messages ordered from newest → oldest.
  Future<List<Message>> fetchMessages(
      String chatId, {
        String? beforeMessageId,
        int limit = 50,
      });

  /// Marks a specific [messageId] as read by a given [userId].
  ///
  /// The repository should update read receipts or message metadata.
  Future<void> markAsRead(String chatId, String messageId, String userId);

  /// Deletes a message from the chat.
  ///
  /// Implementations must ensure that only authorized users can delete.
  Future<void> deleteMessage(String chatId, String messageId);

  /// Updates message content or metadata (e.g., edits, reactions).
  ///
  /// Should only be called by the sender or an admin user.
  Future<void> updateMessage(String chatId, Message message);
}
