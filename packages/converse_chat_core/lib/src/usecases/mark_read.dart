import '../ports/i_chat_repository.dart';

/// Marks a message as read for a specific user.
///
/// This use case updates the message metadata in the data source
/// and is often triggered when the chat screen becomes visible.
class MarkRead {
  final IChatRepository chatRepository;

  MarkRead(this.chatRepository);

  /// Marks message [messageId] in chat [chatId] as read by [userId].
  Future<void> call({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    await chatRepository.markAsRead(chatId, messageId, userId);
  }
}
