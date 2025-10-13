import '../domain/entities/message.dart';
import '../domain/entities/message_status.dart';
import '../plugins/plugin_registry.dart';
import '../ports/i_chat_repository.dart';
import '../ports/i_attachment_repository.dart';
import '../services/message_pipeline.dart';
import '../errors/core_errors.dart';

/// High-level API used by Flutter apps or SDK consumers to send and
/// receive messages.
///
/// This controller glues together:
/// - MessagePipeline
/// - PluginRegistry
/// - Repositories
/// - Attachment handling
///
/// It should remain UI-agnostic — no Flutter imports or Widgets here.
class ChatController {
  final IChatRepository chatRepository;
  final IAttachmentRepository attachmentRepository;
  final MessagePipeline pipeline;
  final PluginRegistry plugins;

  ChatController({
    required this.chatRepository,
    required this.attachmentRepository,
    required this.pipeline,
    required this.plugins,
  });

  /// Watches messages in real-time for a given chat.
  Stream<List<Message>> watchMessages(String chatId, {int limit = 50}) {
    return chatRepository.watchMessages(chatId, limit: limit);
  }

  /// Sends a new text message.
  ///
  /// Passes through encryption, plugin, and pipeline layers.
  Future<void> sendText({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final message = Message.text(
      chatId: chatId,
      senderId: senderId,
      text: text,
    );

    await pipeline.send(message);
  }

  /// Sends a media message (with attachment).
  ///
  /// Handles uploading first, then sends the message with attachment metadata.
  Future<void> sendAttachment({
    required String chatId,
    required String senderId,
    required String filePath,
    required String mimeType,
  }) async {
    try {
      final attachment = await attachmentRepository.uploadAttachment(
        chatId: chatId,
        filePath: filePath,
        mimeType: mimeType,
      );

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: senderId,
        attachment: attachment,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        status: MessageStatus.sending,
      );

      await pipeline.send(message);
    } catch (e, stack) {
      throw MessagePipelineException('Attachment send failed: $e', stack);
    }
  }

  /// Disposes the controller and all active plugins.
  Future<void> dispose() async {
    await plugins.dispose();
  }
}
