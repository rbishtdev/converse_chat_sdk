import '../domain/entities/message.dart';
import '../plugins/plugin_registry.dart';
import '../ports/i_chat_repository.dart';
import 'encryption_strategy.dart';
import '../errors/core_errors.dart';

/// Coordinates message transformations before and after delivery.
///
/// Handles encryption, plugin hooks, and ensures message integrity.
class MessagePipeline {
  final IChatRepository chatRepository;
  final IEncryptionStrategy encryption;
  final PluginRegistry pluginRegistry;

  MessagePipeline({
    required this.chatRepository,
    required this.encryption,
    required this.pluginRegistry,
  });

  /// Handles sending a message with encryption + plugin hooks.
  Future<void> send(Message message) async {
    try {
      var processed = message;

      // 1️⃣ Encrypt message text (if applicable)
      if (processed.text != null && processed.text!.isNotEmpty) {
        final encryptedText = await encryption.encrypt(processed.text!);
        processed = processed.copyWith(text: encryptedText);
      }

      // 2️⃣ Run pre-send plugins
      processed = await pluginRegistry.runOnSend(processed);

      // 3️⃣ Send message to repository
      await chatRepository.sendMessage(processed);
    } catch (e, stack) {
      throw MessagePipelineException('Failed to send message: $e', stack);
    }
  }

  /// Handles received messages: decryption + plugin hooks.
  Future<Message> processIncoming(Message message) async {
    try {
      var processed = await pluginRegistry.runOnReceive(message);

      // 1️⃣ Decrypt message text (if applicable)
      if (processed.text != null && processed.text!.isNotEmpty) {
        final decrypted = await encryption.decrypt(processed.text!);
        processed = processed.copyWith(text: decrypted);
      }

      return processed;
    } catch (e, stack) {
      throw MessagePipelineException('Failed to process incoming message: $e', stack);
    }
  }
}
