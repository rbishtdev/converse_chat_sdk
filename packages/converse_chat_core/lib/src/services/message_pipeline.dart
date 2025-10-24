import 'package:fpdart/fpdart.dart';
import '../domain/entities/message.dart';
import '../plugins/plugin_registry.dart';
import '../ports/i_chat_repository.dart';
import 'encryption_strategy.dart';
import '../errors/chat_failure.dart';
import '../errors/error_mapper.dart';

/// Coordinates message transformations before and after delivery.
///
/// Handles encryption, plugin hooks, and ensures message integrity.
///
/// Returns [Either] results to maintain a functional flow:
/// - [Right]: success
/// - [Left]: [ChatFailure] describing the error
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
  ///
  /// Steps:
  /// 1️⃣ Encrypt message text (if applicable)
  /// 2️⃣ Run pre-send plugins
  /// 3️⃣ Send message through the [IChatRepository]
  ///
  /// Returns:
  /// - [Right]: [Unit] if message sent successfully
  /// - [Left]: [ChatFailure] if encryption, plugin, or repository fails
  Future<Either<ChatFailure, Unit>> send(Message message) async {
    try {
      var processed = message;

      // 1️⃣ Encrypt message text (if applicable)
      if (processed.text != null && processed.text!.isNotEmpty) {
        final encryptedText = await encryption.encrypt(processed.text!);
        processed = processed.copyWith(text: encryptedText);
      }

      // 2️⃣ Run pre-send plugins
      processed = await pluginRegistry.runOnSend(processed);

      // 3️⃣ Send message via repository
      final result = await chatRepository.sendMessage(processed);

      return result; // Already an Either<ChatFailure, Unit>
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  /// Handles received messages: decryption + plugin hooks.
  ///
  /// Steps:
  /// 1️⃣ Run post-receive plugins
  /// 2️⃣ Decrypt message text (if applicable)
  ///
  /// Returns:
  /// - [Right]: [Message] after processing
  /// - [Left]: [ChatFailure] if any stage fails
  Future<Either<ChatFailure, Message>> processIncoming(Message message) async {
    try {
      var processed = await pluginRegistry.runOnReceive(message);

      // 1️⃣ Decrypt message text (if applicable)
      if (processed.text != null && processed.text!.isNotEmpty) {
        final decrypted = await encryption.decrypt(processed.text!);
        processed = processed.copyWith(text: decrypted);
      }

      return right(processed);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }
}
