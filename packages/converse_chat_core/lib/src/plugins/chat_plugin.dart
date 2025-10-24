import '../domain/entities/message.dart';

/// Base interface for all Chat SDK plugins.
///
/// A plugin allows developers to hook into chat events and modify
/// messages before or after they are processed.
///
/// Examples of plugins:
/// - **EncryptionPlugin** — encrypt messages before sending.
/// - **AnalyticsPlugin** — log events when messages are sent or received.
/// - **ModerationPlugin** — block or flag inappropriate content.
/// - **CompressionPlugin** — compress attachments before upload.
abstract class ChatPlugin {
  /// Called before sending a [Message].
  ///
  /// Plugins can modify or reject a message by throwing an exception.
  Future<Message> onSend(Message message) async => message;

  /// Called when a message is received from remote storage.
  ///
  /// Plugins can decrypt, transform, or annotate incoming messages.
  Future<Message> onReceive(Message message) async => message;

  /// Called once when the plugin is registered or initialized.
  Future<void> onInit() async {}

  /// Called when the plugin is being disposed.
  Future<void> onDispose() async {}
}
