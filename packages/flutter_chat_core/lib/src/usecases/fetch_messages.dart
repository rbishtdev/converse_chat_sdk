import '../domain/entities/message.dart';
import '../ports/i_chat_repository.dart';

/// Fetches a list of messages from a chat, ordered by timestamp.
///
/// Supports pagination via [beforeMessageId].
class FetchMessages {
  final IChatRepository chatRepository;

  FetchMessages(this.chatRepository);

  /// Retrieves messages for the given [chatId].
  Future<List<Message>> call(
      String chatId, {
        String? beforeMessageId,
        int limit = 50,
      }) async {
    return chatRepository.fetchMessages(
      chatId,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
  }
}
