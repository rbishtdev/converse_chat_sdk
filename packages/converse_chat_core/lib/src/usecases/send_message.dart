import '../domain/entities/message.dart';
import '../plugins/plugin_registry.dart';
import '../ports/i_chat_repository.dart';

/// Handles sending a message through the configured [IChatRepository].
///
/// This use case also runs all pre-send [ChatPlugin] hooks (e.g., encryption,
/// content moderation, analytics).
class SendMessage {
  final IChatRepository chatRepository;
  final PluginRegistry pluginRegistry;

  SendMessage({required this.chatRepository, required this.pluginRegistry});

  /// Sends a new message after passing through plugin hooks.
  Future<void> call(Message message) async {
    // 1️⃣ Run pre-send plugin hooks
    final processed = await pluginRegistry.runOnSend(message);

    // 2️⃣ Store message in the repository
    await chatRepository.sendMessage(processed);
  }
}
