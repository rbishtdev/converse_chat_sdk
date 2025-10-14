import 'package:fpdart/fpdart.dart';
import '../errors/chat_failure.dart';
import '../domain/entities/message.dart';
import '../ports/i_chat_repository.dart';

/// Fetches a list of messages from a chat, ordered by timestamp.
///
/// Supports pagination via [beforeMessageId].
///
/// Returns an [Either]:
/// - [Right]: List of [Message] objects on success.
/// - [Left]: [ChatFailure] on failure (network, permission, etc.).
class FetchMessages {
  final IChatRepository chatRepository;

  FetchMessages(this.chatRepository);

  /// Retrieves messages for the given [chatId].
  ///
  /// - [beforeMessageId] can be used for pagination.
  /// - [limit] controls how many messages are fetched.
  ///
  /// Example:
  /// ```dart
  /// final result = await fetchMessages('chat123', limit: 20);
  /// result.match(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (messages) => print('Fetched ${messages.length} messages'),
  /// );
  /// ```
  Future<Either<ChatFailure, List<Message>>> call(
      String chatId, {
        String? beforeMessageId,
        int limit = 50,
      }) async {
    return await chatRepository.fetchMessages(
      chatId,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
  }
}
