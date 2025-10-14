import 'package:fpdart/fpdart.dart';
import '../errors/chat_failure.dart';
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
  ///
  /// Returns an [Either] in the stream:
  /// - [Right]: List of [Message] objects
  /// - [Left]: A [ChatFailure] describing the error
  Stream<Either<ChatFailure, List<Message>>> watchMessages(
      String chatId, {
        int limit = 50,
      });

  /// Sends a new [message] to the chat.
  ///
  /// Implementations should:
  /// - Use server timestamps to prevent client clock drift.
  /// - Optionally update local cache for optimistic UI.
  ///
  /// Returns:
  /// - [Right]: [Unit] on success
  /// - [Left]: [ChatFailure] if sending fails
  Future<Either<ChatFailure, Unit>> sendMessage(Message message);

  /// Fetches older messages for pagination.
  ///
  /// - [beforeMessageId] indicates the starting point for pagination.
  /// - Returns messages ordered from newest → oldest.
  ///
  /// Returns:
  /// - [Right]: List of [Message] objects
  /// - [Left]: [ChatFailure] if retrieval fails
  Future<Either<ChatFailure, List<Message>>> fetchMessages(
      String chatId, {
        String? beforeMessageId,
        int limit = 50,
      });

  /// Marks a specific [messageId] as read by a given [userId].
  ///
  /// The repository should update read receipts or message metadata.
  ///
  /// Returns:
  /// - [Right]: [Unit] if successful
  /// - [Left]: [ChatFailure] if the update fails
  Future<Either<ChatFailure, Unit>> markAsRead(
      String chatId,
      String messageId,
      String userId,
      );

  /// Deletes a message from the chat.
  ///
  /// Implementations must ensure that only authorized users can delete.
  ///
  /// Returns:
  /// - [Right]: [Unit] on success
  /// - [Left]: [ChatFailure] on failure
  Future<Either<ChatFailure, Unit>> deleteMessage(
      String chatId,
      String messageId,
      );

  /// Updates message content or metadata (e.g., edits, reactions).
  ///
  /// Should only be called by the sender or an admin user.
  ///
  /// Returns:
  /// - [Right]: [Unit] if update succeeds
  /// - [Left]: [ChatFailure] if operation fails
  Future<Either<ChatFailure, Unit>> updateMessage(
      String chatId,
      Message message,
      );

  /// ✅ Ensures a chat between [userAId] and [userBId] exists, and returns its chat ID.
  ///
  /// Implementations must:
  /// - Generate deterministic chat IDs (e.g., hashed user IDs)
  /// - Create the chat document if it doesn't exist
  /// - Return the chat ID for reuse
  ///
  /// This is a convenience method to avoid duplicate 1:1 chats.
  Future<Either<ChatFailure, String>> ensureChatExists(
      String userAId,
      String userBId,
      );
}

